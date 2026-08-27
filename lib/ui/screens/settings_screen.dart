import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'az';
  int _reminderMinutes = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'az';
      _reminderMinutes = prefs.getInt('reminder_minutes') ?? 60;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setString('language', _selectedLanguage);
      await prefs.setInt('reminder_minutes', _reminderMinutes);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tənzimləmələr yadda saxlanıldı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectivity = context.watch<ConnectivityService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tənzimləmələr'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            onPressed: _isLoading ? null : _saveSettings,
            tooltip: 'Yadda saxla',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        children: [
          _buildSectionTitle(theme, 'Görünüş'),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: SwitchListTile(
              title: const Text('Qaranlıq rejim'),
              subtitle: const Text('Tətbiqin mövzusunu dəyişdir'),
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: DropdownButtonFormTile(
              title: 'Dil',
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'az', child: Text('Azərbaycan')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => setState(() => _selectedLanguage = v ?? 'az'),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _buildSectionTitle(theme, 'Bildirişlər'),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: SwitchListTile(
              title: const Text('Bildirişləri aktiv et'),
              subtitle: const Text('Randevu xatırlatmaları və digər bildirişlər'),
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: ListTile(
              title: const Text('Xatırlatma vaxtı'),
              subtitle: Text('$_reminderMinutes dəqiqə əvvəl'),
              trailing: DropdownButton<int>(
                value: _reminderMinutes,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 dəq')),
                  DropdownMenuItem(value: 30, child: Text('30 dəq')),
                  DropdownMenuItem(value: 60, child: Text('1 saat')),
                  DropdownMenuItem(value: 120, child: Text('2 saat')),
                  DropdownMenuItem(value: 1440, child: Text('1 gün')),
                ],
                onChanged: (v) => setState(() => _reminderMinutes = v ?? 60),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _buildSectionTitle(theme, 'Şəbəkə'),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: ListTile(
              leading: Icon(
                connectivity.currentStatus == ConnectionStatus.online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: connectivity.currentStatus == ConnectionStatus.online ? AppTheme.success : AppTheme.error,
              ),
              title: Text(connectivity.currentStatus == ConnectionStatus.online ? 'Bağlı' : 'Bağlantı kəsilib'),
              subtitle: Text(connectivity.currentStatus == ConnectionStatus.online ? 'Online rejim' : 'Offline rejim'),
              trailing: TextButton.icon(
                onPressed: () async {
                  await connectivity.checkConnection();
                  setState(() {});
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Yenilə'),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _buildSectionTitle(theme, 'Təhlükəsizlik'),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_rounded),
              title: const Text('Şifrəni dəyiş'),
              subtitle: const Text('Hesab şifrəsini yenilə'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const _ChangePasswordDialog(),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _buildSectionTitle(theme, 'Haqqında'),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_rounded),
                  title: const Text('Versiya'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.policy_rounded),
                  title: const Text('Məxfilik siyasəti'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_rounded),
                  title: const Text('Xidmət şərtləri'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_rounded),
                  title: const Text('Kömək'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class DropdownButtonFormTile extends StatelessWidget {
  final String title;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const DropdownButtonFormTile({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifrələr uyğun deyil')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthService>();
      final user = auth.currentUser;
      if (user == null) return;

      final currentHash = AuthService.hashPassword(_currentController.text, user.salt);
      if (currentHash != user.passwordHash) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cari şifrə yanlışdır')),
        );
        return;
      }

      final newSalt = AuthService._generateSalt();
      final newHash = AuthService.hashPassword(_newController.text, newSalt);
      final updatedUser = user.copyWith(
        passwordHash: newHash,
        salt: newSalt,
      );
      await context.read<UserRepository>().save(updatedUser);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifrə uğurla dəyişdirildi')),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xəta: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şifrəni dəyiş'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentController,
            decoration: const InputDecoration(labelText: 'Cari şifrə'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            decoration: const InputDecoration(labelText: 'Yeni şifrə'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            decoration: const InputDecoration(labelText: 'Yeni şifrə (təkrar)'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
        FilledButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Dəyiş'),
        ),
      ],
    );
  }
}
