import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import '../../data/repositories/panneau_repository_impl.dart';

final panneauxProvider = FutureProvider.autoDispose<List<Panneau>>((ref) async {
  final repository = ref.watch(panneauRepositoryProvider);
  // Petit délai simulé pour afficher l'écran de chargement "LE QUARTIER" au démarrage
  await Future.delayed(const Duration(milliseconds: 800));
  return repository.getPanneaux('47.3,0.6,47.5,0.8');
});
