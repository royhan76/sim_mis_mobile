import 'package:flutter/material.dart';

import '../../../app/app_navigator.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../auth/data/models/santri_session.dart';
import '../../auth/presentation/login_screen.dart';
import '../../articles/data/repositories/article_repository.dart';
import '../../articles/presentation/article_feed_section.dart';
import '../../articles/presentation/article_list_screen.dart';
import '../../bendahara/presentation/bendahara_screen.dart';
import 'dashboard_detail_sheet.dart';
import '../../maarif/presentation/maarif_screen.dart';
import '../../security/data/models/security_models.dart';
import '../../security/data/repositories/security_repository.dart';
import '../../security/presentation/security_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final SantriSession session;
  final Future<void> Function() onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  int _homeRefreshToken = 0;
  final ArticleRepository _articleRepository = ArticleRepository();

  void _selectTab(int index) {
    if (_index == index) {
      return;
    }

    setState(() {
      _index = index;
    });
  }

  Future<void> _refreshHome() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _homeRefreshToken++;
    });

    await Future<void>.delayed(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomePage(
        session: widget.session,
        onStudentDetailTap: _showStudentDetailSheet,
        onNavigateToTab: _selectTab,
        onOpenMaarif: _openMaarifScreen,
        onOpenSecurity: _openSecurityScreen,
        onOpenBendahara: _openBendaharaScreen,
        onOpenAllMenus: _showAllMenusSheet,
        refreshToken: _homeRefreshToken,
        onRefresh: _refreshHome,
      ),
      const _DhakirohScreen(),
      _ArticleHubScreen(
        repository: _articleRepository,
      ),
      const _AcademicCalendarScreen(),
      DashboardProfileScreen(
        session: widget.session,
        onLogout: _handleLogout,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF172B4D).withValues(alpha: 0.07),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 74,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFDBF4F1),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? const Color(0xFF0F8B8D)
                      : const Color(0xFF94A3B8),
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: 22,
                  color: selected
                      ? const Color(0xFF0F8B8D)
                      : const Color(0xFF94A3B8),
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _selectTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories_rounded),
                  label: 'Dhakiroh',
                ),
                NavigationDestination(
                  icon: Icon(Icons.article_outlined),
                  selectedIcon: Icon(Icons.article_rounded),
                  label: 'Artikel',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Kalender',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showStudentDetailSheet() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DashboardStudentDetailBottomSheet(
          session: widget.session,
        );
      },
    );
  }

  Future<void> _openMaarifScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MaarifScreen(session: widget.session),
      ),
    );
  }

  Future<void> _openSecurityScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecurityScreen(
          session: widget.session,
          initialTab: 0,
        ),
      ),
    );
  }

  Future<void> _openBendaharaScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BendaharaScreen(session: widget.session),
      ),
    );
  }

  Future<void> _showAllMenusSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AllMenusBottomSheet(
          onOpenHome: () async {
            Navigator.of(context).pop();
            _selectTab(0);
          },
          onOpenDhakiroh: () async {
            Navigator.of(context).pop();
            _selectTab(1);
          },
          onOpenArtikel: () async {
            Navigator.of(context).pop();
            _selectTab(2);
          },
          onOpenKalender: () async {
            Navigator.of(context).pop();
            _selectTab(3);
          },
          onOpenProfil: () async {
            Navigator.of(context).pop();
            _selectTab(4);
          },
          onOpenRaport: () async {
            Navigator.of(context).pop();
            await _openMaarifScreen();
          },
          onOpenSpp: () async {
            Navigator.of(context).pop();
            await _openBendaharaScreen();
          },
          onOpenIzin: () async {
            Navigator.of(context).pop();
            await _openSecurityScreen();
          },
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    await widget.onLogout();
    if (!mounted) {
      return;
    }

    AppNavigator.key.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({
    required this.session,
    required this.onStudentDetailTap,
    required this.onNavigateToTab,
    required this.onOpenMaarif,
    required this.onOpenSecurity,
    required this.onOpenBendahara,
    required this.onOpenAllMenus,
    required this.refreshToken,
    required this.onRefresh,
  });

  final SantriSession session;
  final VoidCallback onStudentDetailTap;
  final ValueChanged<int> onNavigateToTab;
  final Future<void> Function() onOpenMaarif;
  final Future<void> Function() onOpenSecurity;
  final Future<void> Function() onOpenBendahara;
  final Future<void> Function() onOpenAllMenus;
  final int refreshToken;
  final Future<void> Function() onRefresh;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final SecurityRepository _securityRepository = SecurityRepository();
  late Future<SecurityOverview> _securityFuture;

  @override
  void initState() {
    super.initState();
    _securityFuture = _loadSecurityOverview();
  }

  @override
  void didUpdateWidget(covariant _HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(() {
        _securityFuture = _loadSecurityOverview();
      });
    }
  }

  Future<SecurityOverview> _loadSecurityOverview() {
    return _securityRepository.loadOverview(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    final santri = widget.session.santri;
    final nama = santri?.nama ?? widget.session.user.name;
    final avatarUrl = santri?.photoUrl ?? '';
    final status = santri?.status ?? widget.session.user.status;
    final kelas = santri?.kelas ?? '-';
    final khos = santri?.khos ?? '-';
    final alamat = santri?.alamat ?? '-';
    const topHeaderHeight = 62.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFF5F7FB)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: widget.onRefresh,
              color: const Color(0xFF0F8B8D),
              child: SingleChildScrollView(
                key: ValueKey<int>(widget.refreshToken),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(18, 14 + topHeaderHeight + 16, 18, 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF8FAFF), Color(0xFFF1F5FB)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE5ECF4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF172B4D).withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: _StudentIdentityCard(
                        nama: nama,
                        status: status,
                        kelas: kelas,
                        khos: khos,
                        alamat: alamat,
                        photoUrl: avatarUrl,
                        securityFuture: _securityFuture,
                        onTap: widget.onStudentDetailTap,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _QuickAction(
                          icon: Icons.menu_book_rounded,
                          label: 'Raport',
                          color: const Color(0xFF2563EB),
                          onTap: widget.onOpenMaarif,
                        ),
                        _QuickAction(
                          icon: Icons.campaign_rounded,
                          label: 'Berita',
                          color: const Color(0xFFF59E0B),
                          onTap: () async => widget.onNavigateToTab(2),
                        ),
                        _QuickAction(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'SPP',
                          color: const Color(0xFF10B981),
                          onTap: widget.onOpenBendahara,
                        ),
                        _QuickAction(
                          icon: Icons.shield_outlined,
                          label: 'Keamanan',
                          color: const Color(0xFF8B5CF6),
                          onTap: widget.onOpenSecurity,
                        ),
                        _QuickAction(
                          icon: Icons.grid_view_rounded,
                          label: 'Menu',
                          color: const Color(0xFF0F8B8D),
                          onTap: widget.onOpenAllMenus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
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
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F8B8D).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.touch_app_rounded,
                              color: Color(0xFF0F8B8D),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Tarik ke bawah untuk menyegarkan data beranda.',
                              style: TextStyle(
                                color: Color(0xFF6B7A90),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Informasi Terbaru',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF17304D),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const _LatestInfoCard(
                      icon: Icons.event_rounded,
                      title: 'Pertemuan Wali Santri',
                      subtitle: 'Ahad, 15 Juni 2024 - 08:00 WIB',
                    ),
                    const SizedBox(height: 12),
                    const _LatestInfoCard(
                      icon: Icons.notifications_active_rounded,
                      title: 'Pengumuman Pondok',
                      subtitle: 'Jadwal kegiatan pekan ini sudah diperbarui.',
                    ),
                    const SizedBox(height: 12),
                    const _LatestInfoCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Info Keuangan',
                      subtitle: 'Tagihan bulan berjalan sudah tersedia.',
                    ),
                    const SizedBox(height: 18),
                    ArticleFeedSection(
                      key: ValueKey<int>(widget.refreshToken),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 18,
              right: 18,
              child: Container(
                height: topHeaderHeight,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5ECF4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF172B4D).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFE5ECF4)),
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  'assets/images/logo_pondok_teks.png',
                                  fit: BoxFit.contain,
                                  height: 30,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const _HeaderActionButton(icon: Icons.notifications_none_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null ? null : () async => onTap!(),
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 54,
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF4B5C74),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllMenusBottomSheet extends StatelessWidget {
  const _AllMenusBottomSheet({
    required this.onOpenHome,
    required this.onOpenDhakiroh,
    required this.onOpenArtikel,
    required this.onOpenKalender,
    required this.onOpenProfil,
    required this.onOpenRaport,
    required this.onOpenSpp,
    required this.onOpenIzin,
  });

  final Future<void> Function() onOpenHome;
  final Future<void> Function() onOpenDhakiroh;
  final Future<void> Function() onOpenArtikel;
  final Future<void> Function() onOpenKalender;
  final Future<void> Function() onOpenProfil;
  final Future<void> Function() onOpenRaport;
  final Future<void> Function() onOpenSpp;
  final Future<void> Function() onOpenIzin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                'Semua Menu',
                style: TextStyle(
                  color: Color(0xFF17304D),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Akses cepat ke seluruh fitur utama dengan tampilan yang rapi dan ringan.',
                style: TextStyle(
                  color: Color(0xFF6B7A90),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: [
                  _AppMenuTile(
                    icon: Icons.home_rounded,
                    label: 'Beranda',
                    color: const Color(0xFF0F8B8D),
                    onTap: onOpenHome,
                  ),
                  _AppMenuTile(
                    icon: Icons.auto_stories_rounded,
                    label: 'Dhakiroh',
                    color: const Color(0xFF2563EB),
                    onTap: onOpenDhakiroh,
                  ),
                  _AppMenuTile(
                    icon: Icons.article_rounded,
                    label: 'Artikel',
                    color: const Color(0xFFF59E0B),
                    onTap: onOpenArtikel,
                  ),
                  _AppMenuTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Kalender',
                    color: const Color(0xFF10B981),
                    onTap: onOpenKalender,
                  ),
                  _AppMenuTile(
                    icon: Icons.menu_book_rounded,
                    label: 'Raport',
                    color: const Color(0xFF4F46E5),
                    onTap: onOpenRaport,
                  ),
                  _AppMenuTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'SPP',
                    color: const Color(0xFF059669),
                    onTap: onOpenSpp,
                  ),
                  _AppMenuTile(
                    icon: Icons.shield_outlined,
                    label: 'Keamanan',
                    color: const Color(0xFF8B5CF6),
                    onTap: onOpenIzin,
                  ),
                  _AppMenuTile(
                    icon: Icons.manage_accounts_rounded,
                    label: 'Profil',
                    color: const Color(0xFFEC4899),
                    onTap: onOpenProfil,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppMenuTile extends StatelessWidget {
  const _AppMenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async => onTap(),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172B4D).withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
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

class _DhakirohScreen extends StatelessWidget {
  const _DhakirohScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFF5F7FB)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
          children: const [
            _SectionHeader(
              eyebrow: 'Dhakiroh',
              title: 'Wirid dan doa harian',
              subtitle: 'Kumpulan amalan yang siap dibaca kapan saja.',
            ),
            SizedBox(height: 18),
            _FeatureHighlightCard(
              accentColors: [Color(0xFF0F8B8D), Color(0xFF14B8A6)],
              icon: Icons.menu_book_rounded,
              title: 'Wirid Harian',
              subtitle: 'Susunan wirid praktis untuk pagi, sore, dan setelah sholat.',
            ),
            SizedBox(height: 14),
            _FeatureHighlightCard(
              accentColors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              icon: Icons.favorite_rounded,
              title: 'Doa Pilihan',
              subtitle: 'Doa-doa penting yang mudah diakses saat dibutuhkan.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleHubScreen extends StatelessWidget {
  const _ArticleHubScreen({
    required this.repository,
  });

  final ArticleRepository repository;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFF5F7FB)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
          children: [
            Row(
              children: [
                const Expanded(
                  child: _SectionHeader(
                    eyebrow: 'Artikel',
                    title: 'Wawasan dan kabar pondok',
                    subtitle: 'Update terbaru dari website utama pondok.',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ArticleListScreen(repository: repository),
                      ),
                    );
                  },
                  child: const Text('Semua'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ArticleFeedSection(),
          ],
        ),
      ),
    );
  }
}

class _AcademicCalendarScreen extends StatelessWidget {
  const _AcademicCalendarScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFF5F7FB)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
          children: const [
            _SectionHeader(
              eyebrow: 'Kalender Akademik',
              title: 'Agenda penting santri',
              subtitle: 'Jadwal inti yang perlu dipantau selama periode berjalan.',
            ),
            SizedBox(height: 18),
            _TimelineAgendaCard(
              monthLabel: 'JUNI',
              dateLabel: '15',
              title: 'Pertemuan Wali Santri',
              subtitle: 'Ahad, 15 Juni 2024 - 08:00 WIB',
            ),
            SizedBox(height: 14),
            _TimelineAgendaCard(
              monthLabel: 'JULI',
              dateLabel: '01',
              title: 'Awal Kegiatan Semester',
              subtitle: 'Pembukaan kembali kegiatan belajar santri.',
            ),
            SizedBox(height: 14),
            _TimelineAgendaCard(
              monthLabel: 'JULI',
              dateLabel: '12',
              title: 'Evaluasi Pekanan',
              subtitle: 'Monitoring perkembangan akademik dan kedisiplinan.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF0F8B8D),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17304D),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FeatureHighlightCard extends StatelessWidget {
  const _FeatureHighlightCard({
    required this.accentColors,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final List<Color> accentColors;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: accentColors,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentColors.first.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineAgendaCard extends StatelessWidget {
  const _TimelineAgendaCard({
    required this.monthLabel,
    required this.dateLabel,
    required this.title,
    required this.subtitle,
  });

  final String monthLabel;
  final String dateLabel;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF8F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  monthLabel,
                  style: const TextStyle(
                    color: Color(0xFF0F8B8D),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: Color(0xFF17304D),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7A90),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestInfoCard extends StatelessWidget {
  const _LatestInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0F8B8D)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF17304D),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7A90),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SantriAvatar extends StatelessWidget {
  const _SantriAvatar({
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

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EEF6)),
          ),
          child: Icon(icon, color: const Color(0xFF32455B), size: 22),
        ),
      ),
    );
  }
}

