# Product Requirements Document (PRD)
**Project:** RUSVPN Global Exit Nodes

## 1. Informasi Proyek
* **Nama Proyek:** RUSVPN (Remote User Secure VPN)
* **Pemohon / PM:** Tim Manajemen
* **Pelaksana (PIC):** DevOps / Infrastructure Engineer
* **Platform Eksekusi:** Antigravity
* **Status:** Draft / Ready for Review

## 2. Latar Belakang & Objektif
Proyek ini bertujuan untuk membangun infrastruktur VPN (Exit Node) mandiri yang tersebar di 5 benua berbeda menggunakan layanan Amazon Web Services (AWS). Infrastruktur ini diperlukan agar pengguna dari kantor Jakarta dapat mengakses internet atau layanan pihak ketiga menggunakan IP publik dari negara/benua yang dipilih.

**Objektif Utama:** Menyediakan 5 server VPN yang independen (tidak saling terhubung via VPC Peering/Mesh) di 5 benua, yang dapat diakses secara stabil, aman, dan tersentralisasi dari Jakarta.

## 3. Ruang Lingkup (Scope)
### In-Scope:
* Pembuatan script *Infrastructure as Code (IaC)* menggunakan **Terraform**.
* Provisioning 5 instance AWS EC2 (`t3.micro`) di 5 region AWS berbeda.
* Konfigurasi Security Group untuk SSH (TCP 22) dan VPN port (UDP 1194, atau sesuai kebutuhan OpenVPN).
* Alokasi *Elastic IP* (EIP) pada tiap EC2 untuk memastikan IP publik bersifat statis.
* Persiapan server (misalnya instalasi Docker & Docker Compose) via *EC2 User Data* agar siap di-deploy service OpenVPN.

### Out-of-Scope:
* Interkoneksi internal antar VPN node (VPC Peering / Transit Gateway tidak dikonfigurasi).
* Integrasi otentikasi VPN dengan layanan direktori eksternal (LDAP/Active Directory/SSO).

## 4. Spesifikasi Teknis Infrastruktur
Pemetaan region AWS berikut digunakan untuk mewakili 5 benua secara optimal:

| Benua | AWS Region | Instance Type | OS / AMI |
| :--- | :--- | :--- | :--- |
| Asia | `ap-southeast-1` (Singapura) | t3.micro | Ubuntu 22.04 LTS |
| Amerika Utara | `us-east-1` (N. Virginia) | t3.micro | Ubuntu 22.04 LTS |
| Eropa | `eu-central-1` (Frankfurt) | t3.micro | Ubuntu 22.04 LTS |
| Amerika Selatan | `sa-east-1` (São Paulo) | t3.micro | Ubuntu 22.04 LTS |
| Australia | `ap-southeast-2` (Sydney) | t3.micro | Ubuntu 22.04 LTS |

## 5. Keamanan & Akses (Security Requirements)
* **Akses SSH (Port 22 TCP):** Terbuka sementara (`0.0.0.0/0`) karena belum ada IP spesifik (dapat dibatasi kemudian via variabel `jakarta_office_ip`).
* **Akses VPN (Port 1194 UDP - OpenVPN):** Dibuka untuk koneksi klien (`0.0.0.0/0`).
* **Otentikasi:** SSH Key Pair dibuat secara otomatis dan dinamis oleh Terraform (tidak perlu *Key Pair* bawaan AWS). Kunci *private* akan diekspor via *output* Terraform. Otentikasi VPN dikelola di level aplikasi.

## 6. Rencana Eksekusi (Milestones)
1. **Fase 1: Persiapan Script (Terraform)** - Penulisan `main.tf` dengan *provider aliases* (untuk multi-region) dan penyusunan skrip bash persiapan instance (Docker/Dependencies User Data).
2. **Fase 2: Deployment via Antigravity** - Eksekusi pipeline `terraform plan` dan `terraform apply` di lingkungan Antigravity.
3. **Fase 3: Testing & Validasi** - Pembuatan konfigurasi *client*, lalu pengujian koneksi dari Jakarta ke 5 node secara bergantian. Pengecekan perubahan IP publik (misal: via *whatismyip.com*).
4. **Fase 4: Handover** - Penyerahan kredensial/file konfigurasi (`.conf`) VPN kepada Product Manager (PM) / Atasan.

## 7. Struktur Direktori Proyek (Terraform)
Sesuai dengan standar best-practice, implementasi ini menggunakan struktur direktori berikut:

```text
terraform/
├── environments/
│   ├── prod/                   # Entrypoint utama untuk deployment ke 5 region
│   │   ├── main.tf             # Definisi 5 AWS provider & pemanggilan module vpc/ec2
│   │   ├── variables.tf        # Deklarasi variabel
│   │   ├── terraform.tfvars    # Nilai variabel (contoh: IP Jakarta)
│   │   └── outputs.tf          # Mengekspor 5 Public IP (EIP)
│   └── global/                 # (Opsional/Future) Tempat setup S3 Backend state
└── modules/
    ├── vpc/                    # Modul VPC, Subnet, IGW, Route Table mandiri
    └── ec2/                    # Modul EC2, Security Group, EIP, dan User Data (Docker)
```
