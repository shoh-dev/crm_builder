import 'package:fpdart/fpdart.dart';
import '../failure.dart';
import 'supabase_service.dart';

typedef F<T> = Either<Failure, T>;

class WorkspaceService {
  WorkspaceService._();
  static final WorkspaceService I = WorkspaceService._();

  /// Get first workspace OR create a demo one, returns workspace row.
  Future<F<Map<String, dynamic>>> getOrCreateDemo() async {
    try {
      final rows = await SupabaseService.I.client
          .from('workspaces')
          .select()
          .limit(1);

      if (rows.isNotEmpty) return right(rows.first);

      final row =
          await SupabaseService.I.client
              .from('workspaces')
              .insert({'name': 'Demo Workspace'})
              .select()
              .single();

      return right(row);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
