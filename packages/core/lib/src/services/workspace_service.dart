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
          await SupabaseService.I.client.from('workspaces').insert([
            for (int i = 0; i < 100; i++) {'name': 'Demo Workspace $i'},
          ]).select();

      return right(row.first);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
