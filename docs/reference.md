# Panduan Struktur Direktori (Terraform & Ansible)

Dokumen ini adalah acuan standar (PRD Singkat) untuk penulisan dan pengorganisasian proyek-proyek Terraform dan Ansible ke depannya agar konsisten, modular, dan terukur (scalable).

---

## BAGIAN 1: TERRAFORM (Provisioning)

### 1. Prinsip Utama
- **Modularitas**: Pisahkan resource cloud ke dalam modul-modul independen berdasarkan fungsi atau layanan (misal: VPC, EKS, EC2, IAM).
- **Isolasi Environment**: Pisahkan state dan konfigurasi (variabel) secara fisik antar environment (`dev`, `staging`, `prod`) menggunakan struktur direktori. Hal ini meminimalisir risiko kesalahan eksekusi dibanding hanya mengandalkan *Terraform Workspaces*.
- **Reusability**: `environments` (entrypoint pemanggil) hanya memanggil `modules` dengan memberikan nilai variabel yang berbeda. Logika utama pembuatan resource Terraform terpusat di dalam `modules`.

### 2. Standar Struktur Direktori Terraform
Struktur dasar dari setiap repositori/proyek Terraform harus mengikuti pola hierarki berikut:

```text
nama-proyek-terraform/
├── environments/               # Tempat entrypoint dijalankan (terraform init, plan, apply)
│   ├── dev/                    # Environment Development
│   │   ├── main.tf             # Memanggil modul-modul dengan input variabel spesifik dev
│   │   ├── variables.tf        # Deklarasi variabel untuk dev
│   │   ├── terraform.tfvars    # (Opsional) File berisi nilai-nilai variabel dev
│   │   ├── backend.tf          # Konfigurasi remote state (S3 bucket key: env/dev/terraform.tfstate)
│   │   └── outputs.tf          # Output informasi dari environment dev (misal: URL, IP)
│   ├── prod/                   # Environment Production
│   │   ├── main.tf             # Memanggil modul-modul dengan input variabel spesifik prod
│   │   ├── variables.tf
│   │   ├── backend.tf          # S3 State terpisah dan aman untuk prod
│   │   └── outputs.tf
│   └── global/                 # (Opsional) Resource yang tidak terikat environment spesifik
│       ├── main.tf             # Misal: IAM Users, Route53 Root Zone, S3 Bucket untuk State Backend
│       └── backend.tf
│
└── modules/                    # Tempat logika Terraform (Reusable Infrastructure Code)
    ├── vpc/                    # Modul khusus VPC & Networking
    │   ├── main.tf             # Logika pembentukan resource (VPC, Subnet, IGW, NAT)
    │   ├── variables.tf        # Input parameter yang dibutuhkan modul ini
    │   └── outputs.tf          # Output nilai penting (misal: vpc_id, subnet_ids) untuk modul lain
    ├── eks/                    # Modul EKS dan Node Groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/           # Modul spesifik untuk EC2 Database (Scylla, ClickHouse, dll)
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ...                     # Modul-modul lainnya (ALB, IAM, Security, Storage, dll)
```

### 3. Aturan Penulisan (Best Practices)

#### a. Modul (`modules/`)
- Modul **tidak boleh** memiliki provider config keras (hardcoded). Provider harus diset dan diwariskan dari blok pemanggil di `environments/`.
- Jika sebuah modul memiliki terlalu banyak resource (misal EKS), pecah `main.tf` menjadi file-file yang lebih deskriptif di dalam folder modul tersebut (contoh: `eks-cluster.tf`, `node-groups.tf`, `iam.tf`).
- Selalu sediakan `outputs.tf` untuk mengekspos ID, ARN, atau endpoint resource yang mungkin dibutuhkan sebagai input oleh modul lain (Dependencies Passing).

