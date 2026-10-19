import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../main_shell.dart';

InputDecoration _dec(String hint, {Widget? suffix, IconData? icon}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kMuted),
      filled: true,
      fillColor: kSurface,
      prefixIcon: icon == null ? null : Icon(icon, color: kMuted),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      errorStyle: const TextStyle(color: kDanger),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kGold, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kDanger)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kDanger)),
    );

Widget _authScaffold(BuildContext context,
        {required String title, required String sub, required Widget body}) =>
    Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        glow: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 56, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PocketLogo(size: 64),
                const SizedBox(height: 22),
                Text(title,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
                const SizedBox(height: 8),
                Text(sub, style: const TextStyle(color: kMuted, fontSize: 16)),
                const SizedBox(height: 28),
                body,
              ],
            ),
          ),
        ),
      ),
    );

void _toHome(BuildContext context) => Navigator.pushAndRemoveUntil(context,
    MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true, _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(_email.text.trim(), _pass.text);
      if (!mounted) return;
      _toHome(context);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    } catch (_) {
      if (mounted) toast(context, 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _authScaffold(
        context,
        title: 'Selamat datang\nkembali',
        sub: 'Masuk untuk melihat Pocket dari temanmu.',
        body: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Email', icon: Icons.mail_rounded),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Masukkan email yang valid'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pass,
                obscureText: _hide,
                decoration: _dec('Kata sandi',
                    icon: Icons.lock_rounded,
                    suffix: IconButton(
                        icon: Icon(
                            _hide ? Icons.visibility_off : Icons.visibility,
                            color: kMuted),
                        onPressed: () => setState(() => _hide = !_hide))),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen())),
                  child: const Text('Lupa kata sandi?',
                      style: TextStyle(color: kGold)),
                ),
              ),
              const SizedBox(height: 8),
              GoldButton(
                  label: 'Masuk',
                  width: double.infinity,
                  loading: _loading,
                  glow: true,
                  onTap: _submit),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Belum punya akun? Daftar',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true, _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(_name.text.trim(),
          _user.text.trim(), _email.text.trim(), _pass.text);
      if (!mounted) return;
      _toHome(context);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    } catch (_) {
      if (mounted) toast(context, 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _authScaffold(
        context,
        title: 'Buat akunmu',
        sub: 'Hanya butuh beberapa detik.',
        body: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Nama', icon: Icons.person_rounded),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _user,
                decoration: _dec('Username', icon: Icons.alternate_email_rounded),
                validator: (v) => RegExp(r'^[a-zA-Z0-9._]{3,20}$')
                        .hasMatch(v?.trim() ?? '')
                    ? null
                    : '3-20 karakter: huruf, angka, titik, _',
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Email', icon: Icons.mail_rounded),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Masukkan email yang valid'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pass,
                obscureText: _hide,
                decoration: _dec('Kata sandi',
                    icon: Icons.lock_rounded,
                    suffix: IconButton(
                        icon: Icon(
                            _hide ? Icons.visibility_off : Icons.visibility,
                            color: kMuted),
                        onPressed: () => setState(() => _hide = !_hide))),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 26),
              GoldButton(
                  label: 'Daftar',
                  width: double.infinity,
                  loading: _loading,
                  glow: true,
                  onTap: _submit),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Sudah punya akun? Masuk',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_email.text.contains('@')) {
      toast(context, 'Masukkan email yang valid');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().forgot(_email.text.trim());
      if (!mounted) return;
      toast(context, 'Tautan reset dikirim ke email kamu');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _authScaffold(
        context,
        title: 'Lupa kata sandi?',
        sub: 'Kami kirim tautan untuk mengatur ulang kata sandimu.',
        body: Column(
          children: [
            TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Email', icon: Icons.mail_rounded)),
            const SizedBox(height: 24),
            GoldButton(
                label: 'Kirim tautan',
                width: double.infinity,
                loading: _loading,
                onTap: _submit),
          ],
        ),
      );
}
