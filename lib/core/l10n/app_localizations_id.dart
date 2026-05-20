// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Monitor Bilirubin';

  @override
  String get dashboardTitle => 'Dasbor';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get noBabiesTitle => 'Belum ada bayi yang ditambahkan';

  @override
  String get noBabiesCta => 'Tambahkan bayi pertama Anda';

  @override
  String get noMeasurementsTitle => 'Belum ada pengukuran';

  @override
  String get noMeasurementsBody =>
      'Hubungkan perangkat dan lakukan pengukuran.';

  @override
  String deviceConnected(String deviceName, String transport) {
    return 'Terhubung: $deviceName ($transport)';
  }

  @override
  String get deviceDisconnected => 'Tidak terhubung';

  @override
  String get deviceTransportWifi => 'Wi-Fi';

  @override
  String get deviceTransportBle => 'BLE';

  @override
  String get bhutaniChartTitle => 'Nomogram Bhutani';

  @override
  String get showPreviousBilirubin => 'Tampilkan Bacaan Sebelumnya';

  @override
  String get showReadingsOutside168h => 'Tampilkan Bacaan >168 jam';

  @override
  String get bhutaniOutsideRangeNotice =>
      'Pengingat: Nomogram Bhutani ini hanya menampilkan pembacaan bilirubin dari usia 0 hingga 168 jam. Pembacaan di luar rentang usia ini ditampilkan sebagai titik ungu.';

  @override
  String get bhutaniCurrentBeyond168h =>
      'Usia bayi saat ini sudah lebih dari 168 jam.';

  @override
  String get axisLabelTotalSerumBilirubin => 'Total Bilirubin Serum (mg/dL)';

  @override
  String get axisLabelAgeHours => 'Usia (jam)';

  @override
  String get zoneLow => 'Risiko Rendah';

  @override
  String get zoneLowIntermediate => 'Risiko Rendah Menengah';

  @override
  String get zoneHighIntermediate => 'Risiko Menengah Tinggi';

  @override
  String get zoneHigh => 'Risiko Tinggi';

  @override
  String get recommendationHeader => 'Rekomendasi';

  @override
  String get recommendationLow =>
      'Kadar bilirubin dalam batas aman (di bawah persentil ke-40). Terus lakukan pemantauan rutin. Tidak diperlukan tindakan segera.';

  @override
  String get recommendationLowIntermediate =>
      'Bilirubin berada di zona rendah menengah (persentil ke-40 hingga ke-75). Ulangi pengukuran dalam 8–12 jam dan pantau dengan cermat.';

  @override
  String get recommendationHighIntermediate =>
      'Bilirubin berada di zona menengah tinggi (persentil ke-75 hingga ke-95). Ulangi pengukuran dalam 4–8 jam. Pertimbangkan fototerapi sesuai panduan AAP 2022.';

  @override
  String get recommendationHigh =>
      'Bilirubin berada dalam kondisi kritis (di atas persentil ke-95). Diperlukan intervensi segera. Segera eskalasi ke dokter neonatologi.';

  @override
  String get metadataTitle => 'Informasi Bayi';

  @override
  String get metadataName => 'Nama';

  @override
  String get metadataWeight => 'Berat';

  @override
  String metadataWeightKg(String weight) {
    return '$weight kg';
  }

  @override
  String get metadataDob => 'Tanggal Lahir';

  @override
  String get metadataAge => 'Usia';

  @override
  String metadataAgeHours(String hours) {
    return '$hours jam';
  }

  @override
  String get metadataEdit => 'Ubah';

  @override
  String bilirubinValue(String value) {
    return '$value mg/dL';
  }

  @override
  String get editBabyTitle => 'Ubah Data Bayi';

  @override
  String get addBabyTitle => 'Tambah Bayi';

  @override
  String get fieldName => 'Nama';

  @override
  String get fieldWeight => 'Berat (kg)';

  @override
  String get fieldDob => 'Tanggal Lahir';

  @override
  String get selectDate => 'Pilih tanggal';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get validationRequired => 'Kolom ini wajib diisi.';

  @override
  String get validationWeightRange => 'Berat harus antara 0,4 dan 8,0 kg.';

  @override
  String get validationDobFuture => 'Tanggal lahir tidak boleh di masa depan.';

  @override
  String get validationDobTooOld => 'Tanggal lahir terlalu jauh ke masa lalu.';

  @override
  String get validationNameTooLong =>
      'Nama tidak boleh lebih dari 100 karakter.';

  @override
  String get validationNameInvalid =>
      'Nama mengandung karakter yang tidak valid.';

  @override
  String get settingsPiLanTitle => 'Raspberry Pi LAN';

  @override
  String get settingsPiAddressLabel => 'Alamat Pi atau URL';

  @override
  String get settingsPiAddressHint =>
      '192.168.1.50:8080 atau http://raspi.local:8080';

  @override
  String get settingsPiSave => 'Simpan alamat Pi';

  @override
  String get settingsPiClear => 'Hapus';

  @override
  String get settingsPiBeaconUse => 'Gunakan';

  @override
  String get settingsPiBeaconDescription =>
      'Jika ponsel dan Pi terhubung ke jaringan Wi-Fi yang sama, aplikasi dapat menemukan Pi secara otomatis melalui beacon. Supabase tetap menyimpan riwayat yang disinkronkan.';

  @override
  String get settingsWifi => 'Konfigurasi Wi-Fi';

  @override
  String get settingsWifiSsid => 'Nama jaringan (SSID)';

  @override
  String get settingsWifiPassword => 'Kata sandi';

  @override
  String get settingsBle => 'Konfigurasi Bluetooth';

  @override
  String get settingsBleNotAvailable => 'BLE belum didukung pada versi ini.';

  @override
  String get settingsBleNoPaired => 'Tidak ada perangkat yang dipasangkan';

  @override
  String get settingsBleUnpair => 'Putuskan pasangan';

  @override
  String get settingsBleStartScan => 'Cari perangkat';

  @override
  String get settingsBleScanning => 'Memindai…';

  @override
  String get settingsBlePair => 'Pasangkan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsAppLock => 'Kunci Aplikasi';

  @override
  String get settingsAppLockSubtitle =>
      'Wajibkan PIN atau biometrik untuk membuka aplikasi.';

  @override
  String get pinLockTitle => 'Masukkan PIN';

  @override
  String get pinLockEnterNew => 'Buat PIN baru';

  @override
  String get pinLockConfirm => 'Konfirmasi PIN';

  @override
  String get pinLockIncorrect => 'PIN salah. Coba lagi.';

  @override
  String get pinLockMismatch => 'PIN tidak cocok.';

  @override
  String get pinLockUseBiometric => 'Gunakan biometrik';

  @override
  String get exportSuccess => 'Data berhasil diekspor.';

  @override
  String get exportFailed => 'Ekspor gagal.';

  @override
  String get exportAction => 'Ekspor';

  @override
  String exportedTo(String filename) {
    return 'Diekspor ke $filename';
  }

  @override
  String get exportSheetTitle => 'Ekspor Data';

  @override
  String get exportFileName => 'Nama File';

  @override
  String get exportSaveLocation => 'Lokasi Simpan';

  @override
  String get exportBrowse => 'Jelajahi';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageGerman => 'Jerman';

  @override
  String get zoneLowFull => 'Zona Risiko Rendah';

  @override
  String get zoneLowIntermediateFull => 'Zona Risiko Rendah Menengah';

  @override
  String get zoneHighIntermediateFull => 'Zona Risiko Menengah Tinggi';

  @override
  String get zoneHighFull => 'Zona Risiko Tinggi';

  @override
  String get deviceConnecting => 'Menghubungkan…';

  @override
  String get deviceConnectedLabel => 'Terhubung:';

  @override
  String get deviceConnect => 'Hubungkan';

  @override
  String get deviceDisconnect => 'Putuskan';

  @override
  String get selectBaby => 'Pilih bayi';

  @override
  String get searchBabiesHint => 'Cari bayi…';

  @override
  String archivedCount(int count) {
    return 'Diarsipkan ($count)';
  }

  @override
  String get archiveBabyAction => 'Arsipkan Bayi';

  @override
  String archiveBabyContent(String name) {
    return 'Arsipkan \"$name\"? Data akan disimpan dan dapat dipulihkan nanti.';
  }

  @override
  String get archiveAction => 'Arsipkan';

  @override
  String get permanentDeleteTitle => 'Hapus Permanen Bayi';

  @override
  String permanentDeleteContent(String name) {
    return 'Hapus permanen \"$name\"? Semua data akan hilang dan tidak dapat dipulihkan.';
  }

  @override
  String get deleteForever => 'Hapus Selamanya';

  @override
  String get restoreAction => 'Pulihkan';

  @override
  String get permanentlyDeleteTooltip => 'Hapus permanen';

  @override
  String get archivedBabies => 'Lihat Bayi Diarsipkan';

  @override
  String get pdfTitle => 'Laporan Bilirubin';

  @override
  String get pdfExportedAt => 'Diekspor:';

  @override
  String get pdfGeneratedBy => 'Dibuat oleh Aplikasi Bilirubin';

  @override
  String get pdfPatientInfo => 'Informasi Pasien';

  @override
  String get pdfBirthWeight => 'Berat Lahir';

  @override
  String get pdfAgeAtExport => 'Usia saat Ekspor';

  @override
  String get pdfMeasurementsTitle => 'Pengukuran';

  @override
  String get pdfColDateTime => 'Tanggal/Waktu';

  @override
  String get pdfColBilirubin => 'Bilirubin (mg/dL)';

  @override
  String get pdfColZone => 'Zona';

  @override
  String get pdfColDevice => 'Perangkat';

  @override
  String get cloudNotConfigured => 'Tidak dapat terhubung ke server';

  @override
  String get cloudSyncing => 'Menyinkronkan…';

  @override
  String get cloudSyncError => 'Gagal sinkronisasi';

  @override
  String get cloudSynced => 'Tersinkronisasi';
}
