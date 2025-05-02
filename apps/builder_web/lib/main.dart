import 'package:flutter/material.dart';
import 'package:core/src/services/supabase_service.dart';
import 'ui/builder/builder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init(); // <- new
  runApp(const CRMBuilderApp());
}

class CRMBuilderApp extends StatelessWidget {
  const CRMBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const BuilderScreen(),
    );
  }
}
