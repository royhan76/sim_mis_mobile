import 'package:flutter/material.dart';

class AppSkeletonFrame extends StatefulWidget {
  const AppSkeletonFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppSkeletonFrame> createState() => _AppSkeletonFrameState();
}

class _AppSkeletonFrameState extends State<AppSkeletonFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            const base = Color(0xFFE8EEF5);
            const highlight = Color(0xFFF8FAFC);
            return LinearGradient(
              begin: Alignment(-1.5 + (_controller.value * 3), -0.2),
              end: Alignment(-0.5 + (_controller.value * 3), 0.2),
              colors: const [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 12,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class AppSkeletonLine extends StatelessWidget {
  const AppSkeletonLine({
    super.key,
    required this.widthFactor,
    this.height = 12,
  });

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: AppSkeletonBox(height: height, radius: 999),
      ),
    );
  }
}

class AppPageSkeleton extends StatelessWidget {
  const AppPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFF4F7FB)],
        ),
      ),
      child: SafeArea(
        child: AppSkeletonFrame(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    const AppSkeletonBox(width: 60, height: 60, radius: 999),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppSkeletonLine(widthFactor: 0.62, height: 18),
                          SizedBox(height: 10),
                          AppSkeletonLine(widthFactor: 0.92, height: 12),
                          SizedBox(height: 8),
                          AppSkeletonLine(widthFactor: 0.72, height: 12),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              AppSkeletonBox(width: 74, height: 28, radius: 999),
                              SizedBox(width: 8),
                              AppSkeletonBox(width: 88, height: 28, radius: 999),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonLine(widthFactor: 0.58, height: 12),
                          SizedBox(height: 10),
                          AppSkeletonLine(widthFactor: 0.42, height: 24),
                          SizedBox(height: 10),
                          AppSkeletonLine(widthFactor: 0.84, height: 12),
                          SizedBox(height: 8),
                          AppSkeletonLine(widthFactor: 0.66, height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const AppSkeletonLine(widthFactor: 0.42, height: 18),
              const SizedBox(height: 8),
              const AppSkeletonLine(widthFactor: 0.62, height: 12),
              const SizedBox(height: 14),
              ...List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index == 4 ? 0 : 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        AppSkeletonBox(width: 52, height: 52, radius: 16),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeletonLine(widthFactor: 0.72, height: 14),
                              SizedBox(height: 8),
                              AppSkeletonLine(widthFactor: 0.54, height: 12),
                              SizedBox(height: 8),
                              AppSkeletonLine(widthFactor: 0.38, height: 12),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        AppSkeletonBox(width: 64, height: 28, radius: 999),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppArticleFeedSkeleton extends StatelessWidget {
  const AppArticleFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonFrame(
      child: SizedBox(
        height: 228,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.78,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        child: AppSkeletonBox(height: double.infinity, radius: 0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonLine(widthFactor: 0.92, height: 16),
                          SizedBox(height: 10),
                          AppSkeletonLine(widthFactor: 0.72, height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppArticleListSkeleton extends StatelessWidget {
  const AppArticleListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonFrame(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            height: 116,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const ClipRRect(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
                  child: AppSkeletonBox(width: 116, height: 116, radius: 0),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AppSkeletonLine(widthFactor: 0.92, height: 16),
                        SizedBox(height: 10),
                        AppSkeletonLine(widthFactor: 0.76, height: 12),
                        SizedBox(height: 8),
                        AppSkeletonLine(widthFactor: 0.58, height: 12),
                        Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: AppSkeletonLine(widthFactor: 0.54, height: 12),
                            ),
                            SizedBox(width: 10),
                            AppSkeletonBox(width: 22, height: 22, radius: 999),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AppArticleDetailSkeleton extends StatelessWidget {
  const AppArticleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonFrame(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          const Row(
            children: [
              AppSkeletonBox(width: 42, height: 42, radius: 999),
              SizedBox(width: 12),
              AppSkeletonBox(width: 160, height: 20, radius: 999),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    child: AppSkeletonBox(height: 210, radius: 0),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBox(width: 88, height: 28, radius: 999),
                        SizedBox(height: 14),
                        AppSkeletonLine(widthFactor: 0.92, height: 22),
                        SizedBox(height: 10),
                        AppSkeletonLine(widthFactor: 0.74, height: 22),
                        SizedBox(height: 18),
                        AppSkeletonLine(widthFactor: 0.96, height: 12),
                        SizedBox(height: 8),
                        AppSkeletonLine(widthFactor: 0.88, height: 12),
                        SizedBox(height: 8),
                        AppSkeletonLine(widthFactor: 0.82, height: 12),
                        SizedBox(height: 22),
                        AppSkeletonBox(width: 110, height: 18, radius: 999),
                        SizedBox(height: 12),
                        AppSkeletonLine(widthFactor: 0.96, height: 12),
                        SizedBox(height: 8),
                        AppSkeletonLine(widthFactor: 0.94, height: 12),
                        SizedBox(height: 8),
                        AppSkeletonLine(widthFactor: 0.86, height: 12),
                        SizedBox(height: 18),
                        AppSkeletonBox(height: 112, radius: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
