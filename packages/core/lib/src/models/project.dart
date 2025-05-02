import 'package:equatable/equatable.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    this.layout = const {},
    required this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final Map<String, dynamic> layout;
  final DateTime createdAt;

  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'] as String,
    workspaceId: j['workspace_id'] as String,
    name: j['name'] as String,
    description: j['description'] as String?,
    createdAt: DateTime.parse(j['created_at'] as String),
    layout: (j['layout'] ?? const {}) as Map<String, dynamic>,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workspace_id': workspaceId,
    'name': name,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'layout': layout,
  };

  @override
  List<Object?> get props => [id, workspaceId, name, description, createdAt];
}