class _StudentIdentityCard extends StatelessWidget {
  const _StudentIdentityCard({
    required this.nama,
    required this.status,
    required this.kelas,
    required this.khos,
    required this.alamat,
    required this.photoUrl,
    required this.securityFuture,
    this.onTap,
  });

  final String nama;
  final String status;
  final String kelas;
  final String khos;
  final String alamat;
  final String photoUrl;
  final Future<SecurityOverview> securityFuture;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final kabupaten = _extractKabupaten(alamat);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172B4D).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 112,
                    height: 148,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF172B4D).withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _SantriPortrait(photoUrl: photoUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF16283E),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kabupaten,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF7B8A9C),
                                fontSize: 11,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Status: $status',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF556476),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kelas: $kelas',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF556476),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Khos: $khos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF556476),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<SecurityOverview>(
                          future: securityFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const _SecurityPresenceIndicator.loading();
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return const _SecurityPresenceIndicator.unknown();
                            }

                            final hasActiveIzinKeluar =
                                snapshot.data!.izin.any((item) => _isIzinKeluarActive(item));

                            return _SecurityPresenceIndicator(
                              isInPondok: !hasActiveIzinKeluar,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SantriPortrait extends StatelessWidget {
  const _SantriPortrait({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl.trim();
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFFF3F6FA),
        alignment: Alignment.center,
        child: const Icon(
          Icons.person_rounded,
          color: Color(0xFF94A3B8),
          size: 42,
        ),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.white),
          Image.network(
            url,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            color: Colors.white,
            colorBlendMode: BlendMode.dstOver,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF3F6FA),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF94A3B8),
                  size: 42,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _extractKabupaten(String alamat) {
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

bool _isIzinKeluarActive(SecurityIzinItem item) {
  final tanggalMasuk = item.tanggalMasuk.trim();
  return tanggalMasuk.isEmpty || tanggalMasuk == '-';
}

class _SecurityPresenceIndicator extends StatelessWidget {
  const _SecurityPresenceIndicator({
    required this.isInPondok,
    this.isLoading = false,
    this.isUnknown = false,
  });

  const _SecurityPresenceIndicator.loading()
      : isInPondok = false,
        isLoading = true,
        isUnknown = false;

  const _SecurityPresenceIndicator.unknown()
      : isInPondok = false,
        isLoading = false,
        isUnknown = true;

  final bool isInPondok;
  final bool isLoading;
  final bool isUnknown;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppSkeletonFrame(
        child: AppSkeletonBox(height: 38, radius: 14),
      );
    }

    final backgroundColor = isUnknown
        ? const Color(0xFFF3F4F6)
        : isInPondok
            ? const Color(0xFFEAF8EF)
            : const Color(0xFFFDEBEC);
    final foregroundColor = isUnknown
        ? const Color(0xFF6B7280)
        : isInPondok
            ? const Color(0xFF15803D)
            : const Color(0xFFDC2626);
    final icon = isUnknown
            ? Icons.help_outline_rounded
            : isInPondok
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded;
    final label = isUnknown
            ? 'Status keamanan belum tersedia'
            : isInPondok
                ? 'Berada di pondok'
                : 'Sedang izin keluar pondok';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foregroundColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


