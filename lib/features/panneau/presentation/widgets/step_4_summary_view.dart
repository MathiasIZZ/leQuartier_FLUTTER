import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/panneau.dart';
import '../providers/panneau_draft_provider.dart';

class Step4SummaryView extends ConsumerWidget {
  final VoidCallback onPublished;

  const Step4SummaryView({super.key, required this.onPublished});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(panneauDraftProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Récapitulatif avant publication',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.title.isEmpty ? 'Sans titre' : draft.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildRow(Icons.category, 'Catégorie', draft.category?.label ?? 'Non définie'),
                  const SizedBox(height: 8),
                  _buildRow(Icons.place, 'Adresse', draft.address),
                  if (draft.locationHint.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildRow(Icons.info, 'Précision', draft.locationHint),
                  ],
                  const SizedBox(height: 8),
                  _buildRow(Icons.access_time, 'Début', dateFormat.format(draft.startsAt)),
                  const SizedBox(height: 8),
                  _buildRow(Icons.timer_off, 'Fin', dateFormat.format(draft.endsAt)),
                  const SizedBox(height: 8),
                  _buildRow(
                    Icons.gps_fixed,
                    'Mode',
                    draft.creationMode == CreationMode.gps ? 'GPS (Position mesurée)' : 'Adresse (Saisie manuelle)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (draft.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                draft.errorMessage!,
                style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
          ],

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: draft.isLoading
                ? null
                : () async {
                    final success = await ref.read(panneauDraftProvider.notifier).publishPanneau();
                    if (success) {
                      onPublished();
                    }
                  },
            child: draft.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Publier le panneau',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
