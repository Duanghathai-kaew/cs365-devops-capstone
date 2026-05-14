# 🔒 Safety Boundary for Peer Review

## CS365 DevOps Capstone - Terraform S3 Backend Implementation

---

## ✅ SAFE CHANGES (สามารถเปลี่ยนได้)

### 1. **Helm Values Configuration**

**File:** `helm/charts/values-*.yaml`

#### ✅ สามารถเปลี่ยนได้อย่างปลอดภัย:

```yaml
# 1. Image Tags (อัปเดต application version)
image:
  tag: new-version # ✅ เปลี่ยน image tag ได้

# 2. Replica Counts (ปรับจำนวน pod instances)
replicaCount: 3 # ✅ เพิ่ม/ลด replica count ได้
backendReplicaCount: 5 # ✅ ปรับจำนวน backend instance ได้

# 3. Resource Requests/Limits
resources:
  requests:
    memory: "256Mi" # ✅ ปรับ memory request ได้
    cpu: "500m" # ✅ ปรับ CPU request ได้
  limits:
    memory: "512Mi" # ✅ ปรับ memory limit ได้
    cpu: "1" # ✅ ปรับ CPU limit ได้

# 4. Image Pull Policy
imagePullPolicy: Always # ✅ เปลี่ยน pull policy ได้

# 5. Environment Variables (ใน template ถ้ามี)
env:
  LOG_LEVEL: info # ✅ เปลี่ยน env value ได้
  DEBUG: "false" # ✅ ปรับ feature flags ได้
```

**Impact:** ❓ Low - ถูก apply via `helm upgrade` ไม่ destructive

---

### 2. **Test Changes**

#### ✅ สามารถ trigger test ได้:

```bash
# Jenkins pipeline test
- Run "plan" action ก่อนเสมอ
- Trigger test stage ใน pipeline
- Run unit tests ใน app/ และ backend/ ได้

# Test targets:
- app/main_test.go         # ✅ เรียกใช้ได้
- Integration tests        # ✅ Run ได้
- Dry-run terraform plan   # ✅ ลองดูผลได้ก่อน apply
```

**Impact:** ❓ Very Low - ไม่มีผลต่อ production resources

---

### 3. **Helm Template Adjustments (Minor)**

#### ✅ เปลี่ยนได้อย่างปลอดภัย:

```yaml
# File: helm/charts/templates/deployment-*.yaml

# - Container port
containerPort: 8080 # ✅ เปลี่ยนได้ (ถ้า app support)

# - Image pull secrets (ถ้า config ใหม่)
imagePullSecrets:
  - name: new-secret # ✅ เปลี่ยนได้

# - Labels และ annotations
labels:
  team: devops # ✅ เปลี่ยนได้
annotations:
  key: value # ✅ เพิ่มได้
```

**Impact:** ❓ Low - ไม่กระทบโครงสร้างหลัก

---

### 4. **Development Environment Variables**

#### ✅ เปลี่ยนได้:

```hcl
# infra/eks/dev.tfvars
cluster_version = "1.28"     # ✅ เปลี่ยน cluster version ได้ (dev)
desired_capacity_on_demand = 2 # ✅ ปรับ node capacity ได้ (dev)
```

**Impact:** ⚠️ Medium - มีผล แต่ dev environment ยังทำได้

---

## ❌ DANGEROUS CHANGES (ห้ามเปลี่ยน)

### 1. **Terraform Backend State** ⛔

**File:** `infra/eks/backend.tf`

```hcl
backend "s3" {
  bucket         = "cs365-terraform-state-kaew"  # ❌ ห้าม
  key            = "eks/terraform.tfstate"       # ❌ ห้าม
  region         = "us-east-1"                   # ❌ ห้าม
  dynamodb_table = "terraform-lock"              # ❌ ห้าม
  encrypt        = true                          # ❌ ห้าม
}
```

**Why:**

