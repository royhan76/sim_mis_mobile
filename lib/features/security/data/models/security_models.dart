import '../../../auth/data/models/santri_session.dart';

class SecurityPelanggaranItem {
  SecurityPelanggaranItem({
    required this.id,
    required this.tingkat,
    required this.pelanggaran,
    required this.tanggal,
    required this.tanggalInput,
  });

  final int id;
  final String tingkat;
  final String pelanggaran;
  final String tanggal;
  final String tanggalInput;

  factory SecurityPelanggaranItem.fromJson(Map<String, dynamic> json) {
    final parsed = _parsePelanggaranValue('${json['pelanggaran'] ?? '-'}');
    return SecurityPelanggaranItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      tingkat: parsed.level,
      pelanggaran: parsed.name,
      tanggal: '${json['tanggal'] ?? '-'}',
      tanggalInput: '${json['tanggal_input'] ?? '-'}',
    );
  }
}

class _ParsedPelanggaran {
  const _ParsedPelanggaran({
    required this.level,
    required this.name,
  });

  final String level;
  final String name;
}

_ParsedPelanggaran _parsePelanggaranValue(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const _ParsedPelanggaran(level: '-', name: '-');
  }

  final parts = trimmed.split('|').map((part) => part.trim()).toList();
  if (parts.length >= 3) {
    final first = parts[0];
    final second = parts[1];
    final name = parts.sublist(2).join(' | ').trim();

    if (_looksLikeDate(first)) {
      return _ParsedPelanggaran(
        level: second.isEmpty ? '-' : second,
        name: name.isEmpty ? '-' : name,
      );
    }
  }

  if (parts.length == 2) {
    return _ParsedPelanggaran(
      level: parts[0].isEmpty ? '-' : parts[0],
      name: parts[1].isEmpty ? '-' : parts[1],
    );
  }

  return _ParsedPelanggaran(level: '-', name: trimmed);
}

bool _looksLikeDate(String value) {
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim()) ||
      RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value.trim());
}

class SecurityIzinItem {
  SecurityIzinItem({
    required this.id,
    required this.tujuan,
    required this.batasHari,
    required this.tanggalKeluar,
    required this.tanggalMasuk,
    required this.keterangan,
  });

  final int id;
  final String tujuan;
  final String batasHari;
  final String tanggalKeluar;
  final String tanggalMasuk;
  final String keterangan;

  factory SecurityIzinItem.fromJson(Map<String, dynamic> json) {
    return SecurityIzinItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      tujuan: '${json['tujuan'] ?? '-'}',
      batasHari: '${json['batas_hari'] ?? '-'}',
      tanggalKeluar: '${json['tanggal_keluar'] ?? '-'}',
      tanggalMasuk: '${json['tanggal_masuk'] ?? '-'}',
      keterangan: '${json['keterangan'] ?? '-'}',
    );
  }
}

class SecurityPelanggaranBundle {
  SecurityPelanggaranBundle({
    required this.santri,
    required this.records,
  });

  final SantriProfile santri;
  final List<SecurityPelanggaranItem> records;

  factory SecurityPelanggaranBundle.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    final santri = SantriProfile.fromJson(Map<String, dynamic>.from(data['santri'] as Map));
    final records = (data['reports'] as List? ?? const [])
        .map((item) => SecurityPelanggaranItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return SecurityPelanggaranBundle(
      santri: santri,
      records: records,
    );
  }
}

class SecurityIzinBundle {
  SecurityIzinBundle({
    required this.santri,
    required this.records,
  });

  final SantriProfile santri;
  final List<SecurityIzinItem> records;

  factory SecurityIzinBundle.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    final santri = SantriProfile.fromJson(Map<String, dynamic>.from(data['santri'] as Map));
    final records = (data['records'] as List? ?? const [])
        .map((item) => SecurityIzinItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return SecurityIzinBundle(
      santri: santri,
      records: records,
    );
  }
}

class SecurityOverview {
  SecurityOverview({
    required this.santri,
    required this.pelanggaran,
    required this.izin,
  });

  final SantriProfile santri;
  final List<SecurityPelanggaranItem> pelanggaran;
  final List<SecurityIzinItem> izin;
}
