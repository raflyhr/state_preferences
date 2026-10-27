import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _favController = TextEditingController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider = context.read<UserProvider>();
      _nameController = TextEditingController(text: provider.user.name);
      _emailController = TextEditingController(text: provider.user.email);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favController.dispose();
    super.dispose();
  }

  // Latihan 5: Validasi Keamanan dan Menyimpan Profil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    final nameText = _nameController.text.trim();
    final emailText = _emailController.text.trim();

    // Latihan 5b: Cek karakter/tag berbahaya (misal <script>)
    final scriptRegex = RegExp(r'<[^>]*>|script', caseSensitive: false);
    if (scriptRegex.hasMatch(nameText) || scriptRegex.hasMatch(emailText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terdeteksi karakter atau tag berbahaya!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Latihan 5a: Cek jika email sudah terdaftar
    if (emailText != provider.user.email && await provider.isEmailRegistered(emailText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tersebut sudah pernah terdaftar!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedUser = provider.user.copyWith(
      name: nameText,
      email: emailText,
      isLoggedIn: true,
    );
    await provider.updateUser(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<UserProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Latihan 4: Consumer<UserProvider> membaca dan memperbarui state.
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              if (provider.user.isLoggedIn)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Nama',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Profil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Latihan 3: Form & Daftar Favorit
                        const Text(
                          'Daftar Favorit / Hobi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _favController,
                                labelText: 'Tambah Hobi / Favorit',
                                prefixIcon: Icons.favorite_border,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: () {
                                if (_favController.text.isNotEmpty) {
                                  provider.addFavorite(_favController.text);
                                  _favController.clear();
                                }
                              },
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(backgroundColor: Colors.deepPurple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        provider.favorites.isEmpty
                            ? const Text('Belum ada item favorit tersimpan.', style: TextStyle(color: Colors.grey))
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: provider.favorites.map((item) {
                                  return Chip(
                                    label: Text(item),
                                    onDeleted: () => provider.removeFavorite(item),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                  );
                                }).toList(),
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
