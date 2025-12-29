# Sistem Deploy Internal

Sistem deploy otomatis untuk aplikasi internal tim menggunakan Docker dan Traefik.

## Tujuan

Mempermudah deployment aplikasi internal ke server dengan satu perintah. Setiap aplikasi otomatis mendapat subdomain `https://PROJECT_NAME.apps.example.com`.

## Struktur Repo yang Wajib Ada

Setiap repo project HARUS memiliki file-file berikut:

```
project/
├── Dockerfile          # File Docker image
├── package.json        # Dependencies Node.js
├── package-lock.json   # Lock file npm
└── .env.example        # Template environment variables
```

## Cara Deploy Aplikasi

Jalankan script deploy.sh di server dengan format:

```bash
./deploy.sh nama_project https://github.com/username/repo.git
```

Contoh:

```bash
./deploy.sh dashboard-internal https://github.com/company/dashboard.git
./deploy.sh api-users https://github.com/company/api-users.git
```

Aplikasi akan otomatis tersedia di:
- https://dashboard-internal.apps.example.com
- https://api-users.apps.example.com

## Cara Update / Redeploy Aplikasi

Untuk update aplikasi yang sudah berjalan, jalankan ulang perintah deploy yang sama:

```bash
./deploy.sh dashboard-internal https://github.com/company/dashboard.git
```

Script akan otomatis:
1. Hapus folder lama
2. Clone versi terbaru dari repo
3. Stop dan hapus container lama
4. Build image baru
5. Jalankan container baru

## Cara Stop Aplikasi

Untuk menghentikan aplikasi yang sedang berjalan:

```bash
docker stop nama_project
```

Contoh:

```bash
docker stop dashboard-internal
```

## Catatan Penting

1. **Port Aplikasi**: Aplikasi HARUS berjalan di port 3000
2. **Environment Variable**: Aplikasi harus membaca port dari ENV `PORT`
3. **package.json**: Script `start` harus ada dan menjalankan aplikasi
4. **Dockerfile**: Wajib ada di root repo

Contoh dalam kode Node.js:

```javascript
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## Troubleshooting

**Aplikasi tidak bisa diakses:**
- Cek container berjalan: `docker ps | grep nama_project`
- Cek log container: `docker logs nama_project`

**Build gagal:**
- Pastikan Dockerfile ada di root repo
- Pastikan package.json dan package-lock.json ada

**Port error:**
- Pastikan aplikasi membaca dari `process.env.PORT`
- Pastikan EXPOSE 3000 ada di Dockerfile
