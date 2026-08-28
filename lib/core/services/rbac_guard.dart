import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/services/auth_service.dart';

class RbacGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? fallback;

  const RbacGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (auth.currentUser == null || !allowedRoles.contains(auth.currentUser!.role)) {
      return fallback ?? _buildAccessDenied();
    }
    return child;
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 64, color: AppTheme.error),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              'Giriş icazəsi yoxdur',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              'Bu bölməyə giriş üçün kifayət qədər hüququnuz yoxdur',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
