# ⚡ Safety Boundary Quick Reference

## TL;DR - 30 Second Review Checklist

```
✅ SAFE Changes (Can Merge):
  ☑ Image tag updates only
  ☑ Replica count (1→3, 3→5, etc)
  ☑ Resource limits (memory, CPU)
  ☑ Environment variables
  ☑ terraform plan (dev only)
  ☑ Log levels, debug flags
  ☑ Helm chart values only

❌ DANGER - DO NOT MERGE:
  ☐ Touching backend.tf
  ☐ AWS credentials visible
  ☐ terraform destroy (ANY)
  ☐ VPC/Network changes
  ☐ IAM role modifications
  ☐ Kubernetes secrets
  ☐ Module infrastructure files
```

---

## Files You CAN Review/Change

| File                                      | ✅ Safe? | What's OK                                 |
| ----------------------------------------- | -------- | ----------------------------------------- |
| `helm/charts/values-dev.yaml`             | ✅       | image tag, replicas, resources            |
| `helm/charts/values-prod.yaml`            | ✅       | image tag, replicas, resources            |
| `helm/charts/values-staging.yaml`         | ✅       | image tag, replicas, resources            |
| `helm/charts/templates/deployment-*.yaml` | ✅       | env vars, labels, port (no pod structure) |
| `infra/eks/dev.tfvars`                    | ⚠️       | Only if NOT production                    |

---

## Files You CANNOT Modify

| File                     | ❌ DO NOT  | Why                                    |
| ------------------------ | ---------- | -------------------------------------- |
| `infra/eks/backend.tf`   | ❌ NEVER   | State management - cluster disaster    |
| `infra/eks/main.tf`      | ❌ NEVER   | Infrastructure core config             |
| `infra/eks/variables.tf` | ❌ MAYBE   | Only if reviewed by infra team         |
| `infra/module/*.tf`      | ❌ NEVER   | VPC, IAM, networking - total breakdown |
| `infra/Jenkinsfile`      | ⚠️ CAREFUL | Never add credentials                  |
| Kubernetes Secrets (any) | ❌ NEVER   | Secret exposure risk                   |

---

## Instant Red Flags 🚨

If PR contains ANY of these → **REJECT IMMEDIATELY**:

```diff
❌ backend.tf changed
❌ AWS key / secret visible (AKIA...)
❌ DynamoDB table dropped
❌ VPC CIDR changed
❌ IAM policy removed
❌ destroy action on prod
❌ hardcoded credentials
❌ registry login token exposed
❌ terraform state deleted
❌ security_group rules deleted
```

---

## Approval Template

```markdown
✅ APPROVED - Safe deployment

**Reviewed:**

- [x] Changes are image/replicas/resources only
- [x] No infrastructure files modified
- [x] No credentials exposed
- [x] Tests passed
- [x] Dev environment only (if tfvars)
- [x] Rollback plan understood

**Approval:** This PR is safe to merge

- Low risk to production
- Easy to revert if needed
- Follow-up monitoring recommended
```

---

## Rejection Template

```markdown
❌ REQUEST CHANGES - Safety concerns

**Issue Found:**

- [ ] Backend.tf detected - CRITICAL
- [ ] Credentials exposed - SECURITY
- [ ] Destroy on production - DISASTER
- [ ] Infrastructure config - REQUIRES REVIEW
- [ ] No tests - VALIDATION NEEDED

**Required:**

1. Remove dangerous changes
2. Keep only safe modifications
3. Re-run tests
4. Assign infra team for review (if needed)

**Do not merge without addressing safety concerns**
```

---

## Environment Safety Levels

```
🟢 DEV (Most Flexible)
   - Can test image tags
   - Can scale up/down
   - Can run destroy (for testing)
   - Can adjust resources
   - Can enable debug flags

🟡 STAGING (Careful)
   - Can update image tags
   - Can scale with approval
   - Cannot destroy without warning
   - Can adjust resources (minor)
   - Cannot run terraform destroy

🔴 PRODUCTION (Locked Down)
   - Only hot-fixes allowed
   - Image tag updates via process
   - Scaling requires approval
   - NO terraform destroy allowed
   - NO credential changes
   - Infrastructure team review required
```

