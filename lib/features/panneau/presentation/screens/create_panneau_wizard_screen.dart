import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/panneau_draft_provider.dart';
import '../widgets/step_1_location_view.dart';
import '../widgets/step_2_category_view.dart';
import '../widgets/step_3_details_view.dart';
import '../widgets/step_4_summary_view.dart';

class CreatePanneauWizardScreen extends ConsumerWidget {
  const CreatePanneauWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(panneauDraftProvider);
    final theme = Theme.of(context);

    final List<Widget> steps = [
      const Step1LocationView(),
      const Step2CategoryView(),
      const Step3DetailsView(),
      Step4SummaryView(
        onPublished: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Panneau publié avec succès !')),
          );
          Navigator.pop(context);
        },
      ),
    ];

    bool canProceed() {
      if (draft.currentStep == 0) return true; // Location has defaults
      if (draft.currentStep == 1) return draft.category != null;
      if (draft.currentStep == 2) return draft.title.trim().isNotEmpty && draft.endsAt.isAfter(draft.startsAt);
      return true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Publier un panneau (${draft.currentStep + 1}/4)'),
        backgroundColor: theme.colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (draft.currentStep + 1) / 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          Expanded(
            child: steps[draft.currentStep],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (draft.currentStep > 0)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(panneauDraftProvider.notifier).setStep(draft.currentStep - 1);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  )
                else
                  const SizedBox.shrink(),
                if (draft.currentStep < 3)
                  ElevatedButton.icon(
                    onPressed: canProceed()
                        ? () {
                            ref.read(panneauDraftProvider.notifier).setStep(draft.currentStep + 1);
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Suivant'),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
