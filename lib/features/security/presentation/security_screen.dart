import 'package:flutter/material.dart';

import '../../auth/data/models/santri_session.dart';
import '../../auth/data/services/auth_api_service.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../data/models/security_models.dart';
import '../data/repositories/security_repository.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({
    super.key,
    required this.session,
    this.initialTab = 0,
  });

  final SantriSession session;
  final int initialTab;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final SecurityRepository _repository = SecurityRepository();
  late Future<SecurityOverview> _future = _load();
  late int _selectedTab = widget.initialTab.clamp(0, 1);

  Future<SecurityOverview> _load() {
    return _repository.loadOverview(widget.session);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: FutureBuilder<SecurityOverview>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppPageSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat data keamanan.';

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 40,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Data keamanan belum bisa dimuat',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF17304D),
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF6B7A90),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final overview = snapshot.data!;
            final totalPelanggaran = overview.pelanggaran.length;
            final totalIzin = overview.izin.length;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7F9FC), Color(0xFFF4F7FB)],
                ),
              ),
              child: _SecurityListView(
                session: widget.session,
                title: _selectedTab == 0 ? 'Laporan Pelanggaran' : 'Izin Keluar Pondok',
                subtitle: _selectedTab == 0
                    ? 'Riwayat pelanggaran santri yang tersimpan di sistem.'
                    : 'Daftar izin keluar dan masuk pondok santri.',
                overview: overview,
                recordsCount: _selectedTab == 0 ? totalPelanggaran : totalIzin,
                tabIndex: _selectedTab,
                onTabChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                onRefresh: _reload,
                buildBody: () {
                  final body = _selectedTab == 0
                      ? (overview.pelanggaran.isEmpty
                          ? const _EmptyState(
                              icon: Icons.rule_rounded,
                              title: 'Belum ada pelanggaran',
                              subtitle: 'Kalau ada pelanggaran, datanya akan tampil di sini.',
                            )
                          : Column(
                              children: [
                                for (var index = 0; index < overview.pelanggaran.length; index++) ...[
                                  if (index > 0) const SizedBox(height: 12),
                                  _PelanggaranCard(
                                    item: overview.pelanggaran[index],
                                    onTap: () => _showPelanggaranDetail(
                                      context,
                                      overview.santri,
                                      overview.pelanggaran[index],
                                    ),
                                  ),
                                ],
                              ],
                            ))
                      : (overview.izin.isEmpty
                          ? const _EmptyState(
                              icon: Icons.door_front_door_rounded,
                              title: 'Belum ada izin keluar',
                              subtitle: 'Riwayat izin keluar pondok akan tampil di sini.',
                            )
                          : Column(
                              children: [
                                for (var index = 0; index < overview.izin.length; index++) ...[
                                  if (index > 0) const SizedBox(height: 12),
                                  _IzinCard(
                                    item: overview.izin[index],
                                    onTap: () => _showIzinDetail(
                                      context,
                                      overview.santri,
                                      overview.izin[index],
                                    ),
                                  ),
                                ],
                              ],
                            ));

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(fade);

                      return FadeTransition(
                        opacity: fade,
                        child: SlideTransition(
                          position: slide,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedTab),
                      child: body,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPelanggaranDetail(
    BuildContext context,
    SantriProfile santri,
    SecurityPelanggaranItem item,
  ) {
    final severityLabel = _severityStyle(_normalizeSeverity(item.tingkat)).label;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DetailSheet(
          title: 'Detail Pelanggaran',
          profile: santri,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Tanggal', value: item.tanggal),
              const SizedBox(height: 10),
              _DetailRow(label: 'Tingkat', value: severityLabel),
              const SizedBox(height: 10),
              _DetailRow(label: 'Pelanggaran', value: item.pelanggaran),
              const SizedBox(height: 10),
              _DetailRow(label: 'Tanggal Input', value: item.tanggalInput),
            ],
          ),
        );
      },
    );
  }

  void _showIzinDetail(
    BuildContext context,
    SantriProfile santri,
    SecurityIzinItem item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DetailSheet(
          title: 'Detail Izin Keluar Pondok',
          profile: santri,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Tujuan', value: item.tujuan),
              const SizedBox(height: 10),
              _DetailRow(label: 'Batas Hari', value: item.batasHari == '-' ? '-' : '${item.batasHari} hari'),
              const SizedBox(height: 10),
              _DetailRow(label: 'Tanggal Keluar', value: item.tanggalKeluar),
              const SizedBox(height: 10),
              _DetailRow(label: 'Tanggal Masuk', value: item.tanggalMasuk),
              const SizedBox(height: 10),
              _DetailRow(label: 'Keterangan', value: item.keterangan),
            ],
          ),
        );
      },
    );
  }
}

class _SecurityListView extends StatelessWidget {
  const _SecurityListView({
    required this.session,
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.recordsCount,
    required this.tabIndex,
    required this.onTabChanged,
    required this.onRefresh,
    required this.buildBody,
  });

  final SantriSession session;
  final String title;
  final String subtitle;
  final SecurityOverview overview;
  final int recordsCount;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function() onRefresh;
  final Widget Function() buildBody;

