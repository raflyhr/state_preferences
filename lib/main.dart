import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    //  : ChangeNotifierProvider menyediakan UserProvider ke subtree.
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Latihan 4: Consumer<UserProvider> mengakses state UserProvider.
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'State & Preferences',
          debugShowCheckedModeBanner: false,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
