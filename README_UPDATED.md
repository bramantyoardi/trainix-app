# Trainix App

Aplikasi mobile untuk manajemen training dan fitness yang dibangun dengan Flutter dan Firebase.

## 📱 Tentang Aplikasi

Trainix adalah aplikasi mobile yang dirancang untuk membantu pengguna dalam mengelola aktivitas training dan fitness mereka. Aplikasi ini menyediakan fitur-fitur lengkap untuk tracking workout, manajemen tim, leaderboard, dan notifikasi.

## ✨ Fitur Utama

- 🔐 **Autentikasi Pengguna** - Login, register, verifikasi email, forgot password
- 👥 **Manajemen Tim** - Buat dan kelola tim training
- 🏃‍♂️ **Training Log** - Catat dan track aktivitas training
- 📊 **Leaderboard** - Sistem ranking dan kompetisi
- 🔔 **Push Notifications** - Notifikasi real-time
- 📈 **Program Training** - Kelola program latihan
- ⚡ **Intensity Tracking** - Monitor intensitas latihan
- 🔒 **Security** - Enkripsi data dan keamanan

## 🛠️ Teknologi yang Digunakan

- **Flutter** - Framework UI cross-platform
- **Firebase** - Backend as a Service
  - Firebase Auth - Autentikasi
  - Cloud Firestore - Database NoSQL
  - Firebase Storage - Penyimpanan file
  - Firebase Messaging - Push notifications
- **Provider** - State management
- **Material Design** - UI/UX design system

## 📦 Dependencies

### Core Dependencies
- `firebase_core: ^2.15.1`
- `firebase_auth: ^4.9.0`
- `cloud_firestore: ^4.9.1`
- `firebase_storage: ^11.2.6`
- `firebase_messaging: ^14.6.7`
- `provider: ^6.0.5`

### UI & Utils
- `google_sign_in: ^6.1.4`
- `image_picker: ^1.0.2`
- `flutter_local_notifications: ^15.1.0+1`
- `permission_handler: ^10.4.3`
- `intl: ^0.18.1`
- `crypto: ^3.0.3`

### Development
- `flutter_test`
- `flutter_lints: ^2.0.0`
- `fake_cloud_firestore: ^2.4.1+1`
- `firebase_auth_mocks: ^0.13.0`

## 🚀 Cara Menjalankan

1. **Clone repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/trainix_app.git
   cd trainix_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Buat project baru di [Firebase Console](https://console.firebase.google.com/)
   - Tambahkan aplikasi Android/iOS
   - Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
   - Letakkan file konfigurasi di folder yang sesuai

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 📁 Struktur Project

```
lib/
├── extensions/          # Extension methods
├── models/             # Data models
├── providers/          # State management (Provider)
├── services/           # Business logic services
├── ui/                # User interface
│   ├── authentication/ # Auth screens
│   ├── components/     # Reusable components
│   ├── team/          # Team management
│   ├── training/      # Training screens
│   └── user_management/ # User management
└── utils/             # Utility functions
```

## 🔧 Konfigurasi

### Firebase Setup
1. Aktifkan Authentication dengan Email/Password dan Google Sign-In
2. Setup Firestore Database dengan rules yang sesuai
3. Konfigurasi Firebase Storage untuk upload gambar
4. Setup Firebase Messaging untuk push notifications

### Android Permissions
Aplikasi memerlukan permissions berikut:
- Internet access
- Camera (untuk foto profil)
- Storage (untuk menyimpan gambar)
- Notifications

## 🧪 Testing

Jalankan test dengan perintah:
```bash
flutter test
```

Test yang tersedia:
- Unit tests untuk services
- Widget tests untuk UI components
- Firestore rules testing

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS

## 🤝 Kontribusi

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## 📄 Lisensi

Project ini menggunakan lisensi MIT. Lihat file `LICENSE` untuk detail lebih lanjut.

## 👨‍💻 Developer

Dikembangkan sebagai bagian dari project skripsi untuk aplikasi manajemen training dan fitness.

## 📞 Kontak

Untuk pertanyaan atau saran, silakan buat issue di repository ini.