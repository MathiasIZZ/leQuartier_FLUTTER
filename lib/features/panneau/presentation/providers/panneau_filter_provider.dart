import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import 'panneaux_provider.dart';

class PanneauFilterState {
  final String searchQuery;
  final PanneauCategory? category;
  final PanneauKind? kind;
  final bool verifiedOnly;

  const PanneauFilterState({
    this.searchQuery = '',
    this.category,
    this.kind,
    this.verifiedOnly = false,
  });

  bool get hasActiveFilter =>
      searchQuery.trim().isNotEmpty ||
      category != null ||
      kind != null ||
      verifiedOnly;

  PanneauFilterState copyWith({
    String? searchQuery,
    PanneauCategory? category,
    bool clearCategory = false,
    PanneauKind? kind,
    bool clearKind = false,
    bool? verifiedOnly,
  }) {
    return PanneauFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      kind: clearKind ? null : (kind ?? this.kind),
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }
}

class PanneauFilterNotifier extends StateNotifier<PanneauFilterState> {
  PanneauFilterNotifier() : super(const PanneauFilterState());

  void updateFilter({
    String? searchQuery,
    PanneauCategory? category,
    bool clearCategory = false,
    PanneauKind? kind,
    bool clearKind = false,
    bool? verifiedOnly,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      category: category,
      clearCategory: clearCategory,
      kind: kind,
      clearKind: clearKind,
      verifiedOnly: verifiedOnly,
    );
  }

  void clearFilters() {
    state = const PanneauFilterState();
  }
}

final panneauFilterProvider =
    StateNotifierProvider<PanneauFilterNotifier, PanneauFilterState>((ref) {
  return PanneauFilterNotifier();
});

final filteredPanneauxProvider = FutureProvider.autoDispose<List<Panneau>>((ref) async {
  final allPanneaux = await ref.watch(panneauxProvider.future);
  final filter = ref.watch(panneauFilterProvider);

  return allPanneaux.where((panneau) {
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      final matchTitle = panneau.title.toLowerCase().contains(q);
      final matchDesc = panneau.description.toLowerCase().contains(q);
      final matchAddress = panneau.address.toLowerCase().contains(q);
      if (!matchTitle && !matchDesc && !matchAddress) return false;
    }

    if (filter.category != null && panneau.category != filter.category) {
      return false;
    }

    if (filter.kind != null && panneau.kind != filter.kind) {
      return false;
    }

    if (filter.verifiedOnly && !panneau.verifiedOnSite) {
      return false;
    }

    return true;
  }).toList();
});
