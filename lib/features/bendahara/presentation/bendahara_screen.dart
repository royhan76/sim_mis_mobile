import 'package:flutter/material.dart';

import '../../auth/data/models/santri_session.dart';
import '../../auth/data/services/auth_api_service.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../data/models/bendahara_models.dart';
import '../data/repositories/bendahara_repository.dart';

class BendaharaScreen extends StatefulWidget {
  const BendaharaScreen({
    super.key,
    required this.session,
  });

  final SantriSession session;

  @override
  State<BendaharaScreen> createState() => _BendaharaScreenState();
}

class _BendaharaScreenState extends State<BendaharaScreen> {
  final BendaharaRepository _repository = BendaharaRepository();
  late Future<BendaharaOverview> _future = _load();

  Future<BendaharaOverview> _load() => _repository.loadOverview(widget.session);

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _showUnitPaidDetail(
    BuildContext context,
    List<BendaharaUnitItem> items,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UnitPaidDetailSheet(items: items),
    );
  }

  Future<void> _showSyahriyahDetail(
    BuildContext context,
    List<BendaharaSyahriyahItem> paidItems,
    List<String> unpaidMonths,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SyahriyahDetailSheet(
        paidItems: paidItems,
        unpaidMonths: unpaidMonths,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FC), Color(0xFFF3F6FB)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<BendaharaOverview>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppPageSkeleton();
              }

              if (snapshot.hasError) {
                final message = snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Gagal memuat data bendahara.';
                return _ErrorState(message: message, onRetry: _reload);
              }

              final overview = snapshot.data!;
              final santri = overview.santri;
              final dueSyahriyahMonths = _resolveDueSyahriyahMonths(
                overview.syahriyahBelumBayar,
              );

              return RefreshIndicator(
                onRefresh: _reload,
                color: const Color(0xFF0F8B8D),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                  children: [
                    _Header(
                      santri: widget.session.santri,
                      fallbackNama: '${santri['nama'] ?? '-'}',
                      fallbackStatus: '${santri['status'] ?? '-'}',
                    ),
                    const SizedBox(height: 16),
                    _SummaryStrip(
                      items: overview.summary,
                      onUnitTap: () => _showUnitPaidDetail(
                        context,
                        overview.unitSudahBayar,
                      ),
                      onSyahriyahTap: () => _showSyahriyahDetail(
                        context,
                        overview.syahriyahSudahBayar,
                        overview.syahriyahBelumBayar,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (dueSyahriyahMonths.isNotEmpty) ...[
                      _SyahriyahDueNotice(
                        months: dueSyahriyahMonths,
                        tahunHijriyah: overview.tahunHijriyah,
                        nominalPerBulan: overview.syahriyahNominal,
                      ),
                      const SizedBox(height: 18),
                    ],
                    const _SectionTitle(
                      title: 'Unit Belum Bayar',
                      subtitle: 'Daftar tagihan yang masih tersisa.',
                    ),
                    const SizedBox(height: 12),
                    if (overview.unitBelumBayar.isEmpty)
                      const _EmptyMessage(
                        icon: Icons.receipt_long_rounded,
                        title: 'Semua unit sudah dibayar',
                        subtitle: 'Tidak ada unit yang tersisa saat ini.',
                      )
                    else
                      ...overview.unitBelumBayar.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _UnitTagihanCard(item: item),
                        ),
                      ),
                    const SizedBox(height: 18),
                    const _SectionTitle(
                      title: 'Transaksi Terakhir',
                      subtitle: 'Detail riwayat pembayaran terbaru.',
                    ),
                    const SizedBox(height: 12),
                    if (overview.transaksi.isEmpty)
                      const _EmptyMessage(
                        icon: Icons.history_rounded,
                        title: 'Belum ada transaksi',
                        subtitle: 'Riwayat transaksi pembayaran akan tampil di sini.',
                      )
                    else
                      ...overview.transaksi.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransaksiCard(item: item),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.santri,
    required this.fallbackNama,
    required this.fallbackStatus,
  });

  final SantriProfile? santri;
  final String fallbackNama;
  final String fallbackStatus;

  @override
  Widget build(BuildContext context) {
    final nama = santri?.nama.isNotEmpty == true ? santri!.nama : fallbackNama;
    final status = santri?.status.isNotEmpty == true ? santri!.status : fallbackStatus;
    final photoUrl = santri?.photoUrl ?? '';

    return Container(
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
              child: photoUrl.isEmpty
                  ? Container(
                      color: Colors.white.withValues(alpha: 0.18),
                      child: const Icon(Icons.person_rounded, color: Colors.white),
                    )
                  : Image.network(
                      photoUrl,
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
                  'Status: $status',
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
    );
  }
}

