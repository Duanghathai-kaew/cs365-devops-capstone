# 🟢 Safe PR Changes Examples

## ✅ Example 1: Update Image Tag (SAFE)

```diff
# helm/charts/values-prod.yaml

replicaCount: 3

image:
  repository: avian19/go-port
  pullPolicy: Always
- tag: production
+ tag: production-v2.1.0

backendReplicaCount: 3
backendImage:
  repository: avian19/go-backend
- tag: production
+ tag: production-v2.1.0
```

**Why SAFE:**

- Only changes application version
- Helm will pull new image and rolling restart pods
- Easy to rollback: `helm rollback <release>`
- No infrastructure changed

---

## ✅ Example 2: Scale Up Replicas (SAFE)

```diff
# helm/charts/values-prod.yaml

- replicaCount: 3
+ replicaCount: 5

image:
  repository: avian19/go-port
  pullPolicy: Always
  tag: production

- backendReplicaCount: 3
+ backendReplicaCount: 5

backendImage:
  repository: avian19/go-backend
  tag: production
```

**Why SAFE:**

- Only increases pod count
- EKS cluster scales gracefully
- Kubernetes scheduler distributes load
- Easy to revert

**Approval Comment:**

```
✅ Approved: Safe scaling change
- Dev tested on staging first ✓
- Resource requests verified ✓
- HPA configuration respected ✓
```

---

## ✅ Example 3: Adjust Resource Limits (SAFE)

```diff
# helm/charts/templates/deployment-app.yaml

resources:
  requests:
-   memory: "256Mi"
+   memory: "512Mi"
-   cpu: "500m"
+   cpu: "750m"
  limits:
-   memory: "512Mi"
+   memory: "1024Mi"
-   cpu: "1"
+   cpu: "2"
```

**Why SAFE:**

- Only affects pod resource requests
- Kubernetes scheduler accounts for new requirements
- No infrastructure scaling unless needed
- Can be reverted immediately

**Approval Comment:**

```
✅ Approved: Resource adjustment
- Memory increase justified by profiling ✓
- CPU headroom adequate on nodes ✓
- Cost impact analyzed ✓
```

---

## ✅ Example 4: Change Environment Variables (SAFE)

```diff
# helm/charts/templates/deployment-app.yaml

spec:
  containers:
    - name: go-portfolio
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
      env:
-       - name: LOG_LEVEL
-         value: "info"
+       - name: LOG_LEVEL
+         value: "debug"
+       - name: ENABLE_METRICS
+         value: "true"
```

**Why SAFE:**

- Runtime configuration only
- Application restart picks up changes
- No structural changes
- Easy to test and verify

**Approval Comment:**

```
✅ Approved: Feature flag update
- Debug mode for troubleshooting ✓
- Metrics enabled for monitoring ✓
- Performance impact acceptable ✓
```

---

## ✅ Example 5: Run Terraform Plan (SAFE)

```groovy
// Jenkinsfile
// Safe action: Just previewing changes

properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'],
            name: 'Terraform_Action'
        )])
])

// ✅ Running: Terraform_Action = 'plan'
// Parameter: Environment = 'dev'

// Result: Shows what WOULD happen, nothing deployed
```

**Why SAFE:**

- `terraform plan` is read-only
- No resources created/modified/deleted
- Good for peer review before apply
- No state changes

**Approval Comment:**

```
✅ Approved: Plan review complete
- Plan output reviewed ✓
- No unexpected changes ✓
- Ready for apply when needed ✓
```

---

## ❌ Examples: DO NOT APPROVE

### ❌ Example A: Modifying Backend Configuration (DANGEROUS)

```diff
# infra/eks/backend.tf ❌ DO NOT MERGE

terraform {
  backend "s3" {
-   bucket         = "cs365-terraform-state-kaew"
+   bucket         = "cs365-terraform-state-new"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
```

**Why DANGEROUS:**

- ❌ Terraform loses connection to current state
- ❌ Thinks infrastructure doesn't exist
- ❌ `terraform apply` will CREATE new resources (duplicate!)
- ❌ Cluster becomes unmanageable

**Rejection Comment:**

```
❌ REJECTED: Backend config change detected
DANGER ZONE - Do NOT merge:
- Backend S3 bucket changed
- This will break terraform state tracking
- Cluster could be destroyed/duplicated
- Talk to infrastructure team first
```

---

### ❌ Example B: Using Destroy on Production (DANGEROUS)

```groovy
// Jenkinsfile
// ❌ DANGER: Destroy production EKS cluster

properties([
    parameters([
        string(
            defaultValue: 'prod',    // ❌ PRODUCTION!
            name: 'Environment'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'],
            name: 'Terraform_Action'
        )])
])

// Jenkins Execute:
// Terraform_Action = 'destroy'     // ❌ DELETE ALL
// Environment = 'prod'              // ❌ PRODUCTION
```

