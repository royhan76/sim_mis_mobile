import 'dart:convert';

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.status,
    required this.santriId,
  });

  final int? id;
  final String name;
  final String username;
  final String role;
  final String status;
  final String? santriId;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: '${json['name'] ?? '-'}',
      username: '${json['username'] ?? '-'}',
      role: '${json['role'] ?? '-'}',
      status: '${json['status'] ?? '-'}',
      santriId: json['santri_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'role': role,
      'status': status,
      'santri_id': santriId,
    };
  }
}

class SantriProfile {
  SantriProfile({
    required this.santriId,
    required this.nik,
    required this.nama,
    required this.khos,
    required this.kelas,
    required this.status,
    required this.noTlp,
    required this.alamat,
    required this.photoUrl,
  });

  final String santriId;
  final String nik;
  final String nama;
  final String khos;
  final String kelas;
  final String status;
  final String noTlp;
  final String alamat;
  final String photoUrl;

  factory SantriProfile.fromJson(Map<String, dynamic> json) {
    return SantriProfile(
      santriId: '${json['santri_id'] ?? '-'}',
      nik: '${json['nik'] ?? '-'}',
      nama: '${json['nama'] ?? '-'}',
      khos: '${json['khos'] ?? '-'}',
      kelas: '${json['kelas'] ?? '-'}',
      status: '${json['status'] ?? '-'}',
      noTlp: '${json['no_tlp'] ?? '-'}',
      alamat: '${json['alamat'] ?? '-'}',
      photoUrl: '${json['photo_url'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'santri_id': santriId,
      'nik': nik,
      'nama': nama,
      'khos': khos,
      'kelas': kelas,
      'status': status,
      'no_tlp': noTlp,
      'alamat': alamat,
      'photo_url': photoUrl,
    };
  }
}

class SantriSession {
  SantriSession({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.santri,
  });

  final String token;
  final String tokenType;
  final int? expiresIn;
  final AppUser user;
  final SantriProfile? santri;

  factory SantriSession.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return SantriSession(
      token: '${json['token'] ?? ''}',
      tokenType: '${json['token_type'] ?? 'Bearer'}',
      expiresIn: json['expires_in'] is int ? json['expires_in'] as int : int.tryParse('${json['expires_in']}'),
      user: AppUser.fromJson((data['user'] as Map<String, dynamic>?) ?? const {}),
      santri: data['santri'] == null ? null : SantriProfile.fromJson(Map<String, dynamic>.from(data['santri'] as Map)),
    );
  }

  factory SantriSession.fromStoredJson(Map<String, dynamic> json) {
    return SantriSession(
      token: '${json['token'] ?? ''}',
      tokenType: '${json['token_type'] ?? 'Bearer'}',
      expiresIn: json['expires_in'] is int ? json['expires_in'] as int : int.tryParse('${json['expires_in']}'),
      user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      santri: json['santri'] == null ? null : SantriProfile.fromJson(Map<String, dynamic>.from(json['santri'] as Map)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
      'santri': santri?.toJson(),
    };
  }

  String get authorizationHeader => '$tokenType $token';

  String toStoredJson() => jsonEncode(toJson());

  static SantriSession fromStoredString(String raw) {
    return SantriSession.fromStoredJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }
}
