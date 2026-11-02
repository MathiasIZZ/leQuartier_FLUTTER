import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import '../providers/panneau_filter_provider.dart';
import '../providers/navigation_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late TextEditingController _searchController;
  PanneauCategory? _selectedCategory;
  PanneauKind? _selectedKind;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(panneauFilterProvider);
    _searchController = TextEditingController(text: filter.searchQuery);
    _selectedCategory = filter.category;
    _selectedKind = filter.kind;
    _verifiedOnly = filter.verifiedOnly;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilterAndSwitchToMap() {
    ref.read(panneauFilterProvider.notifier).updateFilter(
          searchQuery: _searchController.text,
          category: _selectedCategory,
          clearCategory: _selectedCategory == null,
          kind: _selectedKind,
          clearKind: _selectedKind == null,
          verifiedOnly: _verifiedOnly,
        );
    // Switch to Map tab (index 0)
    ref.read(currentTabProvider.notifier).state = 0;
  }

  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedKind = null;
      _verifiedOnly = false;
    });
    ref.read(panneauFilterProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer & Filtrer'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: _resetFilter,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Recherche approfondie',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Search query text field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Mots-clés (Titre, description, adresse)',
                hintText: 'Ex: brocante, concert...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Category filter dropdown
            DropdownButtonFormField<PanneauCategory?>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Toutes les catégories'),
                ),
                ...PanneauCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 20),

            // Kind filter dropdown
            DropdownButtonFormField<PanneauKind?>(
              value: _selectedKind,
              decoration: const InputDecoration(
                labelText: 'Type de panneau',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tous les types'),
                ),
                ...PanneauKind.values.map((kind) {
                  return DropdownMenuItem(
                    value: kind,
                    child: Text(kind.label),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() => _selectedKind = val);
              },
            ),
            const SizedBox(height: 20),

            // Verified on site switch
            SwitchListTile(
              title: const Text('Uniquement "Vu sur place"'),
              subtitle: const Text('Afficher les événements vérifiés par la communauté'),
              value: _verifiedOnly,
              onChanged: (val) {
                setState(() => _verifiedOnly = val);
              },
            ),
            const SizedBox(height: 32),

            // Apply button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _applyFilterAndSwitchToMap,
              icon: const Icon(Icons.map),
              label: const Text(
                'Rechercher sur la carte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _resetFilter,
              child: const Text('Effacer tous les filtres'),
            ),
          ],
        ),
      ),
    );
  }
}
