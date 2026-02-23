<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## Technical Stack
Sistem ini dibangun menggunakan teknologi :
* Framework : Laravel 12 (API-only)
* Database : PostgreSQL 14
* Authentication : Token-based Authentication

## Tes Backend
* Menggunakkan Postman (install terlebih dahulu di VS Code *php artisan install:api* agar token login bisa muncul)
* Password dalam database bisa kalian ubah dengan cara melakukan hash di VS Code dengan command *php artisan tinker* lalu ketik *Hash::make('isi password kalian');

## (Workflow)
Sistem ini mengakomodasi alur kerja pengadaan barang sebagai berikut:
1. Karyawan mengajukan permintaan barang/jasa
2. Tim *Purchasing* melakukan verifikasi terhadap permintaan tersebut
3. Atasan *Purchasing* melakukan *approval* (persetujuan)
4. Tim *Warehouse* melakukan pengecekan ketersediaan stok
5. Jika stok tidak tersedia, *Purchasing* akan melakukan pengadaan langsung ke vendor
6. Sistem akan menginformasikan status proses secara berkala kepada pemohon hingga selesai

## Instalasi Dependensi
* composer install

## Migrasi Database
* php artisan migrate (pada .env silahkan memasukkan username, password, database milih kalian)

## Run Server
* php artisan serve
