# RUSVPN Global Exit Nodes - Terraform Infrastructure

Repositori ini berisi *Infrastructure as Code* (IaC) menggunakan Terraform untuk melakukan provisioning 5 server VPN mandiri di 5 region AWS yang berbeda (mewakili 5 benua). Server ini dipersiapkan menggunakan Docker sehingga tim dapat dengan mudah men-deploy OpenVPN dari repositori `openvpn-service`.

## Struktur Direktori
Proyek ini mengikuti standar best-practice Terraform:
- **`environments/`**: Entrypoint tempat Anda menjalankan perintah Terraform (`init`, `plan`, `apply`). Pengaturan spesifik *environment* seperti `prod` atau pengaturan `global` (misal S3 Backend) ditempatkan di sini.
- **`modules/`**: Tempat logika infrastruktur inti (reusable). Proyek ini memiliki modul `vpc` (untuk networking) dan `ec2` (untuk komputasi & security group).

## Prasyarat
- [Terraform](https://www.terraform.io/downloads.html) v1.0+ terinstal.
- AWS CLI terinstal dan sudah dikonfigurasi (`aws configure`) dengan kredensial yang memadai untuk membuat VPC dan EC2.
- IP Publik Kantor Jakarta (untuk kebutuhan whitelisting SSH di port 22).

## Cara Menjalankan

1. Pindah ke direktori environment `prod`:
   ```bash
   cd environments/prod
   ```

2. Persiapkan nilai variabel di file `terraform.tfvars`:
   ```bash
   # Buat atau sesuaikan isi file terraform.tfvars
   # Contoh isi:
   # jakarta_office_ip = "203.0.113.50/32"
   # key_name          = "my-aws-key"
   ```

3. Inisialisasi Terraform (mengunduh provider aws):
   ```bash
   terraform init
   ```

4. Lihat rencana perubahan (apa saja yang akan dibuat):
   ```bash
   terraform plan
   ```

5. Aplikasikan dan bangun infrastruktur:
   ```bash
   terraform apply
   ```

## Dokumentasi Terkait
- [Product Requirements Document (PRD)](docs/PRD.md)
- [Standar & Referensi Terraform](docs/reference.md)
