import 'package:flutter/material.dart';
import 'potential_api_service.dart';
import 'potential_models.dart';

class PotentialScreen extends StatefulWidget {
  const PotentialScreen({super.key});

  @override
  State<PotentialScreen> createState() => _PotentialScreenState();
}

class _PotentialScreenState extends State<PotentialScreen> {
  final companyController = TextEditingController();
  final plzController = TextEditingController();

  String selectedBranch = 'Keine Auswahl';
  PotentialApiResult? result;
  String? errorMessage;
  bool isLoading = false;

  final List<String> branches = const [
    'Keine Auswahl',
    'Wohnungswirtschaft',
    'Filialisten',
    'Industrie',
    'Gesundheitswesen',
  ];

  @override
  void dispose() {
    companyController.dispose();
    plzController.dispose();
    super.dispose();
  }

  Future<void> calculatePotential() async {
    final company = companyController.text.trim();
    final plz = plzController.text.trim();
    final branch = selectedBranch == 'Keine Auswahl' ? '' : selectedBranch;

    if (company.isEmpty || plz.isEmpty) {
      setState(() {
        errorMessage = 'Bitte mindestens Firmenname und PLZ eingeben.';
        result = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      final apiResult = await PotentialApiService.analyzeCompany(
        company: company,
        plz: plz,
        branch: branch,
      );

      setState(() {
        result = apiResult;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Fehler bei der Analyse: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void clearForm() {
    companyController.clear();
    plzController.clear();

    setState(() {
      selectedBranch = 'Keine Auswahl';
      result = null;
      errorMessage = null;
    });
  }

  Color _badgeColor(String level) {
    switch (level) {
      case 'HIGH':
        return Colors.red.shade700;
      case 'MID':
        return Colors.orange.shade700;
      case 'LOW':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Potential Check',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Reales Unternehmen anhand von Firmenname und PLZ prüfen und daraus ein Energie-Potential ableiten.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: companyController,
          decoration: const InputDecoration(
            labelText: 'Firmenname',
            hintText: 'z. B. Zahnärzte in Harvestehude MVZ GmbH',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: plzController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'PLZ',
            hintText: 'z. B. 20149',
          ),
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
              selectedBranch = value ?? 'Keine Auswahl';
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: isLoading ? null : calculatePotential,
                icon: const Icon(Icons.search),
                label: const Text('Unternehmen prüfen'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: isLoading ? null : clearForm,
              child: const Text('Zurücksetzen'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        if (errorMessage != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (result != null && result!.found == false)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(result!.message ?? 'Kein passendes Unternehmen gefunden.'),
            ),
          ),
        if (result != null && result!.found)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gefundenes Unternehmen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result!.matchedCompany,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(result!.address),
                  if (result!.website.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Website: ${result!.website}'),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeColor(result!.level),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Lead-Level: ${result!.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Confidence Score: ${result!.confidenceScore}'),
                  const SizedBox(height: 14),
                  Text(
                    'Geschätzter Strombedarf',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(result!.stromRange),
                  const SizedBox(height: 14),
                  Text(
                    'Geschätzter Gasbedarf',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(result!.gasRange),
                  const SizedBox(height: 14),
                  Text(
                    'Begründung',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(result!.reasoning),
                  if (result!.hints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Vertriebliche Hinweise',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...result!.hints.map(
                      (hint) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(hint.toString())),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}