import 'package:equatable/equatable.dart';

class Workspace extends Equatable {
  const Workspace({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;

  factory Workspace.fromJson(Map<String, dynamic> j) => Workspace(
    id: j['id'] as String,
    name: j['name'] as String,
    ownerId: j['owner_id'] as String,
    createdAt: DateTime.parse(j['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'owner_id': ownerId,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, ownerId, createdAt];
}
