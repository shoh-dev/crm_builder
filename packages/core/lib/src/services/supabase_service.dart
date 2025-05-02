import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core.dart';

class SupabaseService {
  SupabaseService._(this.client);
  static late final SupabaseService _instance;
  final SupabaseClient client;

  static SupabaseService get I => _instance;

  /// Call once in `main()` **before** `runApp`.
  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnon);
    _instance = SupabaseService._(Supabase.instance.client);
  }

  // ---------- CRUD helpers (1‑liner wrappers) ----------
  Future<List<Map<String, dynamic>>> fetchWorkspaces() =>
      client.from('workspaces').select();

  Future<Map<String, dynamic>> createWorkspace(String name) async =>
      (await client
          .from('workspaces')
          .insert({'name': name})
          .select()
          .single());

  Future<List<Map<String, dynamic>>> fetchProjects(String workspaceId) =>
      client.from('projects').select().eq('workspace_id', workspaceId);
}
