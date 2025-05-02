import 'package:fpdart/fpdart.dart';
import '../failure.dart';
import 'supabase_service.dart';

typedef F<T> = Either<Failure, T>;

class ProjectService {
  ProjectService._();
  static final ProjectService I = ProjectService._();

  Future<F<Map<String, dynamic>>> getOrCreateDemo(String workspaceId) async {
    try {
      final rows = await SupabaseService.I.client
          .from('projects')
          .select()
          .eq('workspace_id', workspaceId)
          .limit(1);

      if (rows.isNotEmpty) return right(rows.first);

      final row =
          await SupabaseService.I.client
              .from('projects')
              .insert({'workspace_id': workspaceId, 'name': 'Demo Project'})
              .select()
              .single();

      return right(row);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<F<Map<String, dynamic>>> upsertLayout({
    required String projectId,
    required Map<String, dynamic> layout,
  }) async {
    try {
      final row =
          await SupabaseService.I.client
              .from('projects')
              .update({'layout': layout})
              .eq('id', projectId)
              .select()
              .single();
      return right(row);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
