# Aplikasi To-Do List (Flutter & SQLite)

Aplikasi mobile pencatat daftar tugas (**To-Do List**) yang dibangun menggunakan **Flutter** dan penyimpanan lokal terstruktur **SQLite** melalui *package* `sqflite`. Aplikasi ini menerapkan arsitektur pemisahan tanggung jawab (*Separation of Concerns*), pola desain *Singleton* untuk manajemen koneksi basis data, serta relasi antar-tabel (*Foreign Key*).

---

## Fitur Utama

1. **Operasi CRUD Lengkap:**
   - **Create:** Menambahkan tugas baru lengkap dengan judul, deskripsi, batas waktu (*deadline*), dan kategori.
   - **Read:** Menampilkan seluruh daftar tugas yang diurutkan dari waktu pembuatan terbaru.
   - **Update:** Mengubah detail tugas serta menandai status penyelesaian tugas secara langsung melalui *checkbox*.
   - **Delete:** Menghapus satu tugas tertentu dengan dialog konfirmasi, atau menghapus seluruh tugas yang sudah selesai sekaligus.
2. **Manajemen Batas Waktu (*Deadline*):**
   - Mendukung penyimpanan dan penampilan tanggal tenggat penyelesaian tugas dalam format ISO 8601.
3. **Pencarian & Filter Multi-Kriteria:**
   - **Pencarian Kata Kunci:** Mencari tugas secara *real-time* berdasarkan judul menggunakan klausa `LIKE` di SQL.
   - **Filter Status:** Menyaring daftar tugas berdasarkan status (*Semua*, *Belum Selesai*, atau *Selesai*).
   - **Filter Kategori:** Menyaring daftar tugas berdasarkan kategori tertentu menggunakan `ChoiceChip`.
4. **Kategorisasi Tugas (Relasi Dua Tabel):**
   - Menghubungkan tabel `todos` dan `categories` menggunakan *Foreign Key* (`categoryId`) serta menampilkan label kategori pada setiap kartu tugas.
5. **Keamanan & Best Practices SQLite:**
   - Menggunakan *Singleton Pattern* pada `DatabaseHelper` untuk mencegah konflik koneksi ganda.
   - Menerapkan *Parameterized Queries* (`where` dan `whereArgs`) untuk mencegah celah keamanan *SQL Injection*.

---

## Teknologi & Dependencies

- **Flutter SDK** (Material 3)
- **[sqflite](https://pub.dev/packages/sqflite):** Plugin SQLite untuk Flutter (Android & iOS).
- **[path](https://pub.dev/packages/path):** Manipulasi jalur (*path*) penyimpanan berkas basis data lintas platform.

---

## Struktur Proyek

```text
lib/
├── main.dart                     # Titik masuk utama (entry point) dan konfigurasi tema aplikasi
├── models/
│   ├── todo.dart                 # Model data Todo beserta metode konversi toMap() & fromMap()
│   └── category.dart             # Model data Category beserta metode konversi toMap() & fromMap()
├── database/
│   └── database_helper.dart      # Singleton helper untuk inisialisasi DB, migrasi, & seluruh operasi CRUD
└── screens/
    ├── todo_list_screen.dart     # Halaman utama daftar tugas, pencarian, dan filter
    └── todo_form_screen.dart     # Halaman formulir untuk menambah dan menyunting tugas
```

---

## Skema Basis Data SQLite

Aplikasi menyimpan data di dalam satu berkas basis data lokal yang terdiri dari dua tabel yang saling berelasi:

### 1. Tabel `categories`
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `INTEGER` | *Primary Key*, `AUTOINCREMENT` |
| `name` | `TEXT` | Nama kategori (`NOT NULL`) |

### 2. Tabel `todos`
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `INTEGER` | *Primary Key*, `AUTOINCREMENT` |
| `title` | `TEXT` | Judul tugas (`NOT NULL`) |
| `description` | `TEXT` | Deskripsi detail tugas (opsional) |
| `isDone` | `INTEGER` | Status selesai (`0` = Belum Selesai, `1` = Selesai) |
| `createdAt` | `TEXT` | Waktu pembuatan tugas dalam format ISO 8601 (`NOT NULL`) |
| `deadline` | `TEXT` | Batas waktu penyelesaian dalam format ISO 8601 (opsional) |
| `categoryId` | `INTEGER` | *Foreign Key* yang merujuk ke `categories(id)` |

---

## Langkah-langkah Menjalankan Aplikasi

Pastikan Anda sudah menginstal Flutter SDK di perangkat atau komputer Anda.

### 1. Clone repositori

Clone repositori ini ke komputer lokal Anda:

```bash
git clone https://github.com/munazahrah/BAB-3---to-do---list.git
```

### 2. Masuk ke direktori project

Masuk ke dalam direktori project:

```bash
cd to_do_list
```

### 3. Unduh package

Unduh seluruh package / dependensi:

```bash
flutter pub get
```

### 4. Jalankan aplikasi

Jalankan aplikasi di emulator atau perangkat fisik yang sudah terhubung:

```bash
flutter run
```

> **Catatan Pengembang:** Jika Anda sebelumnya pernah menjalankan versi lama aplikasi sebelum penambahan tabel `categories` dan kolom `deadline`, disarankan untuk melakukan **uninstall** aplikasi pada emulator/perangkat terlebih dahulu agar callback `onCreate` pada SQLite dapat membangun ulang skema tabel beserta data kategori awal secara bersih.
