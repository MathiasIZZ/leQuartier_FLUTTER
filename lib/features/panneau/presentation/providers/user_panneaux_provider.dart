import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import '../../data/repositories/panneau_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final userPanneauxProvider = FutureProvider.autoDispose<List<Panneau>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  final repository = ref.watch(panneauRepositoryProvider);
  return repository.getUserPanneaux(authState.user!.id);
});
