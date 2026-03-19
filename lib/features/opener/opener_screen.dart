import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/opener_data.dart';

class OpenerScreen extends StatefulWidget {
  const OpenerScreen({super.key});

  @override
  State<OpenerScreen> createState() => _OpenerScreenState();
}

class _OpenerScreenState extends State<OpenerScreen> {
  String selectedBranch = 'Standard';
  String selectedTone = 'Professionell';
  String companyName = '';

  final TextEditingController companyController = TextEditingController();

  final List<String> branches = const [
    'Standard',
    'Wohnungswirtschaft',
    'Filialisten',
    'Industrie',
    'Gesundheitswesen',
  ];

  final List<String> tones = const [
    'Professionell',
    'Direkt',
    'Dominant',
  ];

  @override
  void dispose() {
    companyController.dispose();
    super.dispose();
  }

  void resetForm() {
    companyController.clear();
    setState(() {
      companyName = '';
      selectedBranch = 'Standard';
      selectedTone = 'Professionell';
    });
  }

  String buildMailText() {
    final base =
        openerData[selectedBranch]?['mail'] ?? openerData['Standard']!['mail']!;

    switch (selectedTone) {
      case 'Direkt':
        return '$base\n\nFalls das Thema bei Ihnen aktuell relevant ist, freue ich mich über eine kurze Rückmeldung, ob ein erster Austausch sinnvoll ist.';
      case 'Dominant':
        return '$base\n\nGerade bei Unternehmen mit gewachsenen Strukturen zeigt sich schnell, ob in der Beschaffung echte Potenziale liegen oder ob unnötig Geld und Zeit gebunden werden. Wenn das für Sie ein Thema ist, sollten wir dazu sprechen.';
      default:
        return '$base\n\nGerne würde ich in einem kurzen Austausch prüfen, ob und in welcher Form das auch bei Ihnen relevant sein könnte.';
    }
  }

  String buildPhoneText() {
    final base =
        openerData[selectedBranch]?['phone'] ?? openerData['Standard']!['phone']!;

    switch (selectedTone) {
      case 'Direkt':
        return '$base Ich will vermeiden, Ihnen Zeit zu rauben – deshalb direkt die Frage: Ist das Thema Energiebeschaffung bei Ihnen zentral gesteuert oder eher verteilt?';
      case 'Dominant':
        return '$base Erfahrungsgemäß zeigt sich sehr schnell, ob bei bestehenden Strukturen wirklich sauber gesteuert wird oder ob Potenziale ungenutzt bleiben. Genau das würde ich gern mit Ihnen kurz einordnen.';
      default:
        return base;
    }
  }

  Future<void> copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopiert'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mailText = buildMailText();
    final phoneText = buildPhoneText();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Opener Generator',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Erstelle passende Mail- und Telefon-Opener nach Branche und Tonalität.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: companyController,
          decoration: const InputDecoration(
            labelText: 'Firmenname (optional)',
            hintText: 'z. B. thyssenkrupp Rasselstein GmbH',
          ),
          onChanged: (value) {
            setState(() {
              companyName = value.trim();
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedBranch,
          decoration: const InputDecoration(
            labelText: 'Branche',
          ),
          items: branches
              .map(
                (branch) => DropdownMenuItem<String>(
                  value: branch,
                  child: Text(branch),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedBranch = value ?? 'Standard';
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedTone,
          decoration: const InputDecoration(
            labelText: 'Tonalität',
          ),
          items: tones
              .map(
                (tone) => DropdownMenuItem<String>(
                  value: tone,
                  child: Text(tone),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedTone = value ?? 'Professionell';
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Zurücksetzen'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mail-Opener',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (companyName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text('Für: $companyName'),
                  ),
                Text(mailText),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => copyToClipboard(mailText, 'Mail-Opener'),
                  icon: const Icon(Icons.copy),
                  label: const Text('Mail kopieren'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telefon-Opener',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (companyName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text('Für: $companyName'),
                  ),
                Text(phoneText),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () =>
                      copyToClipboard(phoneText, 'Telefon-Opener'),
                  icon: const Icon(Icons.copy),
                  label: const Text('Telefon-Opener kopieren'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}