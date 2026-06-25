import '../../../auth/data/models/santri_session.dart';

class MaarifSummaryItem {
  MaarifSummaryItem({
    required this.label,
    required this.value,
    required this.note,
    required this.icon,
  });

  final String label;
  final int value;
  final String note;
  final String icon;

  factory MaarifSummaryItem.fromJson(Map<String, dynamic> json) {
    return MaarifSummaryItem(
      label: '${json['label'] ?? '-'}',
      value: json['value'] is int ? json['value'] as int : int.tryParse('${json['value']}') ?? 0,
      note: '${json['note'] ?? '-'}',
      icon: '${json['icon'] ?? ''}',
    );
  }
}

class MuhafadzohItem {
  MuhafadzohItem({
    required this.field,
    required this.label,
    required this.progress,
    required this.pelajaran,
    required this.kelas,
    required this.triwulan,
    required this.target,
    required this.hasil,
    required this.progressPercent,
  });

  final String field;
  final String label;
  final String progress;
  final String pelajaran;
  final String kelas;
  final String triwulan;
  final String target;
  final int hasil;
  final int progressPercent;

  factory MuhafadzohItem.fromJson(Map<String, dynamic> json) {
    return MuhafadzohItem(
      field: '${json['field'] ?? ''}',
      label: '${json['label'] ?? '-'}',
      progress: '${json['progress'] ?? '-'}',
      pelajaran: '${json['pelajaran'] ?? '-'}',
      kelas: '${json['kelas'] ?? '-'}',
      triwulan: '${json['triwulan'] ?? '-'}',
      target: '${json['target'] ?? '-'}',
      hasil: json['hasil'] is int ? json['hasil'] as int : int.tryParse('${json['hasil']}') ?? 0,
      progressPercent: json['progress_percent'] is int
          ? json['progress_percent'] as int
          : int.tryParse('${json['progress_percent']}') ?? 0,
    );
  }
}

class MaarifAttendanceItem {
  MaarifAttendanceItem({
    required this.id,
    required this.tanggal,
    required this.kelas,
    required this.kegiatan,
    required this.status,
    required this.statusLabel,
    required this.totalSantri,
  });

  final int id;
  final String tanggal;
  final String kelas;
  final String kegiatan;
  final String status;
  final String statusLabel;
  final int totalSantri;

  factory MaarifAttendanceItem.fromJson(Map<String, dynamic> json) {
    return MaarifAttendanceItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      tanggal: '${json['tanggal'] ?? '-'}',
      kelas: '${json['kelas'] ?? '-'}',
      kegiatan: '${json['kegiatan'] ?? '-'}',
      status: '${json['status'] ?? 'hadir'}',
      statusLabel: '${json['status_label'] ?? 'Hadir'}',
      totalSantri: json['total_santri'] is int ? json['total_santri'] as int : int.tryParse('${json['total_santri']}') ?? 0,
    );
  }
}

class PondokAttendanceActivity {
  PondokAttendanceActivity({
    required this.id,
    required this.namaKegiatan,
    required this.status,
    required this.statusLabel,
  });

  final int id;
  final String namaKegiatan;
  final String status;
  final String statusLabel;

  factory PondokAttendanceActivity.fromJson(Map<String, dynamic> json) {
    return PondokAttendanceActivity(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      namaKegiatan: '${json['nama_kegiatan'] ?? '-'}',
      status: '${json['status'] ?? 'ghoib'}',
      statusLabel: '${json['status_label'] ?? 'Ghoib'}',
    );
  }
}

class PondokAttendanceItem {
  PondokAttendanceItem({
    required this.id,
    required this.tanggal,
    required this.keterangan,
    required this.activities,
  });

  final int id;
  final String tanggal;
  final String keterangan;
  final List<PondokAttendanceActivity> activities;

  factory PondokAttendanceItem.fromJson(Map<String, dynamic> json) {
    return PondokAttendanceItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      tanggal: '${json['tanggal'] ?? '-'}',
      keterangan: '${json['keterangan'] ?? '-'}',
      activities: (json['activities'] as List? ?? const [])
          .map((item) => PondokAttendanceActivity.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class MaarifOverview {
  MaarifOverview({
    required this.santri,
    required this.summary,
    required this.muhafadzoh,
    required this.absensiMaarif,
    required this.absensiPondok,
  });

  final SantriProfile santri;
  final List<MaarifSummaryItem> summary;
  final List<MuhafadzohItem> muhafadzoh;
  final List<MaarifAttendanceItem> absensiMaarif;
  final List<PondokAttendanceItem> absensiPondok;

  factory MaarifOverview.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    return MaarifOverview(
      santri: SantriProfile.fromJson(Map<String, dynamic>.from(data['santri'] as Map)),
      summary: (data['summary'] as List? ?? const [])
          .map((item) => MaarifSummaryItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      muhafadzoh: (data['muhafadzoh'] as List? ?? const [])
          .map((item) => MuhafadzohItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      absensiMaarif: (data['absensi_maarif'] as List? ?? const [])
          .map((item) => MaarifAttendanceItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      absensiPondok: (data['absensi_pondok'] as List? ?? const [])
          .map((item) => PondokAttendanceItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
