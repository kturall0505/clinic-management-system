import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';

class ForcePasswordChangeScreen extends StatefulWidget {
  const ForcePasswordChangeScreen({super.key});

  @override
  State<ForcePasswordChangeScreen> createState() => _ForcePasswordChangeScreenState();
}

class _ForcePasswordChangeScreenState extends State<ForcePasswordChangeScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Şifrələr uyğun deyil');
      return;
    }

    if (!AuthService.isPasswordStrong(_newPasswordController.text)) {
      setState(() => _errorMessage = 'Şifrə ən az 6 simvol olmalıdır və hərf və rəqəm ehtiva etməlidir');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthService>();
      final user = auth.currentUser;
      if (user == null) return;

      final newSalt = AuthService.generateSalt();
      final newHash = AuthService.hashPassword(_newPasswordController.text, newSalt);
      final updatedUser = user.copyWith(
        passwordHash: newHash,
        salt: newSalt,
        requiresPasswordChange: false,
      );

      final userRepo = context.read<UserRepository>();
      await userRepo.save(updatedUser);

      auth._currentUser = updatedUser;
      auth.notifyListeners();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifrə uğurla dəyişdirildi')),
        );
      }
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Xəta: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_reset_rounded, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Şifrəni Dəyiş',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  'Təhlükəsizlik üçün ilk girişdə şifrənizi dəyişmək məcburiyyətindəsiniz',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing4),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Yeni şifrə',
                    prefixIcon: Icon(Icons.lock_rounded),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppTheme.spacing3),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifrəni təkrar daxil edin',
                    prefixIcon: Icon(Icons.lock_rounded),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppTheme.spacing4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Şifrəni dəyiş'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