---

## Common Changes Matrix

| Change            | File               | Dev | Staging | Prod | Command           |
| ----------------- | ------------------ | --- | ------- | ---- | ----------------- |
| Image tag         | values-\*.yaml     | ✅  | ✅      | ✅   | `helm upgrade -f` |
| Replicas          | values-\*.yaml     | ✅  | ✅      | ⚠️   | `helm upgrade -f` |
| CPU/Memory        | deployment-\*.yaml | ✅  | ✅      | ⚠️   | `helm upgrade -f` |
| Env vars          | deployment-\*.yaml | ✅  | ✅      | ⚠️   | `helm upgrade -f` |
| Test              | main_test.go       | ✅  | ✅      | ❌   | `go test`         |
| Terraform Plan    | \*                 | ✅  | ✅      | ✅   | `terraform plan`  |
| Terraform Apply   | \*                 | ✅  | ⚠️      | ❌   | `terraform apply` |
| Terraform Destroy | \*                 | ✅  | ❌      | ❌   | Never use         |

---

## One-Liner Decisions

```
🟢 "Just image tag update?" → APPROVE
🟢 "Only helm values changed?" → APPROVE
🟢 "Replicas going from 1→3?" → APPROVE
🟢 "terraform plan output?" → APPROVE
🟢 "Resource limits increased?" → APPROVE

🔴 "backend.tf touched?" → REJECT (CRITICAL)
🔴 "Credentials visible?" → REJECT (SECURITY)
🔴 "Destroy on prod?" → REJECT (DISASTER)
🔴 "Module files changed?" → REJECT (INFRA ONLY)
🔴 "State files deleted?" → REJECT (CRITICAL)
```

---

## Peer Review Workflow

```
1. Open PR
   ↓
2. Run Safety Check:
   ├─ "Is only helm values changed?" → YES ✅
   ├─ "Are credentials exposed?" → NO ✅
   ├─ "Is destroy on production?" → NO ✅
   └─ "Did tests pass?" → YES ✅
   ↓
3. Decide:
   ├─ ALL ✅ → APPROVE
   ├─ ANY ❌ → REQUEST CHANGES
   └─ UNCLEAR → ASK for clarification
   ↓
4. Post Review Comment
```

---

## When in Doubt

```
❓ "Should I approve this?"

Ask:
1. Can the system still work if this fails?
   └─ NO → Request changes
2. Can we rollback in 5 minutes?
   └─ NO → Request changes
3. Does infrastructure team need to review?
   └─ YES → Tag infrastructure team
4. Are there credentials/secrets visible?
   └─ YES → REJECT immediately
5. Is it just image/replicas/resources?
   └─ YES → APPROVE (after tests pass)
```

---

## Key Contacts

```
🔧 Infrastructure Issues:
   → Contact infrastructure team
   → For: backend.tf, main.tf, module/*.tf changes
   → Decision: Infrastructure team approval required

🐳 Application Issues:
   → Contact app development team
   → For: app code, Dockerfile changes
   → Decision: Code review team approval

🔐 Security Issues:
   → Contact security team immediately
   → For: credentials, secrets, permissions
   → Decision: REJECT, rotate credentials

🚀 Deployment Issues:
   → Contact DevOps team
   → For: Jenkinsfile, Helm chart changes
   → Decision: DevOps team approval
```

---

**Quick Reference Last Updated:** May 14, 2026  
**Current PR:** Feat/terraform-s3-backend (Backend S3 state management)

---

### 📌 Remember

> **Golden Rule:** If you're not 100% sure → REJECT and ask for clarification
>
> **Better safe than sorry:** It's OK to slow down deployment for safety
>
> **When critical:** Infrastructure, security, production = Infrastructure team decides
