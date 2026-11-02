import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import '../providers/panneau_draft_provider.dart';

class Step2CategoryView extends ConsumerWidget {
  const Step2CategoryView({super.key});

  void _showDuplicateBottomSheet(BuildContext context, WidgetRef ref, List<Panneau> duplicates) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Un événement similaire existe déjà !',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Vérifiez si l’événement n’a pas déjà été signalé à proximité :',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ...duplicates.map((p) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.address}\n${p.description}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      isThreeLine: true,
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('C’est le même (Ajouter une précision)'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('C’est différent, continuer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(panneauDraftProvider);
    final theme = Theme.of(context);

    ref.listen(panneauDraftProvider, (previous, next) {
      if (previous?.category != next.category && next.category != null && next.title.trim().isNotEmpty) {
        ref.read(panneauDraftProvider.notifier).checkDuplicates();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quel type d’événement signalez-vous ?',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<PanneauKind>(
            initialValue: draft.kind,
            decoration: const InputDecoration(
              labelText: 'Nature du panneau',
              border: OutlineInputBorder(),
            ),
            items: PanneauKind.values.map((kind) {
              return DropdownMenuItem(
                value: kind,
                child: Text(kind.label),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(panneauDraftProvider.notifier).setKind(val);
              }
            },
          ),
          const SizedBox(height: 20),

          Text(
            'Catégorie principale *',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...PanneauCategory.values.map((category) {
            final isSelected = draft.category == category;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
                  side: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () async {
                  ref.read(panneauDraftProvider.notifier).setCategory(category);
                  await ref.read(panneauDraftProvider.notifier).checkDuplicates();
                  final updatedDraft = ref.read(panneauDraftProvider);
                  if (updatedDraft.duplicateResult?.hasDuplicates == true && context.mounted) {
                    _showDuplicateBottomSheet(context, ref, updatedDraft.duplicateResult!.duplicates);
                  }
                },
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),

          if (draft.isCheckingDuplicates) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