const List<String> _hijriMonthOrder = [
  'Syawal',
  'Dzulqodah',
  'Dzulhijjah',
  'Muharram',
  'Shafar',
  'Rabiul Awal',
  'Rabiul Akhir',
  'Jumadil Awal',
  'Jumadil Akhir',
  'Rajab',
  'Syaban',
  'Ramadhan',
];

List<String> _resolveDueSyahriyahMonths(List<String> unpaidMonths) {
  if (unpaidMonths.isEmpty) {
    return const [];
  }

  final currentMonth = _currentHijriMonthName();
  if (currentMonth == null) {
    return unpaidMonths;
  }

  final currentIndex = _hijriMonthOrder.indexOf(currentMonth);
  if (currentIndex == -1) {
    return unpaidMonths;
  }

  return unpaidMonths.where((month) {
    final index = _hijriMonthOrder.indexOf(month);
    return index != -1 && index <= currentIndex;
  }).toList();
}

String? _currentHijriMonthName() {
  final now = DateTime.now();
  final julianDay = ((1461 * (now.year + 4800 + ((now.month - 14) ~/ 12))) ~/ 4) +
      ((367 * (now.month - 2 - 12 * (((now.month - 14) ~/ 12)))) ~/ 12) -
      ((3 * ((now.year + 4900 + ((now.month - 14) ~/ 12)) ~/ 100)) ~/ 4) +
      now.day -
      32075;

  final l = julianDay - 1948440 + 10632;
  final n = ((l - 1) ~/ 10631);
  var ll = l - 10631 * n + 354;
  final j = (((10985 - ll) ~/ 5316) * ((50 * ll) ~/ 17719)) +
      ((ll ~/ 5670) * ((43 * ll) ~/ 15238));
  ll = ll - (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) - ((j ~/ 16) * ((15238 * j) ~/ 43)) + 29;
  final month = (24 * ll) ~/ 709;

  const monthNames = [
    'Muharram',
    'Shafar',
    'Rabiul Awal',
    'Rabiul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Syaban',
    'Ramadhan',
    'Syawal',
    'Dzulqodah',
    'Dzulhijjah',
  ];

  if (month < 1 || month > 12) {
    return null;
  }

  return monthNames[month - 1];
}

