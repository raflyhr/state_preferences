import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Latihan 4: Consumer<UserProvider> membaca perubahan state.
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              // Latihan 1: Tombol Toggle Dark Mode
              IconButton(
                icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => provider.toggleDarkMode(),
                tooltip: 'Ubah Tema',
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  Text(
                    provider.user.isLoggedIn
                        ? 'Selamat datang, ${provider.user.name}!'
                        : 'Selamat datang, Tamu!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Latihan 2: Display Counter Kunjungan
                  Chip(
                    avatar: const Icon(Icons.touch_app, size: 18),
                    label: Text('Aplikasi dibuka: ${provider.visitCount} kali'),
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  if (provider.user.isLoggedIn) ...[
                    Text(
                      'Email: ${provider.user.email}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    icon: Icon(provider.user.isLoggedIn ? Icons.person : Icons.login),
                    label: Text(provider.user.isLoggedIn ? 'Lihat Profil' : 'Login / Daftar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
