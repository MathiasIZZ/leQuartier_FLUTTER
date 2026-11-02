import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/panneau_draft_provider.dart';

class Step3DetailsView extends ConsumerStatefulWidget {
  const Step3DetailsView({super.key});

  @override
  ConsumerState<Step3DetailsView> createState() => _Step3DetailsViewState();
}

class _Step3DetailsViewState extends ConsumerState<Step3DetailsView> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(panneauDraftProvider);
    _titleController = TextEditingController(text: draft.title);
    _descController = TextEditingController(text: draft.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _updateDraft() {
    ref.read(panneauDraftProvider.notifier).updateDetails(
          title: _titleController.text,
          description: _descController.text,
          startsAt: ref.read(panneauDraftProvider).startsAt,
          endsAt: ref.read(panneauDraftProvider).endsAt,
        );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final draft = ref.read(panneauDraftProvider);
    final initialDate = isStart ? draft.startsAt : draft.endsAt;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null && mounted) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStart) {
          ref.read(panneauDraftProvider.notifier).updateDetails(
                title: _titleController.text,
                description: _descController.text,
                startsAt: newDateTime,
                endsAt: newDateTime.isAfter(draft.endsAt)
                    ? newDateTime.add(const Duration(hours: 3))
                    : draft.endsAt,
              );
        } else {
          ref.read(panneauDraftProvider.notifier).updateDetails(
                title: _titleController.text,
                description: _descController.text,
                startsAt: draft.startsAt,
                endsAt: newDateTime,
              );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(panneauDraftProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Détails de l’événement',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre de l’événement *',
              hintText: 'Ex: Vide-grenier de la rue des Lilas',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (_) => _updateDraft(),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              hintText: 'Précisez les horaires, les objets vendus, les animations...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: (_) => _updateDraft(),
          ),
          const SizedBox(height: 20),

          Text(
            'Horaires (Heure de Paris)',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Start Date Picker
          InkWell(
            onTap: () => _pickDateTime(true),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date et heure de début *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.play_arrow),
              ),
              child: Text(dateFormat.format(draft.startsAt)),
            ),
          ),
          const SizedBox(height: 16),

          // End Date Picker
          InkWell(
            onTap: () => _pickDateTime(false),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date et heure de fin *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.stop),
              ),
              child: Text(dateFormat.format(draft.endsAt)),
            ),
          ),
        ],
      ),
    );
  }
}
