import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/tips_data.dart';
import '../../services/market_service.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenGlossary;
  final VoidCallback onOpenTips;
  final VoidCallback onOpenPotential;
  final VoidCallback onOpenOpener;

  const DashboardScreen({
    super.key,
    required this.onOpenGlossary,
    required this.onOpenTips,
    required this.onOpenPotential,
    required this.onOpenOpener,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<MarketData> marketData;

  @override
  void initState() {
    super.initState();
    marketData = MarketService.fetchMarketData();
  }

  int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  Map<String, String> _dailyTip() {
    if (tipsData.isEmpty) {
      return {
        'title': 'Kein Tipp verfügbar',
        'text': 'Bitte tips_data.dart prüfen.',
      };
    }

    final index = _dayOfYear(DateTime.now()) % tipsData.length;
    return tipsData[index];
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link konnte nicht geöffnet werden.')),
      );
    }
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _salesHintBanner(BuildContext context, double width) {
    final hints = [
      'Wochen-Trends lesen, nicht Tageszucken überbewerten',
      'Steigender Trend → Timing und Preisabsicherung ansprechen',
      'Fallender Trend → guter Einstieg für Re-Entry und Neuansätze',
    ];

    final cardWidth = width < 500 ? width * 0.78 : 320.0;

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hints.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: _glassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC72C).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hints[index],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final iconBoxSize = compact ? 38.0 : 46.0;
    final iconSize = compact ? 19.0 : 23.0;
    final titleStyle = (compact
            ? Theme.of(context).textTheme.bodyLarge
            : Theme.of(context).textTheme.titleMedium)
        ?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _glassCard(
        padding: EdgeInsets.all(compact ? 14 : 18),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(height: compact ? 10 : 14),
            Text(
              title,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: compact ? 4 : 6),
            Expanded(
              child: Text(
                subtitle,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: compact ? 12 : 14,
                      height: 1.3,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _trendColor(MarketMetric metric) {
    if (metric.isUp) return const Color(0xFFFFB199);
    if (metric.isDown) return const Color(0xFF8CF0C1);
    return const Color(0xFFB8D7FF);
  }

  Widget _marketTile({
    required BuildContext context,
    required String title,
    required MarketMetric metric,
  }) {
    final trendColor = _trendColor(metric);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.78),
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                metric.arrow,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: trendColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${metric.current.toStringAsFixed(2)} €/MWh',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${metric.periodLabel}: ${metric.current.toStringAsFixed(2)} €/MWh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.82),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${metric.comparisonLabel}: ${metric.previous.toStringAsFixed(2)} €/MWh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.82),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Veränderung: ${metric.delta >= 0 ? '+' : ''}${metric.delta.toStringAsFixed(2)} €/MWh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Trend: ${metric.directionText}',
            style: TextStyle(
              color: trendColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Text(
              metric.salesHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketInfoCard(BuildContext context, MarketData data) {
    return _glassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Datenhinweis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quelle: ${data.source}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.78),
                ),
          ),
        ],
      ),
    );
  }

  Widget _linkTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return _glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.open_in_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _openLink(context, url),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Öffnen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _tileColumns(double width) {
    if (width >= 1200) return 4;
    if (width >= 850) return 3;
    return 2;
  }

  double _tileAspectRatio(double width) {
    if (width >= 1200) return 1.35;
    if (width >= 850) return 1.2;
    if (width >= 500) return 1.1;
    return 1.0;
  }

  bool _compactTiles(double width) {
    return width < 430;
  }

  @override
  Widget build(BuildContext context) {
    final tip = _dailyTip();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final tileColumns = _tileColumns(width);
        final tileAspectRatio = _tileAspectRatio(width);
        final compactTiles = _compactTiles(width);

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/energy_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0B1F3A).withOpacity(0.80),
                      const Color(0xFF0B1F3A).withOpacity(0.70),
                      const Color(0xFF0B1F3A).withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.10),
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _glassCard(
                  padding: EdgeInsets.all(width < 500 ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Energy Sales Rookie',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Schneller lernen, besser qualifizieren, sauberer pitchen.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _salesHintBanner(context, width),
                const SizedBox(height: 24),
                _sectionTitle('Module', context),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: tileColumns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: tileAspectRatio,
                  children: [
                    _menuTile(
                      context: context,
                      icon: Icons.menu_book_outlined,
                      title: 'Glossar',
                      subtitle: 'Begriffe & Basics',
                      onTap: widget.onOpenGlossary,
                      compact: compactTiles,
                    ),
                    _menuTile(
                      context: context,
                      icon: Icons.lightbulb_outline,
                      title: 'Tipps',
                      subtitle: 'Vertrieb in echt',
                      onTap: widget.onOpenTips,
                      compact: compactTiles,
                    ),
                    _menuTile(
                      context: context,
                      icon: Icons.query_stats_outlined,
                      title: 'Potential',
                      subtitle: 'Reales Unternehmen prüfen',
                      onTap: widget.onOpenPotential,
                      compact: compactTiles,
                    ),
                    _menuTile(
                      context: context,
                      icon: Icons.record_voice_over_outlined,
                      title: 'Opener',
                      subtitle: 'Mail & Telefon',
                      onTap: widget.onOpenOpener,
                      compact: compactTiles,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle('Tipp des Tages', context),
                const SizedBox(height: 12),
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3C2).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF9B7A00),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip['title'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tip['text'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Strommarkt', context),
                const SizedBox(height: 8),
                Text(
                  'Wochen-Trends zur Markteinordnung, keine tagesaktuellen Börsenpreise.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<MarketData>(
                  future: marketData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _glassCard(
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Marktentwicklung konnte nicht geladen werden',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.90),
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return _glassCard(
                        child: Text(
                          'Keine Marktdaten verfügbar.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      );
                    }

                    final data = snapshot.data!;

                    return Column(
                      children: [
                        _marketInfoCard(context, data),
                        const SizedBox(height: 12),
                        _marketTile(
                          context: context,
                          title: 'Strom',
                          metric: data.power,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _sectionTitle('Marktquellen', context),
                const SizedBox(height: 8),
                Text(
                  'Offizielle und hilfreiche Quellen für Vertiefung und Marktverständnis.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                ),
                const SizedBox(height: 12),
                _linkTile(
                  context: context,
                  title: 'Energy-Charts',
                  subtitle: 'Strompreise, Marktverläufe und Charts als freie Datenquelle.',
                  url: 'https://energy-charts.info',
                ),
                const SizedBox(height: 12),
                _linkTile(
                  context: context,
                  title: 'EEX Market Data Hub',
                  subtitle: 'Offizielle Marktübersicht und Datenprodukte der EEX.',
                  url: 'https://www.eex.com/en/market-data/market-data-hub',
                ),
                const SizedBox(height: 12),
                _linkTile(
                  context: context,
                  title: 'Power Futures',
                  subtitle: 'Offizielle EEX-Seite für Strom-Futures.',
                  url: 'https://www.eex.com/en/markets/power/power-futures',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        );
      },
    );
  }
}