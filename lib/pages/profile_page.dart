import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latres_prak_mobile/pages/login_page.dart';
import 'package:latres_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences _prefs;
  bool _isLoading = true;
  String? _username;
  String? _name;
  String? _nim;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    _prefs = await SharedPreferences.getInstance();

    final String? username = _prefs.getString('username');
    final String? photoPath = _prefs.getString('profile_photo_path');

    final box = await Hive.openBox('users');
    final userData = box.get(username) as Map?;

    setState(() {
      _username = username;
      _name = userData?['name'];
      _nim = userData?['nim'];
      _photoPath = photoPath;
      _isLoading = false;
    });
  }

  Future<void> _showImageSourceDialog() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: OtsuColor.primary),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: OtsuColor.primary),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      _getImage(source);
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
      );

      if (image != null) {
        await _prefs.setString('profile_photo_path', image.path);
        setState(() {
          _photoPath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: OtsuColor.surface,
                          backgroundImage: _photoPath != null
                              ? FileImage(File(_photoPath!))
                              : null,
                          child: _photoPath == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 80,
                                  color: OtsuColor.grey,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: OtsuColor.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: OtsuColor.background, width: 3)
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: _showImageSourceDialog,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _name ?? 'N/A',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: OtsuColor.primary,
                            fontSize: 26
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${_username ?? 'N/A'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: OtsuColor.grey,
                            fontSize: 18
                          ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      decoration: BoxDecoration(
                        color: OtsuColor.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: OtsuColor.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            Icons.badge_outlined,
                            "NIM",
                            _nim ?? 'N/A',
                          ),
                          Divider(color: OtsuColor.background.withOpacity(0.8), height: 1, indent: 20, endIndent: 20),
                          _buildInfoTile(
                            Icons.person_outline_rounded,
                            "Full Name",
                            _name ?? 'N/A',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    
                    ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.9),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                          )
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: OtsuColor.primary, size: 28),
      title: Text(
        title,
        style: const TextStyle(color: OtsuColor.grey, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: OtsuColor.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}