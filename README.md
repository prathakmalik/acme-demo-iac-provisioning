# acme-demo-iac-provisioning

Modular Terraform for **Demo Infrastructure Automation (DIA)** — time-boxed AWS and GCP demo environments, provisioned and destroyed by GitHub Actions when Workato dispatches a workflow.

Solutions Consultants open a Jira **Provisioning Request**. Workato looks up the request type in a catalog, then calls this repository’s workflow. After apply or destroy, Actions posts results back to Workato, which updates Jira and Slack.

This repo is the **execution plane** (Terraform + CI). Intake, TTL, notifications, and the request log live in Workato.

---

## How it fits together

```
Jira  →  Workato Orchestrator  →  GitHub Actions (this repo)
                                      ↓
                              terraform apply / destroy
                                      ↓
                                 AWS / GCP
                                      ↓
                         POST callback → Workato Result Listener
                                      ↓
                              Jira + Slack
```

A daily Workato **Lifecycle Reaper** dispatches the same workflow with `action=destroy` for expired requests.

---

## Repository layout

```
.github/workflows/config.yml     Single parameterized workflow (apply + destroy)
backend.tf                       Shared S3 backend (bucket + region); key is set at init
terraform/
  aws/
    s3_bucket/                   Cloud Storage
    ec2_instance/                Compute
    rds_instance/                Database (MySQL)
    modules/iam-user/            Shared: create or reuse SC IAM user
  aws_bundled/
    wordpress_demo/              Full stack: EC2 + RDS + S3 + security group
  gcp/
    gcp_bucket/                  Cloud Storage
    compute_instance/            Compute (OS Login)
    sql_instance/                Cloud SQL (MySQL)
```

Working directory for every run:

```text
terraform/{cloud_provider}/{module_id}
```

`cloud_provider` and `module_id` are workflow inputs and must match a folder pair above (for example `aws` + `s3_bucket`, `aws_bundled` + `wordpress_demo`, `gcp` + `sql_instance`).

---

## What gets provisioned

| Request type (Jira catalog) | `cloud_provider` | `module_id` | Default TTL (Workato) | Category |
|---|---|---|---|---|
| AWS - S3 Bucket | `aws` | `s3_bucket` | 14 days | Cloud Storage |
| AWS - EC2 Server | `aws` | `ec2_instance` | 7 days | Compute |
| AWS - Relational Database | `aws` | `rds_instance` | 7 days | Database |
| AWS - WordPress | `aws_bundled` | `wordpress_demo` | 7 days | FullStack |
| GCP - Storage Bucket | `gcp` | `gcp_bucket` | 14 days | Cloud Storage |
| GCP - Compute Instance | `gcp` | `compute_instance` | 7 days | Compute |
| GCP - Cloud SQL Database | `gcp` | `sql_instance` | 7 days | Database |

Storage is created **in Terraform**, not via a Workato S3 connector.

**WordPress bundle:** EC2, RDS MySQL, S3, and a security group (HTTP/80). Load balancer resources are commented out — the demo AWS account does not allow ELBv2 `CreateLoadBalancer`.

**Not in this repo (catalog-extensible):** Lambda, Cloud Functions, ECS, GKE.

---

## GitHub Actions workflow

**File:** [`.github/workflows/config.yml`](.github/workflows/config.yml)  
**Name:** `[FIT] [DIA] Terraform Workflow`  
**Trigger:** `workflow_dispatch` only (Workato POST to `/actions/workflows/.../dispatches`).

### Inputs

| Input | Required | Values | Purpose |
|---|---|---|---|
| `action` | yes | `apply` \| `destroy` | Create or tear down |
| `jira_id` | yes | e.g. `FDIA-22` | Request key; also Terraform `req_id` and state key |
| `requester_username` | yes | SC email | IAM user name (AWS modules) |
| `cloud_provider` | yes | `aws` \| `aws_bundled` \| `gcp` | First path segment |
| `module_id` | yes | module directory | Second path segment |
| `db_password` | yes | string | RDS / bundled WordPress (`TF_VAR_db_password`). Reaper may send a dummy value on destroy. |

### Job steps (summary)

1. Checkout  
2. Configure AWS credentials (always)  
3. Configure GCP credentials **if** `cloud_provider == gcp`  
4. `terraform init` with backend key `demo-infra/{jira_id}/terraform.tfstate`  
5. `terraform apply -auto-approve` **or** `terraform destroy -auto-approve`  
6. On **apply failure:** `terraform destroy` rollback  
7. **Always:** `POST` JSON to Workato (`jira_id`, `action`, `success`, `outputs`)

Terraform variables passed from CI:

- `TF_VAR_req_id` ← `jira_id`
- `TF_VAR_requester_username`
- `TF_VAR_db_password`

---

## State

Remote state is **S3**:

