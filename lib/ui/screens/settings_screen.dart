import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/settings_provider.dart';
import '../../core/services/integration_settings.dart';
import '../../core/models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _reminderMinutes = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _reminderMinutes = prefs.getInt('reminder_minutes') ?? 60;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setInt('reminder_minutes', _reminderMinutes);

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectivity = context.watch<ConnectivityService>();
    final settings = context.watch<SettingsProvider>();
    final integration = context.watch<IntegrationSettings>();
    final auth = context.watch<AuthService>();
    final role = auth.currentUser?.role;

    final canManageIntegrations = auth.hasAnyRole([UserRole.superAdmin, UserRole.moderator, UserRole.auditor, UserRole.clinicAdmin]);
    final canChangePassword = auth.hasAnyRole([UserRole.superAdmin, UserRole.moderator, UserRole.auditor, UserRole.clinicAdmin, UserRole.doctor, UserRole.receptionist, UserRole.patient]);
    final canViewApprovals = role == UserRole.clinicAdmin;

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
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (v) {
                settings.setThemeMode(v ? ThemeMode.dark : ThemeMode.system);
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Card(
            child: ListTile(
              title: const Text('Dil'),
              subtitle: Text(settings.locale.languageCode == 'az' ? 'Azərbaycan' : 'English'),
              trailing: DropdownButton<String>(
                value: settings.locale.languageCode,
                items: const [
                  DropdownMenuItem(value: 'az', child: Text('Azərbaycan')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) {
                  if (v != null) settings.setLocale(Locale(v));
                },
              ),
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
          if (canManageIntegrations) ...[
            _buildSectionTitle(theme, 'İnteqrasiyalar'),
            const SizedBox(height: AppTheme.spacing3),
            _buildIntegrationCard(theme, integration),
            const SizedBox(height: AppTheme.spacing4),
          ],
          if (canChangePassword) ...[
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
            const SizedBox(height: AppTheme.spacing2),
            Card(
              child: FutureBuilder(
                future: context.read<TwoFactorService>().isEnabled(auth.currentUser?.id ?? ''),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.data ?? false;
                  return SwitchListTile(
                    title: const Text('İki Faktorlu Doğrulama (2FA)'),
                    subtitle: Text(isEnabled ? 'Aktiv' : 'Deaktiv'),
                    value: isEnabled,
                    onChanged: (v) async {
                      if (v) {
                        final secret = await context.read<TwoFactorService>().generateSecret(auth.currentUser?.id ?? '');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('2FA aktivləşdirildi. Secret: $secret')),
                          );
                        }
                      } else {
                        await context.read<TwoFactorService>().disable(auth.currentUser?.id ?? '');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('2FA deaktiv edildi')),
                          );
                        }
                      }
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
          ],
          if (auth.hasAnyRole([UserRole.superAdmin, UserRole.moderator, UserRole.auditor])) ...[
            _buildSectionTitle(theme, 'IP Məhdudiyyəti'),
            const SizedBox(height: AppTheme.spacing3),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lan_rounded),
                title: const Text('IP Whitelist'),
                subtitle: const Text('Super Admin giriş IP-ləri'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const _IpWhitelistDialog(),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
          ],
          if (canViewApprovals) ...[
            _buildSectionTitle(theme, 'Gözləyən Təsdiqlər'),
            const SizedBox(height: AppTheme.spacing3),
            FutureBuilder(
              future: context.read<ApprovalRepository>().findPending(),
              builder: (context, snapshot) {
                final pending = snapshot.data as List<ApprovalRequest>? ?? [];
                if (pending.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      child: Text('Gözləyən təsdiq yoxdur', style: theme.textTheme.bodyMedium),
                    ),
                  );
                }
                return Column(
                  children: pending.map((approval) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                      child: ListTile(
                        title: Text(approval.type.name),
                        subtitle: Text('Tarix: ${DateFormat('yyyy-MM-dd HH:mm').format(approval.createdAt)}'),
                        trailing: const Icon(Icons.pending_rounded, color: AppTheme.warning),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacing4),
          ],
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

  Widget _buildIntegrationCard(ThemeData theme, IntegrationSettings integration) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.integrations_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: AppTheme.spacing2),
                Text('Xarici Servislər', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                _buildStatusBadge(integration.hasAnyIntegration ? 'Aktiv' : 'Deaktiv', 
                  integration.hasAnyIntegration ? AppTheme.success : AppTheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: AppTheme.spacing3),
            _IntegrationTile(
              title: 'Supabase',
              subtitle: integration.isSupabaseConfigured ? 'Konfiqurasiya edilib' : 'Konfiqurasiya edilməyib',
              icon: Icons.cloud_rounded,
              isConfigured: integration.isSupabaseConfigured,
              onTap: () => _showSupabaseDialog(integration),
            ),
            const Divider(height: 1),
            _IntegrationTile(
              title: 'AI Backend',
              subtitle: integration.isAiConfigured ? integration.aiEndpoint : 'Konfiqurasiya edilməyib',
              icon: Icons.smart_toy_rounded,
              isConfigured: integration.isAiConfigured,
              onTap: () => _showAiDialog(integration),
            ),
            const Divider(height: 1),
            _IntegrationTile(
              title: 'License Server',
              subtitle: integration.isLicenseConfigured ? 'Konfiqurasiya edilib' : 'Konfiqurasiya edilməyib',
              icon: Icons.verified_rounded,
              isConfigured: integration.isLicenseConfigured,
              onTap: () => _showLicenseDialog(integration),
            ),
            const Divider(height: 1),
            _IntegrationTile(
              title: 'Ödəniş Gateway',
              subtitle: integration.paymentGateway == 'none' ? 'Konfiqurasiya edilməyib' : integration.paymentGateway,
              icon: Icons.payment_rounded,
              isConfigured: integration.isPaymentConfigured,
              onTap: () => _showPaymentDialog(integration),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Avtomatik Sinxronizasiya'),
              subtitle: const Text('Bağlantı yeniləndikdə avtomatik sync'),
              value: integration.autoSyncEnabled,
              onChanged: (v) async {
                await integration.setAutoSyncEnabled(v);
                setState(() {});
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Polling Interval'),
              subtitle: Text('${integration.pollingInterval} saniyə'),
              trailing: DropdownButton<int>(
                value: integration.pollingInterval,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 sn')),
                  DropdownMenuItem(value: 30, child: Text('30 sn')),
                  DropdownMenuItem(value: 60, child: Text('1 dəq')),
                  DropdownMenuItem(value: 120, child: Text('2 dəq')),
                ],
                onChanged: (v) async {
                  if (v != null) {
                    await integration.setPollingInterval(v);
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _showSupabaseDialog(IntegrationSettings integration) async {
    final urlController = TextEditingController(text: integration.supabaseUrl);
    final keyController = TextEditingController(text: integration.supabaseAnonKey);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supabase Konfiqurasiyası'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Supabase URL'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: keyController,
                decoration: const InputDecoration(labelText: 'Anon Key'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              await integration.setSupabaseUrl(urlController.text);
              await integration.setSupabaseAnonKey(keyController.text);
              AppConfig.updateFromIntegrationSettings(integration);
              Navigator.pop(context);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supabase konfiqurasiyası yeniləndi')),
                );
              }
            },
            child: const Text('Yadda saxla'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAiDialog(IntegrationSettings integration) async {
    final endpointController = TextEditingController(text: integration.aiEndpoint);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Backend Konfiqurasiyası'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: endpointController,
                decoration: const InputDecoration(labelText: 'AI Endpoint URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              await integration.setAiEndpoint(endpointController.text);
              AppConfig.updateFromIntegrationSettings(integration);
              Navigator.pop(context);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI konfiqurasiyası yeniləndi')),
                );
              }
            },
            child: const Text('Yadda saxla'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLicenseDialog(IntegrationSettings integration) async {
    final serverController = TextEditingController(text: integration.licenseServerUrl);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('License Server Konfiqurasiyası'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: serverController,
                decoration: const InputDecoration(labelText: 'License Server URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              await integration.setLicenseServerUrl(serverController.text);
              AppConfig.updateFromIntegrationSettings(integration);
              Navigator.pop(context);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('License server konfiqurasiyası yeniləndi')),
                );
              }
            },
            child: const Text('Yadda saxla'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDialog(IntegrationSettings integration) async {
    final gatewayController = TextEditingController(text: integration.paymentGateway);
    final publicKeyController = TextEditingController(text: integration.paymentPublicKey);
    final secretKeyController = TextEditingController(text: integration.paymentSecretKey);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ödəniş Gateway Konfiqurasiyası'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gateway'),
                  value: gatewayController.text,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Yox')),
                    DropdownMenuItem(value: 'stripe', child: Text('Stripe')),
                    DropdownMenuItem(value: 'paytr', child: Text('PayTR')),
                  ],
                  onChanged: (v) {
                    if (v != null) gatewayController.text = v;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: publicKeyController,
                  decoration: const InputDecoration(labelText: 'Public Key'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: secretKeyController,
                  decoration: const InputDecoration(labelText: 'Secret Key'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
            FilledButton(
              onPressed: () async {
                await integration.setPaymentGateway(gatewayController.text);
                await integration.setPaymentPublicKey(publicKeyController.text);
                await integration.setPaymentSecretKey(secretKeyController.text);
                Navigator.pop(context);
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ödəniş konfiqurasiyası yeniləndi')),
                  );
                }
              },
              child: const Text('Yadda saxla'),
            ),
          ],
        ),
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

class _IntegrationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isConfigured;
  final VoidCallback onTap;

  const _IntegrationTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isConfigured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isConfigured ? AppTheme.success : theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
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

      final newSalt = AuthService.generateSalt();
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

class _IpWhitelistDialog extends StatefulWidget {
  const _IpWhitelistDialog();

  @override
  State<_IpWhitelistDialog> createState() => _IpWhitelistDialogState();
}

class _IpWhitelistDialogState extends State<_IpWhitelistDialog> {
  final _ipController = TextEditingController();
  final _labelController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ipWhitelistService = context.read<IpWhitelistService>();

    return AlertDialog(
      title: const Text('IP Whitelist'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'IP Ünvanı'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Etiket'),
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: ipWhitelistService.getAll(),
              builder: (context, snapshot) {
                final entries = snapshot.data as List<IpWhitelistEntry>? ?? [];
                if (entries.isEmpty) {
                  return const Text('IP yoxdur');
                }
                return Column(
                  children: entries.map((entry) {
                    return ListTile(
                      dense: true,
                      title: Text(entry.ipAddress),
                      subtitle: Text(entry.label),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                        onPressed: () async {
                          await ipWhitelistService.removeIp(entry.ipAddress);
                          setState(() {});
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bağla')),
        FilledButton(
          onPressed: _isLoading ? null : () async {
            if (_ipController.text.isEmpty || _labelController.text.isEmpty) return;
            setState(() => _isLoading = true);
            try {
              await ipWhitelistService.addIp(_ipController.text, _labelController.text, 'admin');
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IP əlavə edildi')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Xəta: $e')),
              );
            } finally {
              setState(() => _isLoading = false);
            }
          },
          child: _isLoading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Əlavə et'),
        ),
      ],
    );
  }
}
