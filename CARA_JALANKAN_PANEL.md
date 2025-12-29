# Cara Menjalankan Deploy Panel

## 1. Jalankan Backend

Di terminal, jalankan:

```bash
cd /app/backend
python deploy_panel.py
```

Backend akan berjalan di: `http://localhost:8002`

## 2. Buka Web UI

Buka file HTML di browser:

```
/app/frontend/public/deploy.html
```

Atau buka langsung di browser:
```
file:///app/frontend/public/deploy.html
```

## 3. Cara Menggunakan

1. Masukkan **Project Name** (contoh: dashboard-internal)
2. Masukkan **GitHub Repository URL** (contoh: https://github.com/company/repo.git)
3. Klik tombol **Deploy Sekarang**
4. Tunggu proses selesai dan lihat log hasil deploy

## Endpoint API

**POST** `/deploy`

Request Body:
```json
{
  "project": "nama-project",
  "repo": "https://github.com/user/repo.git"
}
```

Response:
```json
{
  "success": true,
  "log": "=== STDOUT ===\n...\n=== STDERR ===\n...\n=== EXIT CODE ===\n0"
}
```

## Catatan

- Backend harus berjalan sebelum membuka web UI
- deploy.sh harus ada di `/app/deploy.sh`
- Timeout deploy maksimal 5 menit
- Log akan menampilkan stdout, stderr, dan exit code
