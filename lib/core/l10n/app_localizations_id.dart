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
  String get deviceTransportFake => 'Simulator';

  @override
  String get bhutaniChartTitle => 'Nomogram Bhutani';

  @override
  String get showPreviousBilirubin => 'Tampilkan Bilirubin Sebelumnya';

  @override
  String get zoneLow => 'Risiko Rendah';

  @override
  String get zoneIntermediate => 'Risiko Menengah';

  @override
  String get zoneHighIntermediate => 'Risiko Menengah Tinggi';

  @override
  String get zoneHigh => 'Risiko Tinggi';

  @override
  String get zoneVeryHigh => 'Risiko Sangat Tinggi';

  @override
  String get recommendationHeader => 'Rekomendasi';

  @override
  String get recommendationLow =>
      'Kadar bilirubin dalam batas aman. Terus lakukan pemantauan rutin. Tidak diperlukan tindakan segera.';

  @override
  String get recommendationIntermediate =>
      'Bilirubin berada di zona menengah. Ulangi pengukuran dalam 8–12 jam dan pantau dengan cermat.';

  @override
  String get recommendationHighIntermediate =>
      'Bilirubin berada di zona menengah tinggi. Ulangi pengukuran dalam 4–8 jam. Pertimbangkan fototerapi sesuai panduan AAP 2022.';

  @override
  String get recommendationHigh =>
      'Bilirubin berada di zona risiko tinggi. Pertimbangkan fototerapi segera. Konsultasikan dengan dokter spesialis neonatologi.';

  @override
  String get recommendationVeryHigh =>
      'Bilirubin berada dalam kondisi kritis. Diperlukan intervensi segera. Segera eskalasi ke dokter neonatologi.';

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
  String get languageEnglish => 'Inggris';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageGerman => 'Jerman';
}