- ❌ ลบ/ย้าย S3 bucket → **cluster state หาย**
- ❌ เปลี่ยน key path → **terraform ไม่รู้ state ของ current infrastructure**
- ❌ ลบ DynamoDB lock table → **concurrent apply จะพัง**
- ❌ ปิด encryption → **sensitive data expose**

**Risk:** 🔴 CRITICAL - ระบบ destroy เอง, state lock ไม่ทำงาน

---

### 2. **AWS Credentials & Secrets** ⛔

**Files:** Jenkinsfile, IAM roles/policies

```groovy
withAWS(credentials: 'aws-creds', region: 'us-east-1') {  // ❌ ห้าม
  // ❌ ห้ามเปลี่ยน credentials reference
  // ❌ ห้ามเพิ่ม hardcoded secrets
  // ❌ ห้ามลบ IAM role policies
}
```

**Why:**

- ❌ Hardcoded credentials → **leaked to GitHub**
- ❌ ลบ IAM permission → **terraform commands fail**
- ❌ เปลี่ยน credential ที่ Jenkins store → **authentication fail**

**Risk:** 🔴 CRITICAL - AWS account compromise, pipeline cannot run

---

### 3. **EKS Cluster Critical Configuration** ⛔

**Files:** `infra/eks/main.tf`, `infra/module/*.tf`

```hcl
# ❌ ห้ามเปลี่ยน infrastructure-level settings:

# VPC Configuration
cidr_block = "10.16.0.0/16"           # ❌ ห้าม
vpc_name   = "ap-medium-vpc"          # ❌ ห้าม

# EKS Cluster Settings
cluster_name = "eks-cluster"          # ❌ ห้าม
cluster_version = "1.28"              # ❌ ห้าม (prod)

# IAM Role Configuration
is_eks_role_enabled = true            # ❌ ห้าม
is_eks_cluster_enabled = true         # ❌ ห้าม

# Network Configuration
pub_cidr_block = ["10.16.0.0/20", ...] # ❌ ห้าม
pri_availability_zone = ["us-east-1a", ...] # ❌ ห้าม

# Node Group Settings (Production)
desired_capacity_on_demand = 3        # ❌ ห้าม (prod)
max_capacity_on_demand = 5            # ❌ ห้าม (prod)
```

**Why:**

- ❌ เปลี่ยน VPC CIDR → **all pods/nodes disconnected**
- ❌ ลบ/ปิด IAM role → **EKS cannot control EC2**
- ❌ ลบ subnets → **nodes cannot communicate**
- ❌ ลบ security groups → **network isolated**

**Risk:** 🔴 CRITICAL - Cluster becomes non-functional

---

### 4. **Terraform Destroy Action (Production)** ⛔

**File:** `infra/Jenkinsfile`

```groovy
# ❌ ห้าม trigger "destroy" บน production:
choice(
  choices: ['plan', 'apply', 'destroy'],  # ❌ ห้าม select destroy (prod)
  name: 'Terraform_Action'
)
```

**Why:**

- ❌ terraform destroy → **EKS cluster ลบทั้งหมด**
- ❌ ❌ ❌ **ALL applications stop**
- ❌ ❌ ❌ **Data loss** (ถ้า PVC/database attached)
- ❌ ❌ ❌ **Cannot recovery without backup**

**Risk:** 🔴 🔴 CRITICAL - Total infrastructure destruction

---

### 5. **Application Secrets & Image Registries** ⛔

```yaml
# ❌ ห้าม:
imagePullSecrets:
  - name: registry-creds # ❌ ห้ามลบ

securityContext:
  capabilities:
    drop:
      - ALL # ❌ ห้ามเพิ่ม unprivileged capabilities
```

**Why:**

- ❌ ลบ image pull secret → **containers cannot pull images**
- ❌ เปลี่ยน secret content → **authentication fail**
- ❌ เพิ่ม privileged capabilities → **security vulnerability**

**Risk:** 🔴 CRITICAL - Containers fail, security risk

