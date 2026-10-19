import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name =
      TextEditingController(text: context.read<AuthProvider>().user?.name);
  late final _user =
      TextEditingController(text: context.read<AuthProvider>().user?.username);
  bool _saving = false;

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context
          .read<AuthProvider>()
          .updateProfile(_name.text.trim(), _user.text.trim());
      if (!mounted) return;
      toast(context, 'Profil diperbarui');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profil')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (me != null) Center(child: Avatar(me, size: 100, ring: true)),
              const SizedBox(height: 28),
              TextField(controller: _name, decoration: _dec('Nama')),
              const SizedBox(height: 14),
              TextField(controller: _user, decoration: _dec('Username')),
              const SizedBox(height: 28),
              GoldButton(
                  label: 'Simpan',
                  width: double.infinity,
                  loading: _saving,
                  onTap: _save),
            ],
          ),
        ),
      ),
    );
  }
}
