import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/audit_log_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.receptionist;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (_usernameController.text.isEmpty || _fullNameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Bütün sahələri doldurun');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthService>();
      await auth.register(
        username: _usernameController.text,
        password: _passwordController.text,
        role: _selectedRole,
        fullName: _fullNameController.text,
      );

      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: auth.currentUser?.id ?? '',
        userName: auth.currentUser?.fullName ?? 'System',
        userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
        action: AuditAction.create,
        entityType: 'User',
        entityName: _usernameController.text,
        changes: {'role': _selectedRole.name, 'fullName': _fullNameController.text},
      );

      _usernameController.clear();
      _fullNameController.clear();
      _passwordController.clear();
      setState(() => _selectedRole = UserRole.receptionist);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İstifadəçi uğurla əlavə edildi')),
        );
      }
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.message);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Xəta: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İstifadəçini sil'),
        content: Text('${user.fullName} istifadəçisini silmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final repo = context.read<UserRepository>();
      await repo.delete(user.id);

      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: context.read<AuthService>().currentUser?.id ?? '',
        userName: context.read<AuthService>().currentUser?.fullName ?? 'Unknown',
        userRole: context.read<AuthService>().currentUser?.role ?? UserRole.clinicAdmin,
        action: AuditAction.delete,
        entityType: 'User',
        entityId: user.id,
        entityName: user.username,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İstifadəçi silindi')),
        );
        setState(() {});
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    }
  }

  Future<void> _resetPassword(AppUser user) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifrəni sıfırla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${user.fullName} üçün yeni şifrə daxil edin'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Yeni şifrə'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Sıfırla')),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final auth = context.read<AuthService>();
      final newSalt = AuthService.generateSalt();
      final newHash = AuthService.hashPassword(result, newSalt);
      final updatedUser = user.copyWith(passwordHash: newHash, salt: newSalt);
      await context.read<UserRepository>().save(updatedUser);
      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: auth.currentUser?.id ?? '',
        userName: auth.currentUser?.fullName ?? 'System',
        userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
        action: AuditAction.update,
        entityType: 'User',
        entityId: user.id,
        entityName: user.username,
        changes: {'passwordReset': true},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifrə sıfırlandı')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRepo = context.read<UserRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'İstifadəçilər',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildTextField(_usernameController, 'İstifadəçi adı', Icons.person_outline)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_fullNameController, 'Ad Soyad', Icons.badge)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: DropdownButtonFormField<UserRole>(
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                        ),
                        value: _selectedRole,
                        items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                        onChanged: (v) => setState(() => _selectedRole = v ?? UserRole.receptionist),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_passwordController, 'Şifrə', Icons.lock_outline, TextInputType.visiblePassword)),
                    const SizedBox(width: AppTheme.spacing2),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _createUser,
                      icon: _isSaving
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add_rounded),
                      label: const Text('Əlavə et'),
                    ),
                  ],
                );
              }
              return Wrap(
                spacing: AppTheme.spacing2,
                runSpacing: AppTheme.spacing2,
                children: [
                  SizedBox(width: 160, child: _buildTextField(_usernameController, 'İstifadəçi adı', Icons.person_outline)),
                  SizedBox(width: 150, child: _buildTextField(_fullNameController, 'Ad Soyad', Icons.badge)),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<UserRole>(
                      decoration: const InputDecoration(labelText: 'Rol', prefixIcon: Icon(Icons.admin_panel_settings_outlined), isDense: true),
                      value: _selectedRole,
                      items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                      onChanged: (v) => setState(() => _selectedRole = v ?? UserRole.receptionist),
                    ),
                  ),
                  SizedBox(width: 130, child: _buildTextField(_passwordController, 'Şifrə', Icons.lock_outline, TextInputType.visiblePassword)),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _createUser,
                    icon: _isSaving
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_rounded),
                    label: const Text('Əlavə et'),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: userRepo.all(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Xəta baş verdi', style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }

              var users = snapshot.data as List<AppUser>? ?? [];

              if (_searchQuery.isNotEmpty) {
                users = users.where((u) => u.fullName.toLowerCase().contains(_searchQuery) || u.username.toLowerCase().contains(_searchQuery)).toList();
              }

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('İstifadəçi yoxdur', style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Axtarış...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                            ),
                            title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('@${user.username} • ${user.role.label}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.lock_reset_rounded, color: AppTheme.warning),
                                  tooltip: 'Şifrəni sıfırla',
                                  onPressed: () => _resetPassword(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                                  tooltip: 'Sil',
                                  onPressed: () => _deleteUser(user),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
      ),
    );
  }
}
