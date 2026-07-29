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
* Konfigurasi Security Group untuk SSH (TCP 22) dan VPN port (UDP).
* Alokasi *Elastic IP* (EIP) pada tiap EC2 untuk memastikan IP publik bersifat statis.
* Instalasi dan konfigurasi otomatis VPN Engine (rekomendasi: **WireGuard**) melalui *EC2 User Data*.

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
* **Akses SSH (Port 22 TCP):** Wajib dibatasi (*whitelisted*) hanya untuk *IP Public* Kantor Jakarta atau bastion host perusahaan.
* **Akses VPN (Port 51820 UDP - WireGuard):** Dibuka untuk koneksi klien (`0.0.0.0/0`) atau disesuaikan dengan kebijakan keamanan Antigravity.
* **Otentikasi:** Menggunakan SSH Key Pair standar perusahaan untuk akses server, dan *Public/Private Key pair* WireGuard untuk akses VPN.

## 6. Rencana Eksekusi (Milestones)
1. **Fase 1: Persiapan Script (Terraform)** - Penulisan `main.tf` dengan *provider aliases* (untuk multi-region) dan penyusunan skrip bash instalasi WireGuard (User Data).
2. **Fase 2: Deployment via Antigravity** - Eksekusi pipeline `terraform plan` dan `terraform apply` di lingkungan Antigravity.
3. **Fase 3: Testing & Validasi** - Pembuatan konfigurasi *client*, lalu pengujian koneksi dari Jakarta ke 5 node secara bergantian. Pengecekan perubahan IP publik (misal: via *whatismyip.com*).
4. **Fase 4: Handover** - Penyerahan kredensial/file konfigurasi (`.conf`) VPN kepada Product Manager (PM) / Atasan.
