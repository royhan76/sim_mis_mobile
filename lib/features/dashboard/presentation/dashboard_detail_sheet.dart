import 'package:flutter/material.dart';

import '../../auth/data/models/santri_session.dart';
import '../../security/data/models/security_models.dart';
import '../../../shared/widgets/app_skeleton.dart';

class DashboardProfileBottomSheet extends StatelessWidget {
  const DashboardProfileBottomSheet({
    required this.session,
    required this.onLogout,
  });

  final SantriSession session;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final santri = session.santri;
    final nama = santri?.nama ?? session.user.name;
    final nik = santri?.nik ?? session.user.username;
    final kelas = santri?.kelas ?? '-';
    final khos = santri?.khos ?? '-';
    final status = santri?.status ?? session.user.status;
    final noTlp = santri?.noTlp ?? '-';
    final alamat = santri?.alamat ?? '-';
    final photoUrl = santri?.photoUrl ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E2EC),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF13B3A7), Color(0xFF0E8E98)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: _DetailSantriAvatar(photoUrl: photoUrl),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Detail profil santri',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileInfoCard(
                  items: [
                    _ProfileInfoItem(label: 'NIK', value: nik),
                    _ProfileInfoItem(label: 'Status', value: status),
                    _ProfileInfoItem(label: 'Khos', value: khos),
                    _ProfileInfoItem(label: 'Kelas', value: kelas),
                    _ProfileInfoItem(label: 'No. HP', value: noTlp),
                    _ProfileInfoItem(label: 'Alamat', value: alamat),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Tutup',
                        icon: Icons.close_rounded,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF17304D),
                        borderColor: const Color(0xFFE2E8F0),
                        onTap: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: 'Logout',
                        icon: Icons.logout_rounded,
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        onTap: onLogout,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DashboardProfileScreen extends StatelessWidget {
  const DashboardProfileScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final SantriSession session;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final santri = session.santri;
    final nama = santri?.nama ?? session.user.name;
    final nik = santri?.nik ?? session.user.username;
    final kelas = santri?.kelas ?? '-';
    final khos = santri?.khos ?? '-';
    final status = santri?.status ?? session.user.status;
    final noTlp = santri?.noTlp ?? '-';
    final alamat = santri?.alamat ?? '-';
    final photoUrl = santri?.photoUrl ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFF5F7FB)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF13B3A7), Color(0xFF0E8E98)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 68,
                        height: 68,
                        child: _DetailSantriAvatar(photoUrl: photoUrl),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Menu profil santri',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _ProfileInfoCard(
                items: [
                  _ProfileInfoItem(label: 'NIK', value: nik),
                  _ProfileInfoItem(label: 'Status', value: status),
                  _ProfileInfoItem(label: 'Khos', value: khos),
                  _ProfileInfoItem(label: 'Kelas', value: kelas),
                  _ProfileInfoItem(label: 'No. HP', value: noTlp),
                  _ProfileInfoItem(label: 'Alamat', value: alamat),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  onTap: onLogout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStudentDetailBottomSheet extends StatelessWidget {
  const DashboardStudentDetailBottomSheet({
    required this.session,
  });

  final SantriSession session;

  @override
  Widget build(BuildContext context) {
    final santri = session.santri;
    final nama = santri?.nama ?? session.user.name;
    final nik = santri?.nik ?? session.user.username;
    final kelas = santri?.kelas ?? '-';
    final khos = santri?.khos ?? '-';
    final status = santri?.status ?? session.user.status;
    final noTlp = santri?.noTlp ?? '-';
    final alamat = santri?.alamat ?? '-';
    final kabupaten = _detailExtractKabupaten(alamat);
    final photoUrl = santri?.photoUrl ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E2EC),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF14B8A6), Color(0xFF0F8B8D)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: _DetailSantriAvatar(photoUrl: photoUrl),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nik,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StudentHeroInfoCard(
                              label: 'Tempat Tinggal',
                              value: kabupaten,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StudentHeroInfoCard(
                              label: 'Kontak',
                              value: noTlp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _StudentDetailSection(
                  title: 'Data Santri',
                  subtitle: 'Profil utama santri',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StudentMiniInfoCard(label: 'NIK', value: nik),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StudentMiniInfoCard(label: 'Kelas', value: kelas),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StudentMiniInfoCard(label: 'Status', value: status),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StudentMiniInfoCard(label: 'Khos', value: khos),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StudentMiniInfoCard(
                        label: 'Nama Lengkap',
                        value: nama,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _StudentMiniInfoCard(
                        label: 'No. Telepon',
                        value: noTlp,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _StudentDetailSection(
                  title: 'Domisili',
                  subtitle: 'Alamat santri',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StudentMiniInfoCard(
                              label: 'Kabupaten',
                              value: kabupaten,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StudentMiniInfoCard(
                              label: 'Status Tinggal',
                              value: status,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StudentMiniInfoCard(
                        label: 'Alamat Lengkap',
                        value: alamat,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  label: 'Tutup',
                  icon: Icons.close_rounded,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF17304D),
                  borderColor: const Color(0xFFE2E8F0),
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentHeroInfoCard extends StatelessWidget {
  const _StudentHeroInfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDetailSection extends StatelessWidget {
  const _StudentDetailSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StudentMiniInfoCard extends StatelessWidget {
  const _StudentMiniInfoCard({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: fullWidth ? 4 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.items});

  final List<_ProfileInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ProfileInfoRow(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ProfileInfoItem {
  const _ProfileInfoItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.item});

  final _ProfileInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            item.value,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async => onTap(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: borderColor == null ? null : Border.all(color: borderColor!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSantriAvatar extends StatelessWidget {
  const _DetailSantriAvatar({
    required this.photoUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String photoUrl;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl.trim();
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFFE2E8F0),
        child: const Icon(Icons.person_rounded, color: Color(0xFF6B7A90)),
      );
    }

    return Image.network(
      url,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE2E8F0),
          child: const Icon(Icons.person_rounded, color: Color(0xFF6B7A90)),
        );
      },
    );
  }
}

String _detailExtractKabupaten(String alamat) {
  final trimmed = alamat.trim();
  if (trimmed.isEmpty || trimmed == '-') {
    return '-';
  }

  final parts = trimmed
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  for (final part in parts) {
    final lower = part.toLowerCase();
    if (lower.contains('kabupaten')) {
      return part;
    }
  }

  for (final part in parts) {
    final lower = part.toLowerCase();
    if (lower.contains('kab.') || lower.contains('kab ')) {
      return part;
    }
  }

  return parts.length >= 2 ? parts[1] : parts.first;
}