String _formatRupiahValue(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    final reverseIndex = digits.length - index;
    buffer.write(digits[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

class _SyahriyahDueNotice extends StatelessWidget {
  const _SyahriyahDueNotice({
    required this.months,
    required this.tahunHijriyah,
    required this.nominalPerBulan,
  });

  final List<String> months;
  final String tahunHijriyah;
  final int nominalPerBulan;

  @override
  Widget build(BuildContext context) {
    final total = nominalPerBulan * months.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Syahriyah Yang Perlu Dibayar',
                      style: TextStyle(
                        color: Color(0xFF17304D),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tunggakan sampai bulan berjalan $tahunHijriyah.',
                      style: const TextStyle(
                        color: Color(0xFF7C5A10),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: months
                .map(
                  (month) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      month,
                      style: const TextStyle(
                        color: Color(0xFF8A5A00),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (nominalPerBulan > 0) ...[
            const SizedBox(height: 14),
            Text(
              'Per bulan: Rp ${_formatRupiahValue(nominalPerBulan)}',
              style: const TextStyle(
                color: Color(0xFF7C5A10),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total sementara: Rp ${_formatRupiahValue(total)}',
              style: const TextStyle(
                color: Color(0xFFD97706),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.items,
    required this.onUnitTap,
    required this.onSyahriyahTap,
  });

  final List<BendaharaSummaryItem> items;
  final VoidCallback onUnitTap;
  final VoidCallback onSyahriyahTap;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where((item) => item.label.toLowerCase() != 'total dibayar')
        .toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: visibleItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final tone = _summaryToneFor(index);
        final normalized = item.label.toLowerCase();
        final onTap = normalized.contains('unit')
            ? onUnitTap
            : normalized.contains('syahriyah')
                ? onSyahriyahTap
                : null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: tone.gradient,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: tone.shadow.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                height: 64,
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, 0.15),
                      child: Text(
                        '${item.value}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tone.foreground.withValues(alpha: 0.28),
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _summaryIconFor(item.label),
                            color: tone.foreground.withValues(alpha: 0.94),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tone.foreground.withValues(alpha: 0.92),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryTone {
  const _SummaryTone({
    required this.gradient,
    required this.foreground,
    required this.shadow,
  });

  final List<Color> gradient;
  final Color foreground;
  final Color shadow;
}

_SummaryTone _summaryToneFor(int index) {
  const tones = [
    _SummaryTone(
      gradient: [Color(0xFF143C8C), Color(0xFF1F6BFF)],
      foreground: Colors.white,
      shadow: Color(0xFF1F6BFF),
    ),
    _SummaryTone(
      gradient: [Color(0xFF0F8B8D), Color(0xFF34C7A1)],
      foreground: Colors.white,
      shadow: Color(0xFF34C7A1),
    ),
    _SummaryTone(
      gradient: [Color(0xFF5B3DF5), Color(0xFF8A6DFF)],
      foreground: Colors.white,
      shadow: Color(0xFF8A6DFF),
    ),
  ];

  return tones[index % tones.length];
}

IconData _summaryIconFor(String label) {
  final normalized = label.toLowerCase();

  if (normalized.contains('unit')) {
    return Icons.layers_rounded;
  }

  if (normalized.contains('syahriyah')) {
    return Icons.calendar_month_rounded;
  }

  return Icons.pie_chart_rounded;
}

class _UnitPaidDetailSheet extends StatelessWidget {
  const _UnitPaidDetailSheet({required this.items});

  final List<BendaharaUnitItem> items;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.76,
      minChildSize: 0.56,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DFEA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    const _DetailIntro(
                      title: 'Detail Unit Dibayar',
                      subtitle: 'Daftar unit pembayaran yang sudah tercatat untuk santri ini.',
                    ),
                    const SizedBox(height: 14),
                    if (items.isEmpty)
                      const _EmptyMessage(
                        icon: Icons.payments_rounded,
                        title: 'Belum ada pembayaran unit',
                        subtitle: 'Unit pembayaran yang sudah dibayar akan tampil di sini.',
                      )
                    else
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _UnitCard(item: item),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SyahriyahDetailSheet extends StatelessWidget {
  const _SyahriyahDetailSheet({
    required this.paidItems,
    required this.unpaidMonths,
  });

  final List<BendaharaSyahriyahItem> paidItems;
  final List<String> unpaidMonths;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.58,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DFEA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    const _DetailIntro(
                      title: 'Detail Syahriyah Dibayar',
                      subtitle: 'Riwayat syahriyah yang sudah dibayar dan bulan yang masih tersisa.',
                    ),
                    const SizedBox(height: 14),
                    if (paidItems.isEmpty)
                      const _EmptyMessage(
                        icon: Icons.calendar_month_rounded,
                        title: 'Belum ada syahriyah',
                        subtitle: 'Riwayat syahriyah akan tampil di sini.',
                      )
                    else
                      ...paidItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SyahriyahCard(item: item),
                        ),
                      ),
                    if (unpaidMonths.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const _SectionTitle(
                        title: 'Syahriyah Belum Bayar',
                        subtitle: 'Bulan yang masih belum masuk pembayaran.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: unpaidMonths
                            .map((bulan) => _Pill(label: bulan))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailIntro extends StatelessWidget {
  const _DetailIntro({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17304D),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17304D),
            fontSize: 18,
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
      ],
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.item});

  final BendaharaUnitItem item;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF10B981),
      title: item.namaUnit,
      subtitle: item.keterangan,
      trailing: item.tanggalBayar,
      caption: item.nominalRupiah,
    );
  }
}

class _UnitTagihanCard extends StatelessWidget {
  const _UnitTagihanCard({required this.item});

  final BendaharaUnitItem item;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFFE11D48),
      title: item.namaUnit,
      subtitle: 'Tagihan belum dibayar',
      trailing: item.nominalRupiah,
      caption: 'Belum ada pembayaran',
    );
  }
}

class _SyahriyahCard extends StatelessWidget {
  const _SyahriyahCard({required this.item});

  final BendaharaSyahriyahItem item;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      icon: Icons.calendar_month_rounded,
      iconColor: const Color(0xFF8B5CF6),
      title: '${item.bulan} ${item.tahunHijriyah}',
      subtitle: item.keterangan,
      trailing: item.tanggalBayar,
      caption: item.nominalRupiah,
    );
  }
}

class _TransaksiCard extends StatelessWidget {
  const _TransaksiCard({required this.item});

  final BendaharaTransactionItem item;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      icon: Icons.history_rounded,
      iconColor: const Color(0xFF0F8B8D),
      title: item.detail,
      subtitle: item.jenis,
      trailing: item.tanggalBayar,
      caption: item.nominalRupiah,
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.caption,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final String caption;

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
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Pill(label: trailing),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4B5C74),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF0F8B8D)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 56, color: Color(0xFFE11D48)),
            const SizedBox(height: 12),
            const Text(
              'Data Bendahara belum bisa dimuat',
              style: TextStyle(
                color: Color(0xFF17304D),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7A90),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