- Bucket: `fit-dia-terraform-state`
- Region: `us-east-1`
- Encryption: on
- Locking: `use_lockfile = true`
- Object key (per request): `demo-infra/{jira_id}/terraform.tfstate`

Each Jira request has isolated state, so destroy does not collide with other demos.

---

## Secrets (GitHub Actions)

Configure these on the repository (or environment). Never commit them.

| Secret | Used for |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS provider |
| `AWS_SECRET_ACCESS_KEY` | AWS provider |
| `GCP_SA_KEY` | GCP auth JSON (GCP jobs only) |
| `WORKATO_API_KEY` | Callback header `api-token` |
| `WORKATO_RESULT_WEBHOOK_URL` | Full Workato API URL (`…/fit-dia-iac-management-api-collection-v1/status-v2`) |

Production hardening: replace static AWS keys with **GitHub OIDC → IAM role**, and GCP JSON with **Workload Identity Federation**.

---

## Callback contract (Workato)

GitHub Actions POSTs JSON roughly:

```json
{
  "jira_id": "FDIA-22",
  "action": "apply",
  "success": true,
  "outputs": { }
}
```

On `apply`, `outputs` is `terraform output -json` (sensitive outputs included in that JSON). On `destroy`, `outputs` is `null`.

Workato maps outputs such as:

- `compute_instance_details`
- `db_instance_details`
- `storage_bucket_details`
- `user_login_details`
- `security_group_details` (WordPress bundle)

---

## AWS IAM user module

[`terraform/aws/modules/iam-user`](terraform/aws/modules/iam-user) is used by AWS single-resource modules and the WordPress bundle:

- Looks up an IAM user matching `requester_username`
- Creates `/FIT-Users/{username}` **only if missing**, with a console login profile (`password_reset_required`)
- Inline policies are **scoped to the resource ARN** (Describe/list plus start/stop/reboot or S3 object access as appropriate)

GCP modules do not create per-user IAM identities in this version (OS Login on GCE; bucket/SQL outputs only).

---

## Tagging

Typical tags / labels:

- `Environment` / `environment` = `Demo` / `demo`
- `Name` includes the Jira id
- `Decommission-Date` / `decommission_date` — intended for cost and orphan reports  

Note: the workflow does **not** currently pass `TF_VAR_decommission_date`; modules default to a placeholder date unless you add that input.

---

## Adding a new resource type

1. Add `terraform/{cloud_provider}/{module_id}/` with `main.tf`, `variables.tf`, `output.tf` (and `access.tf` if AWS IAM is needed). Reuse the same S3 backend block; CI still injects the state **key**.
2. Expose outputs using the same names Workato already parses (`compute_instance_details`, `db_instance_details`, `storage_bucket_details`, `user_login_details`).
3. Add a row to Workato **IAC Resource Mapping Table**: Request Type, CloudProvider, Service (`module_id`), DefaultTTL, ResourceCategory (`Compute` | `Database` | `Cloud Storage` | `FullStack`).
4. Add the matching Jira **Request Type [FIT]** dropdown option.

No workflow YAML change is required if the new path follows `{cloud_provider}/{module_id}`.

---

## Manual dispatch (debug)

Actions → `[FIT] [DIA] Terraform Workflow` → Run workflow. Use the same inputs Workato would send. Confirm the callback URL and API token are set, or Workato will not update Jira/Slack.

---

## Security notes (demo vs production)

**In place**

- Per-request Terraform state
- Encrypted S3 state
- Per-user AWS IAM with ARN-scoped policies
- Rollback destroy on failed apply
- Sensitive Terraform outputs marked `sensitive = true`

**Known demo-scope gaps**

- Static cloud credentials in GitHub Secrets (prefer OIDC)
- Database password supplied as a workflow input (visible in Actions logs unless masked)
- Shared default security group on some AWS modules (`FIT_DIA_SecurityGroup_All_Traffic`)
- GCP Cloud SQL module uses a weak default DB user password — change before any shared use
- Workato currently stores/sends some credentials in Slack and in a data table — treat as demo-only

---

## Requirements this repo supports

| Exercise theme | In this repo |
|---|---|
| Multi-cloud AWS + GCP | Yes — separate module trees, one workflow |
| Two or more resource types | Yes — compute, storage, database, plus WordPress bundle |
| IaC / templating | Yes — per-type modules + dispatch convention |
| Error handling / rollback | Yes — apply failure → `terraform destroy` |
| Lifecycle / destroy | Yes — same workflow, `action=destroy` |
| Avoid Workato S3 connector | Yes — S3/GCS via Terraform |

Jira intake, TTL reaper, Slack copy, and request logging are **Workato**, not this repository.

---

## License / status

Interview / field-demo solution for Acme Inc DIA. Not a production-hardened platform. See the gaps above before using beyond a controlled demo account.