---

## 📊 Summary Table

| Component                | Change Type                 | Safe?    | Risk Level  | Notes                  |
| ------------------------ | --------------------------- | -------- | ----------- | ---------------------- |
| **Image Tags**           | `helm/charts/values-*.yaml` | ✅ YES   | 🟢 Low      | Rollback easy via Helm |
| **Replica Count**        | `helm/charts/values-*.yaml` | ✅ YES   | 🟢 Low      | HPA can override       |
| **Resource Limits**      | `helm/charts/templates/`    | ✅ YES   | 🟡 Medium   | Monitor after change   |
| **Environment Vars**     | `helm/charts/templates/`    | ✅ YES   | 🟢 Low      | App restart needed     |
| **Test/Plan Actions**    | Jenkins pipeline            | ✅ YES   | 🟢 None     | No resources affected  |
| **Dev tfvars**           | `infra/eks/dev.tfvars`      | ✅ MAYBE | 🟡 Medium   | Avoid on prod values   |
| ⛔ S3 Backend Config     | `infra/eks/backend.tf`      | ❌ NO    | 🔴 CRITICAL | Do NOT touch           |
| ⛔ AWS Credentials       | Jenkinsfile/Jenkins Store   | ❌ NO    | 🔴 CRITICAL | Do NOT touch           |
| ⛔ VPC/Network Config    | `infra/module/*.tf`         | ❌ NO    | 🔴 CRITICAL | Do NOT touch           |
| ⛔ EKS Cluster Config    | `infra/eks/main.tf`         | ❌ NO    | 🔴 CRITICAL | Do NOT touch           |
| ⛔ Destroy Action (Prod) | Jenkinsfile parameter       | ❌ NO    | 🔴 CRITICAL | Never use on prod      |
| ⛔ Secrets/Pull Creds    | Kubernetes secrets          | ❌ NO    | 🔴 CRITICAL | Do NOT touch           |

---

## 🎯 Peer Review Guidelines

### When reviewing PR with this Safety Boundary:

**✅ APPROVE if changes are in:**

- [ ] Image tags updated
- [ ] Replica counts adjusted
- [ ] Resource requests/limits modified
- [ ] Environment variables changed
- [ ] Test commands executed
- [ ] Development tfvars only

**❌ REQUEST CHANGES if touches:**

- [ ] backend.tf
- [ ] AWS credentials
- [ ] VPC/EKS network config
- [ ] IAM role definitions
- [ ] DynamoDB lock table
- [ ] Terraform destroy on production
- [ ] Kubernetes secrets
- [ ] Security context privileges

---

## 🚀 Testing Strategy (Safe)

```bash
# Step 1: Plan first (no changes applied)
jenkins_action=plan       # ✅ Safe - preview only
jenkins_env=dev          # ✅ Safe - dev environment

# Step 2: Review plan output
# ... inspect changes ...

# Step 3: If OK, apply
jenkins_action=apply      # ✅ Safe if reviewed
jenkins_env=dev          # ✅ Safe - dev environment

# Step 4: Test applications
helm upgrade go-portfolio ./helm/charts \
  -f helm/charts/values-dev.yaml  # ✅ Safe - reversible

# ❌ NEVER do:
jenkins_action=destroy   # ❌ Production cluster will be gone
jenkins_env=prod         # ❌ Production data loss
```

---

## 📝 Checklist for Approvers

- [ ] PR does NOT modify `backend.tf`
- [ ] PR does NOT contain hardcoded secrets or credentials
- [ ] PR does NOT modify `infra/module/` (unless reviewed with infrastructure team)
- [ ] PR does NOT select "destroy" for production environments
- [ ] PR only modifies safe values (image tags, replicas, resources)
- [ ] All test stages pass successfully
- [ ] Changes are documented in PR description

---

**Last Updated:** May 14, 2026  
**Project:** CS365 DevOps Capstone  
**Current PR:** Feat/terraform-s3-backend
