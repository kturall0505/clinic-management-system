import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/services/report_service.dart';
import '../../core/models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportType _selectedType = ReportType.daily;
  DateTime _selectedDate = DateTime.now();
  bool _isGenerating = false;
  Report? _lastReport;

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      final reportService = context.read<ReportService>();
      final auth = context.read<AuthService>();
      final generatedBy = auth.currentUser?.fullName ?? 'Unknown';

      late Report report;
      switch (_selectedType) {
        case ReportType.daily:
          report = await reportService.generateDailyReport(_selectedDate, generatedBy);
          break;
        case ReportType.weekly:
          report = await reportService.generateWeeklyReport(_selectedDate, generatedBy);
          break;
        case ReportType.monthly:
          report = await reportService.generateMonthlyReport(_selectedDate.year, _selectedDate.month, generatedBy);
          break;
        case ReportType.custom:
          report = await reportService.generateCustomReport(
            _selectedDate,
            _selectedDate.add(const Duration(days: 30)),
            _selectedType,
            generatedBy,
          );
          break;
      }

      final reportsRepo = context.read<ReportRepository>();
      await reportsRepo.save(report);
      final auth = context.read<AuthService>();
      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: auth.currentUser?.id ?? '',
        userName: auth.currentUser?.fullName ?? 'System',
        userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
        action: AuditAction.create,
        entityType: 'Report',
        entityId: report.id,
        entityName: report.type.label,
      );
      setState(() => _lastReport = report);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
    }
  } finally {
    setState(() => _isGenerating = false);
  }
}

  Future<void> _exportReport() async {
    final report = _lastReport;
    if (report == null) return;

    final buffer = StringBuffer();
    buffer.writeln('Hesabat: ${report.type.label}');
    buffer.writeln('Tarix: ${DateFormat('yyyy-MM-dd').format(report.startDate)} - ${DateFormat('yyyy-MM-dd').format(report.endDate)}');
    buffer.writeln('Yaradan: ${report.generatedBy}');
    buffer.writeln('Tarix: ${DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt)}');
    buffer.writeln();
    buffer.writeln('Xülasə:');
    final summary = report.data['summary'] as Map<String, dynamic>? ?? {};
    buffer.writeln('  Pasientlər: ${summary['total_patients'] ?? 0}');
    buffer.writeln('  Randevular: ${summary['total_appointments'] ?? 0}');
    buffer.writeln('  Tamamlanan: ${summary['completed_appointments'] ?? 0}');
    buffer.writeln('  Ziyarətlər: ${summary['total_visits'] ?? 0}');
    buffer.writeln();
    buffer.writeln('Maliyyə:');
    final financial = report.data['financial'] as Map<String, dynamic>? ?? {};
    buffer.writeln('  Ümumi gəlir: ${(financial['total_revenue'] ?? 0).toStringAsFixed(2)} AZN');
    buffer.writeln('  Fakturalar: ${financial['total_invoices'] ?? 0}');
    buffer.writeln('  Ödənilən: ${financial['paid_invoices'] ?? 0}');
    buffer.writeln('  Gözləyən: ${financial['pending_invoices'] ?? 0}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hesabat eksport edildi (${buffer.length} bayt)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Hesabatlar',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ReportType>(
                  decoration: const InputDecoration(
                    labelText: 'Hesabat növü',
                    prefixIcon: Icon(Icons.analytics_rounded),
                  ),
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: ReportType.daily, child: Text('Günlük')),
                    DropdownMenuItem(value: ReportType.weekly, child: Text('Həftəlik')),
                    DropdownMenuItem(value: ReportType.monthly, child: Text('Aylıq')),
                    DropdownMenuItem(value: ReportType.custom, child: Text('Fərdi')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v ?? ReportType.daily),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && mounted) {
                    setState(() => _selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
              const SizedBox(width: AppTheme.spacing3),
              FilledButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh_rounded),
                label: const Text('Yenilə'),
              ),
              if (_lastReport != null) ...[
                const SizedBox(width: AppTheme.spacing2),
                IconButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Eksport',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            child: _lastReport == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          'Hesabat yoxdur',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Text(
                          'Yuxarıdakı parametrləri seçib "Yenilə" düyməsinə basın',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(theme),
                      const SizedBox(height: AppTheme.spacing4),
                      _buildSectionTitle(theme, 'Maliyyə'),
                      const SizedBox(height: AppTheme.spacing2),
                      _buildFinancialCard(theme),
                      const SizedBox(height: AppTheme.spacing4),
                      _buildSectionTitle(theme, 'Həkim performansı'),
                      const SizedBox(height: AppTheme.spacing2),
                      _buildDoctorPerformance(theme),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    final data = _lastReport?.data ?? {};
    final summary = data['summary'] as Map<String, dynamic>? ?? {};

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _StatCard(label: 'Pasientlər', value: '${summary['total_patients'] ?? 0}', icon: Icons.people, theme: theme)),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(child: _StatCard(label: 'Randevular', value: '${summary['total_appointments'] ?? 0}', icon: Icons.event, theme: theme)),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(child: _StatCard(label: 'Tamamlanan', value: '${summary['completed_appointments'] ?? 0}', icon: Icons.check_circle, theme: theme)),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(child: _StatCard(label: 'Ziyarətlər', value: '${summary['total_visits'] ?? 0}', icon: Icons.health_and_safety, theme: theme)),
            ],
          );
        }
        return Wrap(
          spacing: AppTheme.spacing2,
          runSpacing: AppTheme.spacing2,
          children: [
            SizedBox(width: 150, child: _StatCard(label: 'Pasientlər', value: '${summary['total_patients'] ?? 0}', icon: Icons.people, theme: theme)),
            SizedBox(width: 150, child: _StatCard(label: 'Randevular', value: '${summary['total_appointments'] ?? 0}', icon: Icons.event, theme: theme)),
            SizedBox(width: 150, child: _StatCard(label: 'Tamamlanan', value: '${summary['completed_appointments'] ?? 0}', icon: Icons.check_circle, theme: theme)),
            SizedBox(width: 150, child: _StatCard(label: 'Ziyarətlər', value: '${summary['total_visits'] ?? 0}', icon: Icons.health_and_safety, theme: theme)),
          ],
        );
      },
    );
  }

  Widget _StatCard({required String label, required String value, required IconData icon, required ThemeData theme}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing3),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: AppTheme.spacing2),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFinancialCard(ThemeData theme) {
    final data = _lastReport?.data ?? {};
    final financial = data['financial'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 500;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _FinancialItem(label: 'Ümumi gəlir', value: '${(financial['total_revenue'] ?? 0).toStringAsFixed(2)} AZN', theme: theme)),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(child: _FinancialItem(label: 'Fakturalar', value: '${financial['total_invoices'] ?? 0}', theme: theme)),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(child: _FinancialItem(label: 'Ödənilən', value: '${financial['paid_invoices'] ?? 0}', theme: theme)),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(child: _FinancialItem(label: 'Gözləyən', value: '${financial['pending_invoices'] ?? 0}', theme: theme)),
                ],
              );
            }
            return Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                SizedBox(width: 150, child: _FinancialItem(label: 'Ümumi gəlir', value: '${(financial['total_revenue'] ?? 0).toStringAsFixed(2)} AZN', theme: theme)),
                SizedBox(width: 150, child: _FinancialItem(label: 'Fakturalar', value: '${financial['total_invoices'] ?? 0}', theme: theme)),
                SizedBox(width: 150, child: _FinancialItem(label: 'Ödənilən', value: '${financial['paid_invoices'] ?? 0}', theme: theme)),
                SizedBox(width: 150, child: _FinancialItem(label: 'Gözləyən', value: '${financial['pending_invoices'] ?? 0}', theme: theme)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _FinancialItem({required String label, required String value, required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDoctorPerformance(ThemeData theme) {
    final data = _lastReport?.data ?? {};
    final doctors = data['doctors'] as Map<String, dynamic>? ?? {};

    if (doctors.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text('Həkim məlumatı yoxdur', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: doctors.entries.map((entry) {
            final stats = entry.value as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(stats['specialty'] ?? '', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  _PerformanceBadge(label: 'Randevu', value: '${stats['total_appointments'] ?? 0}', theme: theme),
                  const SizedBox(width: AppTheme.spacing2),
                  _PerformanceBadge(label: 'Tamamlanan', value: '${stats['completed'] ?? 0}', theme: theme),
                  const SizedBox(width: AppTheme.spacing2),
                  _PerformanceBadge(
                    label: 'Faiz',
                    value: '${((stats['completion_rate'] ?? 0) * 100).toStringAsFixed(0)}%',
                    theme: theme,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _PerformanceBadge({required String label, required String value, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
