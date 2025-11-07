import 'package:family_planner/presentation/providers/gigachat_provider.dart';
import 'package:family_planner/presentation/screens/splash_screen.dart';
import 'package:family_planner/providers/family_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xhmvrrsmncnxuxerlnbn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhobXZycnNtbmNueHV4ZXJsbmJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzODQzODksImV4cCI6MjA3NTk2MDM4OX0.599elK4h4c6bt-tYUuFHHtmzsqcZ55tbyMU0T4QmZ5w',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => GigaChatProvider()), // Новый провайдер
      ],
      child: MaterialApp(
        title: 'Infancy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}