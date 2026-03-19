import 'package:flutter/material.dart';
import '../services/market_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<MarketTrendResponse> _marketTrendFuture;
  final MarketApiService _marketApiService = MarketApiService();

  @override
  void initState() {
    super.initState();
    _marketTrendFuture = _marketApiService.fetchPowerTrend();
  }

  Future<void> _reload() async {
    setState(() {
      _marketTrendFuture = _marketApiService.fetchPowerTrend();
    });
    await _marketTrendFuture;
  }

  IconData _trendIcon(String direction) {
    switch (direction.toLowerCase()) {
      case 'up':
        return Icons.north_east_rounded;
      case 'down':
        return Icons.south_east_rounded;
      default:
        return Icons.east_rounded;
    }
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Sales Rookie'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<MarketTrendResponse>(
            future: _marketTrendFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingView();
              }

              if (snapshot.hasError) {
                return _ErrorView(
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      _marketTrendFuture = _marketApiService.fetchPowerTrend();
                    });
                  },
                );
              }

              final trend = snapshot.data!;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _HeroCard(),
                  const SizedBox(height: 16),
                  _MarketCard(
                    title: trend.label.isEmpty ? 'Stromtrend' : trend.label,
                    currentValue: _formatNumber(trend.current),
                    previousValue: _formatNumber(trend.previous),
                    deltaValue: _formatNumber(trend.delta),
                    periodLabel: trend.periodLabel,
                    comparisonLabel: trend.comparisonLabel,
                    updatedAt: trend.updatedAt,
                    icon: _trendIcon(trend.direction),
                  ),
                  const SizedBox(height: 16),
                  _SalesHintCard(
                    salesHint: trend.salesHint,
                  ),
                  const SizedBox(height: 16),
                  const _QuickActionsCard(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0057B8),
            Color(0xFF6EC6FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Markt auf einen Blick',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mobile Web App für schnelle Vertriebsimpulse unterwegs.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final String previousValue;
  final String deltaValue;
  final String periodLabel;
  final String comparisonLabel;
  final String updatedAt;
  final IconData icon;

  const _MarketCard({
    required this.title,
    required this.currentValue,
    required this.previousValue,
    required this.deltaValue,
    required this.periodLabel,
    required this.comparisonLabel,
    required this.updatedAt,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final displayPeriod =
        periodLabel.isEmpty ? 'Aktuelle Periode' : periodLabel;
    final displayComparison =
        comparisonLabel.isEmpty ? 'Vorperiode' : comparisonLabel;
    final displayUpdatedAt =
        updatedAt.isEmpty ? 'Keine Zeitangabe' : updatedAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEAF2FF),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0057B8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Aktuell',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentValue,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricBox(
                    label: displayPeriod,
                    value: currentValue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBox(
                    label: displayComparison,
                    value: previousValue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricBox(
              label: 'Delta',
              value: deltaValue,
            ),
            const SizedBox(height: 14),
            Text(
              'Zuletzt aktualisiert: $displayUpdatedAt',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesHintCard extends StatelessWidget {
  final String salesHint;

  const _SalesHintCard({
    required this.salesHint,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = salesHint.isEmpty
        ? 'Noch kein Vertriebsimpuls verfügbar.'
        : salesHint;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Hint',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _QuickChip(label: 'Kunde ansprechen'),
                _QuickChip(label: 'Re-Entry prüfen'),
                _QuickChip(label: 'Termin vorbereiten'),
                _QuickChip(label: 'Marktargument nutzen'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;

  const _QuickChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0057B8),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.error_outline_rounded,
          size: 56,
          color: Color(0xFFB91C1C),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Laden fehlgeschlagen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Erneut versuchen'),
          ),
        ),
      ],
    );
  }
}