#### b. Environment (`environments/`)
- Setiap environment wajib memiliki *Remote State Backend* (contoh: Amazon S3) dan mekanisme *State Locking* (contoh: DynamoDB) untuk mencegah *concurrent modification*.
- File `main.tf` di level environment sebisa mungkin hanya berisi kumpulan blok `module {}` yang mereferensikan direktori di `modules/`. Hindari mendefinisikan `resource` murni (seperti `aws_s3_bucket`) di sini kecuali terpaksa.
- **Scaling & Toleransi**: Perbedaan arsitektur (contoh: `prod` pakai 3 AZ dan instance besar, `dev` hanya 1 AZ) murni dikontrol melalui variabel yang dipasok (`count`, `instance_type`, dll), bukan dengan menulis ulang modul.

#### c. Penamaan Resource (Naming Convention)
- Gunakan tag standar di setiap resource minimal mencakup: `Environment`, `Project`, dan `ManagedBy = "Terraform"`.
- Gunakan konvensi penamaan yang prediktif, contoh format: `<project>-<env>-<service/role>`. (Contoh: `airpay-prod-vpc`, `airpay-dev-eks-cluster`).
- Konsisten menggunakan *kebab-case* (menggunakan strip `-`) atau *snake_case* (menggunakan underscore `_`) untuk penamaan file dan nama internal terraform. Standar komunitas umumnya menggunakan *snake_case* untuk referensi lokal Terraform (`resource "aws_vpc" "main_network"`), namun nama label/tag aktual di Cloud menggunakan *kebab-case*.

---

## BAGIAN 2: ANSIBLE (Configuration Management)

### 1. Prinsip Utama
- **Role-Based Categorization**: Kelompokkan *Roles* berdasarkan kategori layanan (misal: `databases/scylladb`, `cache/redis`) agar repositori rapi dan terstruktur.
- **Tagging Strategy**: Wajib menyertakan `--tags` pada setiap eksekusi role di playbook agar kita bisa menginstal layanan spesifik (parsial) tanpa mengeksekusi seluruh server.
- **Inventory & Variabel Terpisah**: Pisahkan daftar *host* dan *group_vars* antara environment dev dan prod.

### 2. Standar Struktur Direktori Ansible
```text
ansible-project/
├── inventories/
│   ├── dev/
│   │   ├── hosts.ini           # Daftar IP/Host untuk DEV
│   │   └── group_vars/all.yml  # Variabel global untuk DEV
│   └── prod/
│       ├── hosts.ini           # Daftar IP/Host untuk PROD
│       └── group_vars/all.yml  # Variabel global untuk PROD
├── playbooks/
│   ├── setup_dev.yml           # Master playbook DEV (memanggil roles dengan tags)
│   └── setup_prod.yml          # Master playbook PROD (memanggil roles dengan tags)
└── roles/
    ├── base/common/            # Role dasar (contoh: instal tool dasar, security)
    │   └── tasks/
    │       └── main.yml
    ├── databases/scylladb/     # Kategori Database: Role instalasi spesifik
    │   ├── tasks/
    │   │   └── main.yml        # Langkah-langkah instalasi dan konfigurasi
    │   ├── defaults/
    │   │   └── main.yml        # Definisi variabel default (misal: versi aplikasi, port)
    │   ├── templates/
    │   │   └── config.j2       # Template file konfigurasi (Jinja2)
    │   └── handlers/
    │       └── main.yml        # Mendefinisikan service restarts yang dipicu oleh task
    └── cache/redis/            # Kategori Cache: Role instalasi spesifik
        ├── tasks/
        ├── defaults/
        ├── templates/
        └── handlers/
```

### 3. Best Practices Ansible
- **Eksekusi Fleksibel**: Selalu gunakan tag saat running playbook. Contoh: `ansible-playbook -i inventories/prod/hosts.ini playbooks/setup_prod.yml --tags "scylladb"`.
- **Struktur Internal Role**: Gunakan standarisasi struktur folder dalam role secara konsisten (`tasks/`, `defaults/`, `templates/`, `handlers/`) seperti yang ditunjukkan pada contoh hierarki di atas.
- **Manajemen Kredensial**: Simpan variabel penting/rahasia di `group_vars` dan sangat direkomendasikan untuk mengenkripsinya menggunakan Ansible Vault.
