// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Biligun Companion';

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
  String get deviceDisconnected => 'Tidak berpasangan';

  @override
  String get bhutaniChartTitle => 'Nomogram Bhutani';

  @override
  String get showPreviousBilirubin => 'Tampilkan Bacaan Sebelumnya';

  @override
  String get showReadingsOutside168h => 'Tampilkan Bacaan >168 jam';

  @override
  String get bhutaniOutsideRangeNotice =>
      'Peringatan: Nomogram Bhutani ini hanya menampilkan pembacaan bilirubin dari usia 0 hingga 168 jam. Pembacaan di luar rentang usia ini ditampilkan sebagai titik ungu.';

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
  String get editAction => 'Ubah';

  @override
  String get fieldName => 'Nama';

  @override
  String get fieldWeight => 'Berat (kg)';

  @override
  String get fieldDob => 'Tanggal & Waktu Lahir';

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
  String get settingsPiLanTitle => 'Biligun LAN';

  @override
  String get settingsPiAddressLabel => 'Alamat Biligun atau URL';

  @override
  String get settingsPiAddressHint => '10.42.0.1:7878';

  @override
  String get settingsHotspotTitle => 'Pairing Biligun';

  @override
  String get settingsHotspotInstructions =>
      'Saat ponsel dan Biligun terhubung ke jaringan Wi-Fi yang sama, aplikasi akan menemukan perangkat secara otomatis.';

  @override
  String get settingsPiSave => 'Hubungkan';

  @override
  String get settingsPiClear => 'Putuskan';

  @override
  String get settingsPiBeaconUse => 'Gunakan';

  @override
  String get settingsPiBeaconDescription =>
      'Jika ponsel dan Biligun terhubung ke jaringan Wi-Fi yang sama, aplikasi dapat menemukan Biligun secara otomatis melalui beacon. Supabase tetap menyimpan riwayat yang disinkronkan.';

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
  String get deviceConnecting => 'Menghubungi…';

  @override
  String get deviceConnectedLabel => 'Terhubung:';

  @override
  String get deviceConnect => 'Hubungkan';

  @override
  String get deviceDisconnect => 'Putuskan';

  @override
  String deviceConnectedTo(String displayName) {
    return 'Terhubung dengan $displayName';
  }

  @override
  String get deviceConnectionError => 'Gagal menghubung';

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
  String get cloudSyncing => 'Menyinkronkan ke server…';

  @override
  String get cloudSyncError => 'Gagal sinkronisasi';

  @override
  String get cloudSynced => 'Tersinkronisasi';

  @override
  String get noReadings => 'Belum Ada Bacaan';

  @override
  String get syncButton => 'Sinkronisasi';

  @override
  String get syncButtonSyncing => 'Menyinkron…';

  @override
  String get metadataTob => 'Waktu Lahir';

  @override
  String get errorAccountDeactivated =>
      'Akun Anda telah dinonaktifkan. Hubungi administrator rumah sakit Anda.';

  @override
  String get loginSubtitle => 'Masuk untuk melanjutkan';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Kata sandi';

  @override
  String get loginSignIn => 'Masuk';

  @override
  String get loginEmailValidation => 'Masukkan email Anda';

  @override
  String get loginPasswordValidation => 'Masukkan kata sandi Anda';

  @override
  String get loginContactAdmin =>
      'Hubungi administrator rumah sakit Anda untuk mendapatkan akun.';

  @override
  String get loginUnexpectedError => 'Terjadi kesalahan yang tidak terduga.';

  @override
  String get adminPanelTitle => 'Dasbor Admin';

  @override
  String get adminUserManagementTitle => 'Manajemen Pengguna';

  @override
  String get adminUserManagementSubtitle =>
      'Kelola semua akun admin, staf, dan orang tua';

  @override
  String get adminParentAccessTitle => 'Akses Orang Tua';

  @override
  String get adminParentAccessSubtitle =>
      'Hubungkan dan putuskan hubungan orang tua dengan bayi';

  @override
  String get adminTransfersTitle => 'Transfer Bayi';

  @override
  String get adminTransfersSubtitle =>
      'Inisiasi dan kelola transfer antar rumah sakit';

  @override
  String get adminAuditTitle => 'Log Peristiwa Audit';

  @override
  String get adminAuditSubtitle =>
      'Lihat log tindakan sensitif di rumah sakit Anda';

  @override
  String get userManagementTitle => 'Manajemen Pengguna';

  @override
  String get addAccountFab => 'Tambah Akun';

  @override
  String get noAccountsFound => 'Tidak ada akun ditemukan.';

  @override
  String get roleAll => 'Semua';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleStaff => 'Staf';

  @override
  String get roleParent => 'Orang Tua';

  @override
  String get deactivateAccountTitle => 'Nonaktifkan Akun';

  @override
  String get reactivateAccountTitle => 'Aktifkan Kembali Akun';

  @override
  String deactivateConfirmContent(String name, String role) {
    return 'Nonaktifkan $name ($role)? Mereka akan langsung kehilangan akses.';
  }

  @override
  String reactivateConfirmContent(String name, String role) {
    return 'Aktifkan kembali $name ($role)? Mereka akan mendapatkan kembali akses.';
  }

  @override
  String get deactivatedLabel => 'Dinonaktifkan';

  @override
  String get selfLabel => '(Anda)';

  @override
  String get addAccountDialogTitle => 'Tambah Akun';

  @override
  String get fullNameLabel => 'Nama Lengkap';

  @override
  String get roleLabel => 'Peran';

  @override
  String get passwordMinLength => 'Min 8 karakter';

  @override
  String get createLabel => 'Buat';

  @override
  String loadingUsersError(String error) {
    return 'Gagal memuat pengguna: $error';
  }

  @override
  String get parentAccessTitle => 'Akses Orang Tua';

  @override
  String get currentLinksTitle => 'Tautan Saat Ini';

  @override
  String get noParentLinksYet => 'Belum ada tautan orang tua.';

  @override
  String get linkParentSectionTitle => 'Tautkan Orang Tua ke Bayi';

  @override
  String get findParentStep => 'Langkah 1: Temukan akun orang tua';

  @override
  String get parentEmailLabel => 'Email orang tua';

  @override
  String get searchLabel => 'Cari';

  @override
  String get selectBabyStep => 'Langkah 2: Pilih bayi';

  @override
  String get linkParentButton => 'Tautkan Orang Tua ke Bayi';

  @override
  String get unlinkParentTitle => 'Putuskan Tautan Orang Tua';

  @override
  String unlinkConfirmContent(String parent, String baby) {
    return 'Hapus akses $parent ke $baby?';
  }

  @override
  String get parentLinkedSuccess => 'Orang tua berhasil ditautkan.';

  @override
  String get babyTransfersTitle => 'Transfer Bayi';

  @override
  String get outgoingTab => 'Keluar';

  @override
  String get incomingTab => 'Masuk';

  @override
  String get initiateTransferFab => 'Inisiasi Transfer';

  @override
  String get noOutgoingTransfers => 'Tidak ada transfer keluar.';

  @override
  String get noIncomingTransfers => 'Tidak ada transfer masuk.';

  @override
  String get acceptLabel => 'Terima';

  @override
  String get rejectLabel => 'Tolak';

  @override
  String get initiateTransferDialogTitle => 'Inisiasi Transfer';

  @override
  String get babyLabel => 'Bayi';

  @override
  String get targetHospitalCodeLabel => 'Kode Rumah Sakit Tujuan';

  @override
  String get hospitalCodeHint => 'mis. RSU-01';

  @override
  String get sendLabel => 'Kirim';

  @override
  String get auditEventsLogTitle => 'Log Peristiwa Audit';

  @override
  String get auditAllFilter => 'Semua';

  @override
  String get auditNoEvents => 'Tidak ada peristiwa ditemukan.';

  @override
  String get auditEventBabyCreate => 'Bayi Dibuat';

  @override
  String get auditEventBabyEdit => 'Bayi Diubah';

  @override
  String get auditEventBabyDelete => 'Bayi Dihapus';

  @override
  String get auditEventMeasurementCreate => 'Pengukuran Dicatat';

  @override
  String get auditEventMeasurementDelete => 'Pengukuran Dihapus';

  @override
  String get auditEventExport => 'Ekspor Data';

  @override
  String get auditEventAccountCreate => 'Akun Dibuat';

  @override
  String get auditEventAccountDeactivate => 'Akun Dinonaktifkan';

  @override
  String get auditEventAccountReactivate => 'Akun Diaktifkan Kembali';

  @override
  String get auditEventParentLink => 'Orang Tua Ditautkan';

  @override
  String get auditEventParentUnlink => 'Orang Tua Diputuskan';

  @override
  String get auditEventDeviceAdd => 'Perangkat Terhubung';

  @override
  String get auditEventTransferCreate => 'Transfer Diinisiasi';

  @override
  String get auditEventTransferAccept => 'Transfer Diterima';

  @override
  String get auditEventTransferReject => 'Transfer Ditolak';

  @override
  String get parentDashboardTitle => 'Dasbor Orang Tua';

  @override
  String get signOutTooltip => 'Keluar';

  @override
  String get awaitingLinkageTitle => 'Menunggu tautan';

  @override
  String awaitingLinkageBody(String email) {
    return 'Akun Anda ($email) belum ditautkan ke bayi oleh rumah sakit. Hubungi staf rumah sakit Anda.';
  }

  @override
  String get measurementsSectionTitle => 'Pengukuran';

  @override
  String get noMeasurementsParent => 'Belum ada pengukuran.';

  @override
  String get settingsAccountTitle => 'Akun';

  @override
  String get signOutLabel => 'Keluar';

  @override
  String get couldNotLoadProfile => 'Tidak dapat memuat profil.';

  @override
  String get adminSearchUsersHint => 'Cari pengguna…';

  @override
  String get adminDeactivate => 'Nonaktifkan';

  @override
  String get adminReactivate => 'Aktifkan Kembali';

  @override
  String get adminErrorGeneric => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get adminParentNotFound => 'Akun orang tua tidak ditemukan.';

  @override
  String get adminLinkFailed => 'Gagal menautkan orang tua ke bayi.';

  @override
  String get adminUnlinkFailed => 'Gagal menghapus tautan.';

  @override
  String get transferWarningTitle => 'Peringatan: Data Akan Hilang';

  @override
  String get transferWarningBody =>
      'Setelah transfer diterima, rumah sakit Anda akan kehilangan akses permanen ke data dan pengukuran bayi ini. Ekspor data sebelum melanjutkan.';

  @override
  String get transferWarningConfirm => 'Saya Mengerti, Lanjutkan';

  @override
  String get cancelTransfer => 'Batalkan Transfer';

  @override
  String get adminEditUser => 'Edit Pengguna';

  @override
  String get adminEditUserTitle => 'Edit Akun';

  @override
  String get adminSaveChanges => 'Simpan Perubahan';

  @override
  String get auditEventAccountEdit => 'Akun Diubah';

  @override
  String get auditEventTransferCancel => 'Transfer Dibatalkan';

  @override
  String get parentNoConnectionTitle => 'Tidak Ada Koneksi Internet';

  @override
  String get parentNoConnectionBody =>
      'Koneksi internet diperlukan untuk memuat data bayi Anda untuk pertama kali. Harap sambungkan ke internet dan coba lagi.';

  @override
  String get parentSyncLabel => 'Sinkronkan';

  @override
  String get retryAction => 'Coba Lagi';

  @override
  String get transferInvalidHospitalCode => 'Kode rumah sakit tidak valid.';

  @override
  String get transferSameHospitalError =>
      'Tidak dapat mentransfer ke rumah sakit sendiri.';

  @override
  String get transferConfirmTitle => 'Konfirmasi Transfer';

  @override
  String get transferConfirmBabyLabel => 'Bayi yang akan ditransfer';

  @override
  String get transferConfirmYes => 'Ya, Lanjutkan';
}
