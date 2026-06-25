import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../app/app_navigator.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../auth/data/models/santri_session.dart';
import '../../auth/presentation/login_screen.dart';

class AlumniDashboardScreen extends StatefulWidget {
  const AlumniDashboardScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final SantriSession session;
  final Future<void> Function() onLogout;

  @override
  State<AlumniDashboardScreen> createState() => _AlumniDashboardScreenState();
}

class _AlumniDashboardScreenState extends State<AlumniDashboardScreen> {
  int _index = 0;

  void _selectTab(int index) {
    if (_index == index) {
      return;
    }

    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _AlumniHomePage(session: widget.session, onNavigateToTab: _selectTab),
      const _ComingSoonPage(
        title: 'Jaringan Alumni',
        subtitle: 'Ruang untuk memperluas koneksi antar alumni dan angkatan.',
        icon: Icons.groups_rounded,
      ),
      const _AurodPage(),
      const _ComingSoonPage(
        title: 'Aktivitas',
        subtitle: 'Informasi kegiatan, reuni, dan agenda besar alumni.',
        icon: Icons.event_available_rounded,
      ),
      _AlumniProfilePage(session: widget.session, onLogout: _handleLogout),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF17304D).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: _selectTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: const Color(0xFF0F8B8D),
            unselectedItemColor: const Color(0xFF93A4B8),
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_rounded),
                label: 'Network',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_stories_rounded),
                label: 'Aurod',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_rounded),
                label: 'Activities',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await widget.onLogout();
    if (!mounted) {
      return;
    }

    AppNavigator.key.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _AlumniHomePage extends StatelessWidget {
  const _AlumniHomePage({required this.session, required this.onNavigateToTab});

  final SantriSession session;
  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final santri = session.santri;
    final nama = santri?.nama ?? session.user.name;
    final avatarUrl = santri?.photoUrl ?? '';
    final kelas = santri?.kelas?.trim() ?? '';
    final alumniLabel = kelas.isNotEmpty && kelas != '-'
        ? 'Alumni $kelas'
        : 'Alumni MIS Sarang';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6F8FC), Color(0xFFF3F7FA)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamualaikum,',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF7B8A9E),
                                fontSize: 13,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$nama, Alumni',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF17304D),
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alumniLabel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF54657A),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF17304D,
                          ).withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE8EEF5),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF0F8B8D),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF12B4AA), Color(0xFF1382A0)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1382A0).withValues(alpha: 0.24),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selamat Datang Kembali, Akhi.',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tetap terhubung dengan pondok, kabar terbaru, dan keluarga besar alumni.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ketuk profil untuk detail, history mondok, dan logout.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _AlumniShortcut(
                      icon: Icons.volunteer_activism_rounded,
                      label: 'Infaq',
                      gradient: const [Color(0xFFFFE4D6), Color(0xFFFFC9A8)],
                      iconColor: const Color(0xFFE46C29),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Infaq segera hadir.'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AlumniShortcut(
                      icon: Icons.campaign_rounded,
                      label: 'Kabar Pondok',
                      gradient: const [Color(0xFFE7F2FF), Color(0xFFD4E6FF)],
                      iconColor: const Color(0xFF2563EB),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kabar Pondok akan dibuka di sini.'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AlumniShortcut(
                      icon: Icons.groups_rounded,
                      label: 'Jaringan',
                      gradient: const [Color(0xFFE9F9F2), Color(0xFFD8F3E9)],
                      iconColor: const Color(0xFF16A34A),
                      onTap: () => onNavigateToTab(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AlumniShortcut(
                      icon: Icons.menu_book_rounded,
                      label: 'Aurod',
                      gradient: const [Color(0xFFF6E8FF), Color(0xFFE7D7FF)],
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () => onNavigateToTab(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF17304D).withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F8B8D).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFF0F8B8D),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Ketuk profil untuk melihat detail, riwayat mondok, dan logout.',
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
              const _AlumniInfoCard(
                icon: Icons.event_rounded,
                title: "Reuni Akbar Angkatan '15",
                subtitle: 'Ahad, 15 Juni 2025 - 08:00 WIB',
              ),
              const SizedBox(height: 12),
              const _AlumniInfoCard(
                icon: Icons.mosque_rounded,
                title: 'Donasi Pembangunan Masjid Pondok',
                subtitle: 'Sudah terkumpul 75%',
              ),
              const SizedBox(height: 12),
              const _AlumniInfoCard(
                icon: Icons.work_rounded,
                title: 'Peluang Kolaborasi Bisnis Alumni',
                subtitle: 'Mari terhubung dan saling mendukung antar alumni.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlumniShortcut extends StatelessWidget {
  const _AlumniShortcut({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4B5C74),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlumniInfoCard extends StatelessWidget {
  const _AlumniInfoCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17304D).withValues(alpha: 0.05),
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
              color: const Color(0xFFF4F7FA),
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

class _AurodPage extends StatelessWidget {
  const _AurodPage();

  @override
  Widget build(BuildContext context) {
    final entries = <_AurodEntry>[
      const _AurodEntry(
        title: 'Wirid Bakda Shalat Fardhu',
        icon: Icons.handshake_rounded,
        iconBackground: Color(0xFFE2F0E5),
        source: 'Quran NU Online · Wirid Harian',
        arabic:
            'أَسْتَغْفِرُ اللهَ الْعَظِـيْمَ لِيْ وَلِوَالِدَيَّ وَلِجَمِيْعِ الْمُؤْمِنِيْنَ',
        latin:
            'Astaghfirullâh al-‘adhîm lî wa liwâlidayya wa li-jamî‘il-mu’minîn',
        translation:
            'Aku memohon ampunan kepada Allah untuk diriku, kedua orang tua, dan kaum mukmin.',
      ),
      const _AurodEntry(
        title: 'Lâ ilâha illallâh',
        icon: Icons.auto_fix_high_rounded,
        iconBackground: Color(0xFFD8EEF1),
        source: 'Quran NU Online · Wirid Harian',
        arabic: 'لَاإِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ',
        latin: 'Lâ ilâha illallâhu waḫdahu lâ syarîka lah',
        translation:
            'Tiada Tuhan selain Allah Yang Maha Esa, tiada sekutu bagi-Nya.',
      ),
      const _AurodEntry(
        title: 'Doa Salam',
        icon: Icons.wb_twilight_rounded,
        iconBackground: Color(0xFFE7F2FF),
        source: 'Quran NU Online · Wirid Harian',
        arabic:
            'اَللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ وَإِلَيْكَ يَعُوْدُ السَّلَامُ',
        latin: 'Allâhumma antas-salâm wa minkas-salâm wa ilaika ya‘udus-salâm',
        translation:
            'Ya Allah, Engkaulah sumber keselamatan, dari-Mu keselamatan, dan kepada-Mu keselamatan kembali.',
      ),
      const _AurodEntry(
        title: 'Al-Fatihah',
        icon: Icons.menu_book_rounded,
        iconBackground: Color(0xFFF2E4CC),
        source: 'Quran NU Online · Wirid Harian',
        arabic:
            'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ ۝ الْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَ',
        latin: 'Bismillâhir-raḫmânir-raḫîm. Al-ḫamdulillâhi rabbil-‘âlamîn.',
        translation:
            'Dengan nama Allah Yang Maha Pengasih, segala puji bagi Allah Tuhan semesta alam.',
      ),
      const _AurodEntry(
        title: 'Ayat Kursi',
        icon: Icons.shield_rounded,
        iconBackground: Color(0xFFEEDCF1),
        source: 'Quran NU Online · Wirid Harian',
        arabic: 'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيُّوْمُ',
        latin: 'Allâhu lâ ilâha illa huwal-ḫayyul-qayyûm',
        translation:
            'Allah, tidak ada Tuhan selain Dia. Dia Yang Maha Hidup lagi terus mengurus makhluk-Nya.',
      ),
      const _AurodEntry(
        title: 'Tasbih, Tahmid, Takbir',
        icon: Icons.verified_rounded,
        iconBackground: Color(0xFFFDE8D7),
        source: 'Quran NU Online · Wirid Harian',
        arabic:
            'سُبْحَانَ اللهِ ×٣٣ اَلْحَمْدُ لِلّٰهِ ×٣٣ اَللهُ أَكْبَرُ ×٣٣',
        latin: 'Subhânallâh 33x · Al-hamdulillâh 33x · Allâhu akbar 33x',
        translation:
            'Dzikir tasbih, tahmid, dan takbir masing-masing dibaca 33 kali.',
      ),
      const _AurodEntry(
        title: 'Ratib al-Athas',
        icon: Icons.auto_stories_rounded,
        iconBackground: Color(0xFFE8F2FF),
        source: 'Quran NU Online · Kumpulan Ratib',
        arabic: 'Bacaan lengkap Ratib al-Athas',
        latin: 'Buka detail untuk membaca susunan lengkapnya.',
        translation: 'Tampilkan detail bacaan lengkap dalam sheet baca.',
        sourceUrl: 'https://quran.nu.or.id/wirid/ratib',
        sectionStart: 'Ratib al-Athas',
        sectionEnd: 'Ratib al-Haddad',
      ),
      const _AurodEntry(
        title: 'Ratib al-Haddad',
        icon: Icons.menu_book_rounded,
        iconBackground: Color(0xFFDFF5E8),
        source: 'Quran NU Online · Kumpulan Ratib',
        arabic: 'Bacaan lengkap Ratib al-Haddad',
        latin: 'Buka detail untuk membaca susunan lengkapnya.',
        translation: 'Tampilkan detail bacaan lengkap dalam sheet baca.',
        sourceUrl: 'https://quran.nu.or.id/wirid/ratib',
        sectionStart: 'Ratib al-Haddad',
        sectionEnd: 'Ratib Syaikhona Kholil',
      ),
    ];

    Future<void> openDetail(_AurodEntry entry) async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return _AurodDetailSheet(entry: entry);
        },
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aurod & Amalan',
              style: TextStyle(
                color: Color(0xFF17304D),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Wirid harian, yasin, tahlil, dan amalan yang bisa dibaca rutin.',
              style: TextStyle(
                color: Color(0xFF6B7A90),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFECFAF8), Color(0xFFD8F4EE)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF17304D).withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.change_history_rounded,
                        size: 34,
                        color: Color(0xFF0F8B8D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tracker',
                          style: TextStyle(
                            color: Color(0xFF17304D),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Target Harian: 65%',
                          style: TextStyle(
                            color: Color(0xFF4B5C74),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                          child: LinearProgressIndicator(
                            minHeight: 12,
                            value: 0.65,
                            backgroundColor: Color(0xFFD7E4E1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0F8B8D),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Aurod Hari Ini: 8 Amalan',
                          style: TextStyle(
                            color: Color(0xFF17304D),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Curated Amalan',
              style: TextStyle(
                color: Color(0xFF17304D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < entries.length; i++) ...[
              _AurodItemCard(
                icon: entries[i].icon,
                iconBackground: entries[i].iconBackground,
                title: entries[i].title,
                buttonLabel: 'Mulai/Baca',
                onTap: () => openDetail(entries[i]),
              ),
              if (i != entries.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _AurodItemCard extends StatelessWidget {
  const _AurodItemCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17304D).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0F8B8D)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF17304D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F8B8D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _AurodExpandCard extends StatelessWidget {
  const _AurodExpandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7EFF2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17304D).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EEF1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFF0F8B8D),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Surat Yasin',
                  style: TextStyle(
                    color: Color(0xFF17304D),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.expand_less_rounded, color: Color(0xFF17304D)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'اللّهُمَّ عَلَى القُرآنِ...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF17304D),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Ilallal di alih manyaan incampan, milamat bahrin"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5C74),
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _AurodEntry {
  const _AurodEntry({
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.source,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.detailText,
    this.sourceUrl,
    this.sectionStart,
    this.sectionEnd,
  });

  final String title;
  final IconData icon;
  final Color iconBackground;
  final String source;
  final String arabic;
  final String latin;
  final String translation;
  final String? detailText;
  final String? sourceUrl;
  final String? sectionStart;
  final String? sectionEnd;
}

class _AurodDetailSheet extends StatefulWidget {
  const _AurodDetailSheet({required this.entry});

  final _AurodEntry entry;

  @override
  State<_AurodDetailSheet> createState() => _AurodDetailSheetState();
}

class _AurodDetailSheetState extends State<_AurodDetailSheet> {
  late final Future<String> _detailFuture = _loadDetailText(widget.entry);

  Future<String> _loadDetailText(_AurodEntry entry) async {
    if (entry.detailText != null && entry.detailText!.trim().isNotEmpty) {
      return entry.detailText!.trim();
    }

    final sourceUrl = entry.sourceUrl?.trim();
    if (sourceUrl == null || sourceUrl.isEmpty) {
      return 'Data belum tersedia.';
    }

    final response = await http.get(Uri.parse(sourceUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat data ratib.');
    }

    final readable = _htmlToText(response.body);
    final section = _extractSection(
      readable,
      entry.sectionStart,
      entry.sectionEnd,
    );
    final arabicOnly = _extractArabicOnly(
      section.trim().isEmpty ? readable : section,
    );
    return arabicOnly.trim().isEmpty
        ? (section.trim().isEmpty ? readable.trim() : section.trim())
        : arabicOnly.trim();
  }

  String _htmlToText(String html) {
    var text = html;
    text = text.replaceAll(
      RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
      ' ',
    );
    text = text.replaceAll(
      RegExp(r'<style[\s\S]*?</style>', caseSensitive: false),
      ' ',
    );
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    return text.trim();
  }

  String _extractSection(
    String readable,
    String? startMarker,
    String? endMarker,
  ) {
    var section = readable;

    if (startMarker != null && startMarker.trim().isNotEmpty) {
      final startIndex = section.indexOf(startMarker);
      if (startIndex >= 0) {
        section = section.substring(startIndex);
      }
    }

    if (endMarker != null && endMarker.trim().isNotEmpty) {
      final endIndex = section.indexOf(endMarker);
      if (endIndex > 0) {
        section = section.substring(0, endIndex);
      }
    }

    return section;
  }

  String _extractArabicOnly(String text) {
    final lines = text
        .split('\n')
        .map((line) => _keepArabicCharacters(line).trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return lines.join('\n');
  }

  String _keepArabicCharacters(String value) {
    const allowedPunctuation = {
      ' ',
      '\t',
      '\n',
      '\r',
      '،',
      '۔',
      '؛',
      '؟',
      '!',
      '.',
      ',',
      ':',
      ';',
      '-',
      '–',
      '—',
      '(',
      ')',
      '[',
      ']',
      '{',
      '}',
      '\'',
      '"',
      '“',
      '”',
      '‘',
      '’',
      'ـ',
      '…',
      '‰',
      '×',
      '÷',
      '٪',
      '%',
      '+',
      '=',
      '/',
      '\\',
      '۞',
      '۝',
      '۩',
      '﴿',
      '﴾',
      'ٰ',
      'ٔ',
      'ٱ',
      'ۥ',
      'ۦ',
    };

    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final isArabicLetter = rune >= 0x0600 && rune <= 0x06FF;
      final isArabicSupplement = rune >= 0x0750 && rune <= 0x077F;
      final isArabicExtendedA = rune >= 0x08A0 && rune <= 0x08FF;
      final isArabicPresentation = rune >= 0xFB50 && rune <= 0xFDFF;
      final isArabicPresentationB = rune >= 0xFE70 && rune <= 0xFEFF;
      final isAllowed = allowedPunctuation.contains(char);

      if (isArabicLetter ||
          isArabicSupplement ||
          isArabicExtendedA ||
          isArabicPresentation ||
          isArabicPresentationB ||
          isAllowed) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.58,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(widget.entry.icon, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.entry.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.entry.source,
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
                FutureBuilder<String>(
                  future: _detailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: AppSkeletonFrame(
                          child: Column(
                            children: [
                              AppSkeletonBox(height: 120, radius: 22),
                              SizedBox(height: 12),
                              AppSkeletonLine(widthFactor: 0.94, height: 12),
                              SizedBox(height: 8),
                              AppSkeletonLine(widthFactor: 0.88, height: 12),
                              SizedBox(height: 8),
                              AppSkeletonLine(widthFactor: 0.76, height: 12),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _DetailBlock(
                        title: 'Gagal Memuat',
                        content:
                            'Data ratib tidak bisa dimuat sekarang. Coba lagi sebentar.\n\n${snapshot.error}',
                      );
                    }

                    final content = snapshot.data?.trim() ?? '';
                    return _DetailBlock(
                      title: 'Teks Arab',
                      content: content.isEmpty ? 'Data kosong.' : content,
                    );
                  },
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  label: 'Tutup',
                  icon: Icons.close_rounded,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF17304D),
                  borderColor: const Color(0xFFE2E8F0),
                  onTap: () async => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.title,
    required this.content,
    this.align = TextAlign.left,
  });

  final String title;
  final String content;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17304D).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F8B8D),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: align,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17304D).withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF13B3A7), Color(0xFF0E8E98)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icon, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF17304D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7A90), height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlumniProfilePage extends StatelessWidget {
  const _AlumniProfilePage({required this.session, required this.onLogout});

  final SantriSession session;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final santri = session.santri;
    final nama = santri?.nama ?? session.user.name;
    final nik = santri?.nik ?? session.user.username;
    final status = santri?.status ?? session.user.status;
    final khos = santri?.khos ?? '-';
    final kelas = santri?.kelas ?? '-';
    final alamat = santri?.alamat ?? '-';
    final noTlp = santri?.noTlp ?? '-';
    final photoUrl = santri?.photoUrl ?? '';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profil Alumni',
                  style: TextStyle(
                    color: Color(0xFF17304D),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE8EEF5),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Color(0xFF0F8B8D),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF13B3A7), Color(0xFF0E8E98)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: _ProfileAvatar(photoUrl: photoUrl),
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
                        'Profil dan informasi alumni',
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
          _ActionButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String photoUrl;

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
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE2E8F0),
          child: const Icon(Icons.person_rounded, color: Color(0xFF6B7A90)),
        );
      },
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
            color: const Color(0xFF17304D).withValues(alpha: 0.05),
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
            style: const TextStyle(color: Color(0xFF6B7A90), fontSize: 12),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(color: Color(0xFF6B7A90), fontSize: 12),
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
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
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
