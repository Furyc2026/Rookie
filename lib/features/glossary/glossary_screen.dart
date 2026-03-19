import 'package:flutter/material.dart';
import '../../data/glossary_data.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = glossaryData.where((item) {
      final term = item['term']!.toLowerCase();
      final definition = item['definition']!.toLowerCase();
      final q = query.toLowerCase();
      return term.contains(q) || definition.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Begriff suchen...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['term']!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(item['definition']!),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}