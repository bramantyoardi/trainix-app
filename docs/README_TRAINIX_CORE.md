# Trainix — Core Rules & Data Docs

Dokumen ini menjelaskan **bagaimana file-file inti** Trainix saling terkait dan cara memakainya dalam pengembangan aplikasi (Flutter + Firebase).

## Tujuan
- Menyatukan **aturan bisnis** (roles, kalkulasi intensitas, leaderboard) dengan **arsitektur data** (Firestore) dan **izin akses** (Rules).
- Menjadi **sumber kebenaran tunggal** untuk developer, AI agent (Trae/MCP), dan dokumentasi skripsi.

---

## Isi Paket Dokumen

1. **`trainix_core_rules.yaml`**  
   _“Otak utama”_ — berisi kebijakan inti:
   - Role & permission (Coach, Athlete; Owner = `is_owner:true`)
   - Rumus HRR (Tanaka + Karvonen), band, dan scoring
   - Leaderboard mingguan (kriteria eligible, formula, lokasi subkoleksi)
   - Jalur koleksi Firestore dan kebijakan casing
   - Guardrail untuk AI (apa yang boleh/tidak)
   - Environment aktif (`trainix-app-mobile`)

2. **`firestore_schema.md`**  
   _Blueprint_ struktur data:
   - Koleksi & subkoleksi, bidang kanonik, audit fields
   - Casing policy (snake_case untuk koleksi utama; camelCase untuk utilitas)
   - Indeks yang disarankan
   - Catatan implementasi & kompatibilitas casing

3. **`firestore_rules_summary.yaml`**  
   _Matrix izin akses_:
   - read/write/delete per koleksi
   - Catatan perilaku (mis. leaderboard via callable, immutable security_logs)
   - Aturan global (audit fields wajib, timezone)
   - Pedoman indeks

> **Opsional deploy:** `firestore.rules` (disimpan di project root; dapat dihasilkan dari `firestore_rules_summary.yaml`).

---

## Korelasi Antar File

Alur konsistensi:
