# Go Fiber Example

A simple REST API built with Go using the Fiber web framework, GORM for ORM, and PostgreSQL as the database. The project is containerized with Docker and can be deployed to Kubernetes.

## Ringkasan

Aplikasi ini menyediakan endpoint CRUD untuk entitas `Category`.

Tech stack:
- Bahasa: Go (go 1.25)
- Web framework: Fiber (github.com/gofiber/fiber/v2)
- ORM: GORM (gorm.io/gorm) dengan driver Postgres (gorm.io/driver/postgres)
- Database: PostgreSQL
- Container: Docker

## Struktur proyek singkat

- `main.go` - entrypoint (memanggil koneksi database, auto-migrate, dan routes)
- `config/` - koneksi database
- `controllers/` - handler endpoint
- `entities/` - model GORM (Category)
- `routes/` - definisi route API
- `Dockerfile`, `docker-compose.yml` - container & compose

> **Catatan Kubernetes**: Manifest Kubernetes (deployment, service, configmap, dll) disimpan di repository terpisah untuk memisahkan keperluan infrastruktur dari kode aplikasi. Silakan merujuk ke repository `go-fiber-example-k8s` untuk konfigurasi dan instruksi deployment ke Kubernetes.

## Environment variables

Aplikasi membaca konfigurasi database dari environment variables atau file `.env` (jika `godotenv` menemukan file tersebut).

- DB_HOST (contoh: `localhost` atau `postgres` ketika menggunakan Docker Compose)
- DB_PORT (default `5432`)
- DB_USER
- DB_PASSWORD
- DB_NAME
- DB_SSLMODE (opsional, default `disable`)

Contoh `.env` minimal:

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=exampledb
DB_SSLMODE=disable

> Perhatikan: `main.go` sudah memanggil `GormDB.AutoMigrate(&entities.Category{})`, jadi tabel akan otomatis dibuat saat aplikasi dijalankan.

## Endpoint API

Base path: `http://localhost:3000`

- GET /api/categories  — daftar semua kategori
- GET /api/categories/:id — ambil satu kategori
- POST /api/categories — buat kategori (body JSON: {"name":"Nama"})
- PUT /api/categories/:id — update kategori (body JSON: {"name":"Nama baru"})
- DELETE /api/categories/:id — hapus kategori

Contoh request (PowerShell melalui `Invoke-RestMethod`):

# Create
Invoke-RestMethod -Method Post -Uri 'http://localhost:3000/api/categories' -ContentType 'application/json' -Body ('{"name":"Buku"}')

# Get all
Invoke-RestMethod -Method Get -Uri 'http://localhost:3000/api/categories'

# Get by id
Invoke-RestMethod -Method Get -Uri 'http://localhost:3000/api/categories/1'

# Update
Invoke-RestMethod -Method Put -Uri 'http://localhost:3000/api/categories/1' -ContentType 'application/json' -Body ('{"name":"Majalah"}')

# Delete
Invoke-RestMethod -Method Delete -Uri 'http://localhost:3000/api/categories/1'

> Jika menggunakan `curl` pada Windows, hati-hati dengan tanda kutip dan escaping.

## Menjalankan secara lokal

Pilihan A — jalankan PostgreSQL dengan Docker Compose lalu jalankan aplikasi secara lokal:

1. Copy atau buat file `.env` di root project (isi seperti di atas).
2. Jalankan PostgreSQL dengan Docker Compose (PowerShell):

docker-compose up -d

3. Jalankan aplikasi Go (PowerShell):

$env:DB_HOST = "localhost"; $env:DB_PORT = "5432"; $env:DB_USER = "postgres"; $env:DB_PASSWORD = "password"; $env:DB_NAME = "exampledb"; go run .

Aplikasi akan mendengarkan pada port 3000.

Pilihan B — build Docker image dan jalankan container:

# Build image
docker build -t go-fiber-example:local .

# Jalankan (pastikan postgres tersedia, mis. via docker-compose)
docker run --rm -p 3000:3000 --env-file .env --name go-fiber-example go-fiber-example:local

Pilihan C — jalankan semuanya dengan Docker Compose (tambahan service aplikasi perlu ditambahkan jika belum ada):

> File `docker-compose.yml` saat ini hanya berisi service `postgres`. Jika ingin menjalankan aplikasi sebagai service di docker-compose, tambahkan service untuk aplikasi yang membangun image dari `Dockerfile` dan meng-link ke `postgres`.

Contoh snippet (tambahkan ke `docker-compose.yml`):

  app:
    build: .
    image: go-fiber-example:local
    ports:
      - "3000:3000"
    env_file:
      - .env
    depends_on:
      - postgres

## Deployment ke Kubernetes

Untuk deployment ke Kubernetes (termasuk Minikube), silakan merujuk ke repository terpisah:

- Repository: [kubernetes-fiber](https://github.com/R4P8/kubernetes-fiber/tree/main)
- Berisi: manifest Kubernetes lengkap (deployment, service, configmap, secret)
- Instruksi: cara build image, push ke registry, dan deploy ke cluster

Pemisahan ini dilakukan untuk:
1. Memisahkan keperluan infrastruktur dari kode aplikasi
2. Memungkinkan tim infra/DevOps mengelola konfigurasi deployment secara terpisah
3. Mendukung multiple environment dengan konfigurasi berbeda

## Catatan khusus dan troubleshooting

- Koneksi DB gagal: pastikan variabel environment benar dan Postgres sudah running. Jika menggunakan Docker Compose, service postgres biasanya dapat diakses via host `localhost` dari host machine.
- Jika menggunakan container-to-container (di docker network), gunakan `DB_HOST=postgres` sesuai nama service di `docker-compose`.
- Jika menggunakan Minikube, bangun image di Minikube atau push ke registry yang dapat diakses.
- Untuk melihat log aplikasi:

docker logs -f go-fiber-example
# atau (jika menjalankan via kubernetes)
kubectl logs -f deploy/go-fiber

## Contoh singkat pengujian

1. Jalankan DB + app seperti di "Menjalankan secara lokal".
2. Buat kategori:
Invoke-RestMethod -Method Post -Uri 'http://localhost:3000/api/categories' -ContentType 'application/json' -Body ('{"name":"Elektronik"}')
3. Pastikan GET /api/categories mengembalikan data.

## Lanjutan (opsional)

- Tambahkan migrasi versi (mis. golang-migrate) untuk skenario produksi.
- Tambahkan healthcheck endpoint.
- Tambahkan unit/integration tests.

---

Dokumentasi ini dibuat otomatis berdasarkan isi repo. Jika ada file k8s yang belum dibuat (deployment/service/secret), silakan tambahkan dan sesuaikan image serta environment variables sebelum menerapkannya ke cluster Minikube.
