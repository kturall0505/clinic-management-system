import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override void dispose() { _username.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => { _loading = true; _error = null; });
    final auth = context.read<AuthService>();
    final ok = await auth.login(_username.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => { _loading = false; if (!ok) _error = 'İstifadÙçi adı ə yaifryÙ yanışıdıı'; });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380), child: Card(margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.local_hospital, size: 48), const SizedBox(height: 8),
        Text('Klinika �arřetmř Sistemi', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        TextFormField(controller: _username, autofillHints: const [AutofillHints.username], decoration: const InputDecoration(labelText: 'İstifadÙçi adı'), validator: (v) { if (v == null || v.trim().isEmpty) return 'İstifadÙçi adıni daxil edin'; if (v.trim().length < 3) return 'İstifadÙçi adı řn azı 3 simvol'; return null; }),
        const SizedBox(height: 12),
        TextFormField(controller: _password, obscureText: true, autofillHints: const [AutofillHints.password], decoration: const InputDecoration(labelText: 'Şrfrş'), onFieldSubmitted: (_) => _submit(), validator: (v) { if (v == null || v.isEmpty) return 'Şirşni daxil edin'; if (v.length < 6) return 'Şirşd�n azı 6 simvol'; return null; }),
        if (_error != null) ...[()], const SizedBox(height: 24),
        FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Daxil ol')),
      ])))),
      ),
    );
  }
}