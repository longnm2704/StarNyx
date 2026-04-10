import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

// Loads all StarNyx entities for list and picker flows.
class LoadStarnyxsUseCase {
  const LoadStarnyxsUseCase(this._repository);

  final StarNyxRepository _repository;

  Future<List<StarNyx>> call() {
    return _repository.getAllStarnyxs();
  }
}
