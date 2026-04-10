import 'package:starnyx/domain/entities/starnyx.dart';

// Contract for loading and persisting StarNyx habits in the domain layer.
abstract interface class StarNyxRepository {
  // Create and edit flows need the latest list of habits on demand.
  Future<List<StarNyx>> getAllStarnyxs();

  // Watchers keep the active habit picker and home screen reactive.
  Stream<List<StarNyx>> watchAllStarnyxs();

  // Detail and edit flows look up one habit by its stable id.
  Future<StarNyx?> getStarnyxById(String id);

  // Save abstracts both create and update behavior behind one call.
  Future<void> saveStarnyx(StarNyx starnyx);

  // Delete removes the habit and lets lower layers handle related cleanup.
  Future<void> deleteStarnyxById(String id);
}
