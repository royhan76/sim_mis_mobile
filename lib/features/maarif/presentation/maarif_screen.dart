import 'package:flutter/material.dart';

import '../../auth/data/models/santri_session.dart';
import '../../auth/data/services/auth_api_service.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../data/models/maarif_models.dart';
import '../data/repositories/maarif_repository.dart';

class MaarifScreen extends StatefulWidget {
  const MaarifScreen({
    super.key,
    required this.session,
  });

  final SantriSession session;

  @override
  State<MaarifScreen> createState() => _MaarifScreenState();
}

class _MaarifScreenState extends State<MaarifScreen> {
  final MaarifRepository _repository = MaarifRepository();
  late Future<MaarifOverview> _future = _load();

  Future<MaarifOverview> _load() => _repository.loadOverview(widget.session);

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    const topHeaderHeight = 132.0;

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
          child: FutureBuilder<MaarifOverview>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppPageSkeleton();
              }

              if (snapshot.hasError) {
                final message = snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Gagal memuat data Maarif.';

                return _ErrorState(
                  message: message,
                  onRetry: _reload,
                );
              }

              final overview = snapshot.data!;

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _reload,
                    color: const Color(0xFF0F8B8D),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        14 + topHeaderHeight + 24,
                        18,
                        120,
                      ),
                      children: [
                        _SummaryStrip(
                          items: overview.summary,
                          muhafadzohItems: overview.muhafadzoh,
                          onMaarifTap: () => _showMaarifAttendanceChart(
                            context,
                            overview.absensiMaarif,
                          ),
                          onPondokTap: () => _showPondokAttendanceChart(
                            context,
                            overview.absensiPondok,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 18,
                    right: 18,
                    child: _Header(
                      santri: overview.santri,
                      title: 'Maarif',
                      subtitle: 'Progress hafalan, absensi kegiatan Maarif, dan kegiatan pondok.',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showMaarifAttendanceChart(
    BuildContext context,
    List<MaarifAttendanceItem> items,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MaarifAttendanceChartSheet(items: items),
    );
  }

  Future<void> _showPondokAttendanceChart(
    BuildContext context,
    List<PondokAttendanceItem> items,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PondokAttendanceChartSheet(items: items),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.santri,
    required this.title,
    required this.subtitle,
  });

  final SantriProfile santri;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
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
              child: santri.photoUrl.isEmpty
                  ? Container(
                      color: Colors.white.withValues(alpha: 0.18),
                      child: const Icon(Icons.person_rounded, color: Colors.white),
                    )
                  : Image.network(
                      santri.photoUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  santri.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
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

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.items,
    required this.muhafadzohItems,
    required this.onMaarifTap,
    required this.onPondokTap,
  });

  final List<MaarifSummaryItem> items;
  final List<MuhafadzohItem> muhafadzohItems;
  final VoidCallback onMaarifTap;
  final VoidCallback onPondokTap;

  @override
  Widget build(BuildContext context) {
    final nonMuhafadzohItems = items
        .where((item) => item.label.toLowerCase() != 'progress muhafadzoh')
        .toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
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
              const Text(
                'Progress Muhafadzoh',
                style: TextStyle(
                  color: Color(0xFF6B7A90),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              if (muhafadzohItems.isEmpty)
                const Text(
                  'Belum ada progress muhafadzoh.',
                  style: TextStyle(
                    color: Color(0xFF6B7A90),
                    fontSize: 12,
                  ),
                )
              else
                ...muhafadzohItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == muhafadzohItems.length - 1 ? 0 : 12),
                    child: _MuhafadzohCard(item: item, compact: true),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: nonMuhafadzohItems.map((item) {
            final isMaarifAttendance =
                item.label.toLowerCase() == 'absensi maarif';
            final isPondokAttendance =
                item.label.toLowerCase() == 'absensi pondok';

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isMaarifAttendance
                    ? onMaarifTap
                    : isPondokAttendance
                        ? onPondokTap
                        : null,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                color: Color(0xFF6B7A90),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (isMaarifAttendance || isPondokAttendance)
                            const Icon(
                              Icons.bar_chart_rounded,
                              size: 18,
                              color: Color(0xFF0F8B8D),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.value}',
                        style: const TextStyle(
                          color: Color(0xFF17304D),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.note,
                        style: const TextStyle(
                          color: Color(0xFF6B7A90),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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

class _MuhafadzohCard extends StatelessWidget {
  const _MuhafadzohCard({
    required this.item,
    this.compact = false,
  });

  final MuhafadzohItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final progressValue = item.progressPercent > 0
        ? ((item.progressPercent / 100).clamp(0.0, 1.0)).toDouble()
        : _parseProgressValue(item.progress);
    final progressPercent = item.progressPercent > 0
        ? item.progressPercent.clamp(0, 100)
        : (progressValue * 100).round();
    final triwulanLabel = item.triwulan.trim().isEmpty || item.triwulan.trim() == '-'
        ? item.pelajaran
        : item.triwulan;

    return Container(
      padding: EdgeInsets.fromLTRB(16, compact ? 10 : 14, 16, compact ? 10 : 14),
      decoration: BoxDecoration(
        color: compact ? const Color(0xFFF8FAFD) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: compact ? Border.all(color: const Color(0xFFE7EDF5)) : null,
        boxShadow: compact
            ? null
            : [
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Color(0xFF17304D),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      triwulanLabel,
                      style: const TextStyle(
                        color: Color(0xFF6B7A90),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Pill(label: item.kelas),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE6EEF5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F8B8D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: Color(0xFF0F8B8D),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Progress: ${item.progress}${item.target.trim().isEmpty || item.target == '-' ? '' : ' • Target: ${item.target}'}',
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

double _parseProgressValue(String progress) {
  final trimmed = progress.trim();
  if (trimmed.isEmpty || trimmed == '-') {
    return 0;
  }

  final fractionMatch = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(trimmed);
  if (fractionMatch != null) {
    final current = double.tryParse(fractionMatch.group(1) ?? '');
    final total = double.tryParse(fractionMatch.group(2) ?? '');
    if (current != null && total != null && total > 0) {
      return (current / total).clamp(0, 1);
    }
  }

  final percentMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(trimmed);
  final numeric = double.tryParse(percentMatch?.group(1) ?? '');
  if (numeric == null) {
    return 0;
  }

  final normalized = numeric > 1 ? numeric / 100 : numeric;
  return normalized.clamp(0, 1);
}

class _MaarifAttendanceCard extends StatelessWidget {
  const _MaarifAttendanceCard({
    required this.item,
    this.onTap,
  });

  final MaarifAttendanceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
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
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.kegiatan,
                  style: const TextStyle(
                    color: Color(0xFF17304D),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Pill(label: item.tanggal),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: Color(0xFF0F8B8D),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kelas ${item.kelas}',
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _Pill(label: item.statusLabel),
        ],
      ),
        ),
      ),
    );
  }
}

class _MaarifAttendanceChartSheet extends StatefulWidget {
  const _MaarifAttendanceChartSheet({required this.items});

  final List<MaarifAttendanceItem> items;

  @override
  State<_MaarifAttendanceChartSheet> createState() =>
      _MaarifAttendanceChartSheetState();
}

class _MaarifAttendanceChartSheetState
    extends State<_MaarifAttendanceChartSheet> {
  DateTimeRange? _selectedRange;

  List<MaarifAttendanceItem> get _filteredItems {
    if (_selectedRange == null) {
      return widget.items;
    }

    final start = DateTime(
      _selectedRange!.start.year,
      _selectedRange!.start.month,
      _selectedRange!.start.day,
    );
    final end = DateTime(
      _selectedRange!.end.year,
      _selectedRange!.end.month,
      _selectedRange!.end.day,
      23,
      59,
      59,
    );

    return widget.items.where((item) {
      final date = _parseMaarifDate(item.tanggal);
      if (date == null) {
        return false;
      }

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    DateTime firstDate = now.subtract(const Duration(days: 3650));
    DateTime lastDate = now.add(const Duration(days: 365));

    for (final item in widget.items) {
      final parsed = _parseMaarifDate(item.tanggal);
      if (parsed == null) {
        continue;
      }
      if (parsed.isBefore(firstDate)) {
        firstDate = parsed;
      }
      if (parsed.isAfter(lastDate)) {
        lastDate = parsed;
      }
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _selectedRange,
      helpText: 'Filter tanggal absensi',
      saveText: 'Terapkan',
      cancelText: 'Batal',
      confirmText: 'Terapkan',
      fieldStartHintText: 'Tanggal awal',
      fieldEndHintText: 'Tanggal akhir',
      currentDate: now,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedRange = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final grouped = <String, int>{};

    for (final item in filteredItems) {
      if (!_isPresentAttendance(item)) {
        continue;
      }

      grouped.update(item.kegiatan, (value) => value + 1, ifAbsent: () => 1);
    }

    final maxValue = grouped.values.isEmpty
        ? 1
        : grouped.values.reduce((a, b) => a > b ? a : b);
    final chartItems = grouped.entries
        .map(
          (entry) => _ChartBarData(
            label: entry.key,
            value: entry.value,
            maxValue: maxValue,
          ),
        )
        .toList()
      ..sort((a, b) {
        final compareValue = b.value.compareTo(a.value);
        if (compareValue != 0) {
          return compareValue;
        }
        return a.label.compareTo(b.label);
      });

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.55,
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rekap Absensi Maarif',
                                style: TextStyle(
                                  color: Color(0xFF17304D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedRange == null
                                    ? 'Jumlah kehadiran santri pada setiap kegiatan.'
                                    : '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7A90),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.date_range_rounded, size: 18),
                          label: const Text('Filter'),
                        ),
                      ],
                    ),
                    if (_selectedRange != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedRange = null;
                            });
                          },
                          child: const Text('Reset filter'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (chartItems.isEmpty)
                      const _EmptyMessage(
                        icon: Icons.bar_chart_rounded,
                        title: 'Belum ada kehadiran pada rentang ini',
                        subtitle: 'Coba ubah filter tanggal untuk melihat kegiatan yang diikuti santri.',
                      )
                    else
                      _AttendanceBarChart(items: chartItems),
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

class _ChartSummaryCard extends StatelessWidget {
  const _ChartSummaryCard({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
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

class _AttendanceBarChart extends StatelessWidget {
  const _AttendanceBarChart({
    required this.items,
    this.title = 'Chart Kehadiran per Kegiatan',
    this.subtitle = 'Jumlah kehadiran santri login pada tiap kegiatan.',
  });

  final List<_ChartBarData> items;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const barColors = [
      Color(0xFF24A3FF),
      Color(0xFF44C776),
      Color(0xFFFF5A4E),
      Color(0xFFFFA31A),
      Color(0xFF3F7CFF),
      Color(0xFF5BCB8B),
      Color(0xFFFF4A3D),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _VerticalAttendanceBar(
                      item: items[index],
                      color: barColors[index % barColors.length],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalAttendanceBar extends StatelessWidget {
  const _VerticalAttendanceBar({
    required this.item,
    required this.color,
  });

  final _ChartBarData item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final barHeight = item.value <= 0 ? 12.0 : 48 + (item.ratio * 132);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2430),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2430).withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            '${item.value}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 34),
              height: barHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.26),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF17304D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartBarData {
  const _ChartBarData({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final int value;
  final int maxValue;

  double get ratio {
    if (maxValue <= 0) {
      return 0;
    }

    return (value / maxValue).clamp(0, 1).toDouble();
  }
}

bool _isPresentAttendance(MaarifAttendanceItem item) {
  final status = '${item.status} ${item.statusLabel}'.toLowerCase();
  return status.contains('hadir') ||
      status.contains('present') ||
      status.contains('masuk');
}

bool _isPresentPondokActivity(PondokAttendanceActivity activity) {
  final status = '${activity.status} ${activity.statusLabel}'.toLowerCase();
  return status.contains('hadir') ||
      status.contains('present') ||
      status.contains('masuk');
}

DateTime? _parseMaarifDate(String value) {
  final parts = value.trim().split('/');
  if (parts.length == 3) {
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }

  return DateTime.tryParse(value);
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

class _PondokAttendanceChartSheet extends StatefulWidget {
  const _PondokAttendanceChartSheet({required this.items});

  final List<PondokAttendanceItem> items;

  @override
  State<_PondokAttendanceChartSheet> createState() =>
      _PondokAttendanceChartSheetState();
}

class _PondokAttendanceChartSheetState
    extends State<_PondokAttendanceChartSheet> {
  DateTimeRange? _selectedRange;

  List<PondokAttendanceItem> get _filteredItems {
    if (_selectedRange == null) {
      return widget.items;
    }

    final start = DateTime(
      _selectedRange!.start.year,
      _selectedRange!.start.month,
      _selectedRange!.start.day,
    );
    final end = DateTime(
      _selectedRange!.end.year,
      _selectedRange!.end.month,
      _selectedRange!.end.day,
      23,
      59,
      59,
    );

    return widget.items.where((item) {
      final date = _parseMaarifDate(item.tanggal);
      if (date == null) {
        return false;
      }

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    DateTime firstDate = now.subtract(const Duration(days: 3650));
    DateTime lastDate = now.add(const Duration(days: 365));

    for (final item in widget.items) {
      final parsed = _parseMaarifDate(item.tanggal);
      if (parsed == null) {
        continue;
      }
      if (parsed.isBefore(firstDate)) {
        firstDate = parsed;
      }
      if (parsed.isAfter(lastDate)) {
        lastDate = parsed;
      }
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _selectedRange,
      helpText: 'Filter tanggal absensi pondok',
      saveText: 'Terapkan',
      cancelText: 'Batal',
      confirmText: 'Terapkan',
      fieldStartHintText: 'Tanggal awal',
      fieldEndHintText: 'Tanggal akhir',
      currentDate: now,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedRange = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final grouped = <String, int>{};

    for (final item in filteredItems) {
      for (final activity in item.activities) {
        if (!_isPresentPondokActivity(activity)) {
          continue;
        }

        grouped.update(
          activity.namaKegiatan,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final maxValue = grouped.values.isEmpty
        ? 1
        : grouped.values.reduce((a, b) => a > b ? a : b);
    final chartItems = grouped.entries
        .map(
          (entry) => _ChartBarData(
            label: entry.key,
            value: entry.value,
            maxValue: maxValue,
          ),
        )
        .toList()
      ..sort((a, b) {
        final compareValue = b.value.compareTo(a.value);
        if (compareValue != 0) {
          return compareValue;
        }
        return a.label.compareTo(b.label);
      });

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.55,
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rekap Absensi Pondok',
                                style: TextStyle(
                                  color: Color(0xFF17304D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedRange == null
                                    ? 'Jumlah kehadiran santri pada setiap kegiatan pondok.'
                                    : '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7A90),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.date_range_rounded, size: 18),
                          label: const Text('Filter'),
                        ),
                      ],
                    ),
                    if (_selectedRange != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedRange = null;
                            });
                          },
                          child: const Text('Reset filter'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (chartItems.isEmpty)
                      const _EmptyMessage(
                        icon: Icons.bar_chart_rounded,
                        title: 'Belum ada kehadiran pada rentang ini',
                        subtitle:
                            'Coba ubah filter tanggal untuk melihat kegiatan pondok yang diikuti santri.',
                      )
                    else
                      _AttendanceBarChart(
                        items: chartItems,
                        title: 'Chart Kehadiran Kegiatan Pondok',
                        subtitle:
                            'Jumlah kehadiran santri login pada tiap kegiatan pondok.',
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

class _PondokAttendanceCard extends StatelessWidget {
  const _PondokAttendanceCard({
    required this.item,
    this.onTap,
  });

  final PondokAttendanceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Absensi Pondok',
                      style: const TextStyle(
                        color: Color(0xFF17304D),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Pill(label: item.tanggal),
                      if (onTap != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.bar_chart_rounded,
                          size: 18,
                          color: Color(0xFF0F8B8D),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.keterangan,
                style: const TextStyle(
                  color: Color(0xFF6B7A90),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.activities
                    .map(
                      (activity) => _Pill(
                        label:
                            '${activity.namaKegiatan} • ${activity.statusLabel}',
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
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
              'Data Maarif belum bisa dimuat',
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