**Why DANGEROUS:**

- ❌ ❌ ❌ Entire EKS cluster DELETED
- ❌ ❌ ❌ All applications STOPPED
- ❌ ❌ ❌ Data LOST (if using EBS volumes)
- ❌ ❌ ❌ NO RECOVERY without backup

**Rejection Comment:**

```
❌ REJECTED: CRITICAL - Destroy on production detected!
🚨 NEVER approve destroy action on production:
- This will delete all infrastructure
- All applications will stop
- Data loss likely
- No automatic recovery

Use only on 'dev' environment for testing.
```

---

### ❌ Example C: Hardcoded Credentials (DANGEROUS)

```groovy
// Jenkinsfile ❌ DO NOT MERGE

stage('Deploy') {
  steps {
    withAWS(
+     credentials: 'AKIAIOSFODNN7EXAMPLE:wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
      region: 'us-east-1'
    ) {
      sh 'terraform apply...'
    }
  }
}
```

**Why DANGEROUS:**

- ❌ AWS secret keys exposed in code
- ❌ GitHub will detect and invalidate key (but already public)
- ❌ Anyone with access can use AWS account
- ❌ Security breach / account takeover risk

**Rejection Comment:**

```
❌ REJECTED: SECURITY BREACH - Credentials exposed!
🚨 CREDENTIALS LEAKED:
- AWS keys hardcoded in Jenkinsfile
- This is visible in GitHub history
- Keys must be rotated immediately
- Never commit credentials - use Jenkins Secrets
- See Jenkins credentials management docs
```

---

### ❌ Example D: Deleting IAM Role Permissions (DANGEROUS)

```hcl
# infra/module/iam.tf ❌ DO NOT MERGE

resource "aws_iam_role_policy" "eks_cluster_policy" {
  name = "eks-cluster-policy"
  role = aws_iam_role.eks_cluster_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
-     {
-       Effect = "Allow"
-       Action = [
-         "ec2:DescribeInstances",
-         "ec2:DescribeSecurityGroups"
-       ]
-       Resource = "*"
-     }
    ]
  })
}
```

**Why DANGEROUS:**

- ❌ EKS cluster loses permission to manage EC2 instances
- ❌ Cannot add/remove/manage nodes
- ❌ Cluster becomes stuck and unmanageable
- ❌ Requires AWS support to fix

**Rejection Comment:**

```
❌ REJECTED: IAM policy broken
- EKS permissions removed
- Cluster cannot manage node groups
- Will cause cluster malfunction
- Revert this change immediately
```

---

### ❌ Example E: Deleting Network Subnets (DANGEROUS)

```hcl
# infra/module/vpc.tf ❌ DO NOT MERGE

module "eks" {
  source = "../module"

  pub_cidr_block = [
-   "10.16.0.0/20",
    "10.16.16.0/20",
    "10.16.32.0/20"
  ]
}
```

**Why DANGEROUS:**

- ❌ One subnet removed from EKS cluster network
- ❌ Pods in deleted subnet lose connectivity
- ❌ Cluster networking becomes unstable
- ❌ Services may fail intermittently

**Rejection Comment:**

```
❌ REJECTED: Network configuration changed
- Public subnet removed from VPC configuration
- This will break cluster networking
- Pods will lose connectivity
- Infrastructure team must review
```

---

## 📋 Quick Approval/Rejection Checklist

### ✅ SAFE TO APPROVE - Check boxes before approving:

- [ ] Only modifying `helm/charts/values-*.yaml` (image tag, replicas, resources)
- [ ] Only modifying template env vars and non-critical settings
- [ ] Only running `terraform plan` (not apply/destroy)
- [ ] No changes to `backend.tf` or `infra/module/`
- [ ] No secrets/credentials added
- [ ] Environment is 'dev' or 'staging' (not prod destroy)
- [ ] PR description explains the change
- [ ] Tests pass in CI pipeline
- [ ] Change is reversible

### ❌ REQUEST CHANGES - Reject if any of:

- [ ] `backend.tf` or `backend.tf` files modified
- [ ] Any AWS credentials or API keys visible
- [ ] `terraform destroy` on production environment
- [ ] IAM roles/permissions modified
- [ ] VPC/Network configuration changed
- [ ] EKS cluster critical config changed
- [ ] Kubernetes secret modifications
- [ ] No test results / CI failed
- [ ] Unable to rollback changes
- [ ] No documentation of change purpose

---

**Safety Boundary Template Last Updated:** May 14, 2026