  @override
  Widget build(BuildContext context) {
    final santri = session.santri;
    final nama = santri?.nama ?? session.user.name;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF0F8B8D),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF13B3A7), Color(0xFF0E8E98)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E8E98).withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: (santri?.photoUrl ?? '').isEmpty
                        ? Container(
                            color: Colors.white.withValues(alpha: 0.18),
                            child: const Icon(Icons.person_rounded, color: Colors.white),
                          )
                        : Image.network(
                            santri!.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withValues(alpha: 0.18),
                                child: const Icon(Icons.person_rounded, color: Colors.white),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${santri?.status ?? session.user.status}',
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
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF172B4D).withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onTabChanged(0),
                  child: _TabChip(
                    label: 'Pelanggaran',
                    icon: Icons.report_rounded,
                    active: tabIndex == 0,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => onTabChanged(1),
                  child: _TabChip(
                    label: 'Izin Keluar',
                    icon: Icons.logout_rounded,
                    active: tabIndex == 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          buildBody(),
        ],
      ),
    );
  }
}

class _PelanggaranCard extends StatelessWidget {
  const _PelanggaranCard({
    required this.item,
    required this.onTap,
  });

  final SecurityPelanggaranItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final severity = _normalizeSeverity(item.tingkat);
    final severityStyle = _severityStyle(severity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7EEF6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172B4D).withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: severityStyle.background,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(severityStyle.icon, color: severityStyle.foreground, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SeverityChip(style: severityStyle),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.pelanggaran,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFF17304D),
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TinyTag(
                          label: item.tanggal,
                          icon: Icons.calendar_today_rounded,
                        ),
                        _MiniPill(
                          icon: Icons.history_rounded,
                          label: item.tanggalInput,
                        ),
                        _MiniPill(
                          icon: Icons.touch_app_rounded,
                          label: 'Ketuk detail',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Detail pelanggaran tersimpan dan bisa dibuka kapan saja.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7A90),
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6C3D4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IzinCard extends StatelessWidget {
  const _IzinCard({
    required this.item,
    required this.onTap,
  });

  final SecurityIzinItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasTanggalMasuk = item.tanggalMasuk.trim() != '-' && item.tanggalMasuk.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7EEF6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172B4D).withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.16),
                          const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.door_front_door_rounded, color: Color(0xFF8B5CF6), size: 29),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.tujuan,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: const Color(0xFF17304D),
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _TinyTag(
                              label: item.tanggalKeluar,
                              icon: Icons.calendar_month_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MiniPill(
                              icon: Icons.timelapse_rounded,
                              label: item.batasHari == '-' ? 'Batas - hari' : 'Batas ${item.batasHari} hari',
                            ),
                            if (hasTanggalMasuk)
                              _MiniPill(
                                icon: Icons.login_rounded,
                                label: item.tanggalMasuk,
                              ),
                            _MiniPill(
                              icon: Icons.touch_app_rounded,
                              label: 'Ketuk detail',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.keterangan,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7A90),
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hasTanggalMasuk
                              ? 'Izin keluar aktif dengan riwayat masuk tersimpan.'
                              : 'Izin keluar tersimpan dan siap dibuka detailnya.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7A90),
                                height: 1.45,
                              ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6C3D4)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({
    required this.title,
    required this.profile,
    required this.child,
  });

  final String title;
  final SantriProfile profile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
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
              _ProfileHeader(profile: profile, title: title),
              const SizedBox(height: 18),
              Container(
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
                child: child,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.title,
  });

  final SantriProfile profile;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15B8A6), Color(0xFF0E8E98)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 64,
              height: 64,
              child: profile.photoUrl.isEmpty
                  ? Container(
                      color: Colors.white.withValues(alpha: 0.18),
                      child: const Icon(Icons.person_rounded, color: Colors.white),
                    )
                  : Image.network(
                      profile.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white.withValues(alpha: 0.18),
                        child: const Icon(Icons.person_rounded, color: Colors.white),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniBadge(label: 'Khos ${profile.khos}'),
                    _MiniBadge(label: 'Kelas ${profile.kelas}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
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
            value,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF0F8B8D).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, size: 42, color: const Color(0xFF0F8B8D)),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF17304D),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0F8B8D) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFF0F8B8D) : const Color(0xFFE2E8F0),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF0F8B8D).withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 220),
            scale: active ? 1.04 : 1.0,
            child: Icon(
              icon,
              size: 16,
              color: active ? Colors.white : const Color(0xFF4B5C74),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF4B5C74),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF5D6C82),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5D6C82),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2EAF2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF4B5C74),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4B5C74),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityStyle {
  const _SeverityStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;
}

String _normalizeSeverity(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.contains('ringan')) {
    return 'ringan';
  }
  if (normalized.contains('sedang')) {
    return 'sedang';
  }
  if (normalized.contains('berat')) {
    return 'berat';
  }
  return normalized.isEmpty ? '-' : normalized;
}

_SeverityStyle _severityStyle(String severity) {
  switch (severity) {
    case 'ringan':
      return const _SeverityStyle(
        label: 'Ringan',
        background: Color(0xFFE8F8EF),
        foreground: Color(0xFF1E8E5A),
        icon: Icons.spa_rounded,
      );
    case 'sedang':
      return const _SeverityStyle(
        label: 'Sedang',
        background: Color(0xFFFFF1DD),
        foreground: Color(0xFFCB7A14),
        icon: Icons.wb_sunny_rounded,
      );
    case 'berat':
      return const _SeverityStyle(
        label: 'Berat',
        background: Color(0xFFFEE6E8),
        foreground: Color(0xFFE11D48),
        icon: Icons.dangerous_rounded,
      );
    default:
      return const _SeverityStyle(
        label: 'Lainnya',
        background: Color(0xFFE9EEF5),
        foreground: Color(0xFF64748B),
        icon: Icons.label_rounded,
      );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.style,
  });

  final _SeverityStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
