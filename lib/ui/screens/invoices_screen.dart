import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/audit_log_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String? _selectedPatientId;
  String? _selectedAppointmentId;
  final _amountController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  String? _selectedPaymentMethod;
  bool _isCreating = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _invoiceItems = [];

  Future<void> _createInvoice() async {
    if (_selectedPatientId == null || _selectedAppointmentId == null) {
      setState(() => _errorMessage = 'Pasient və randevu seçin');
      return;
    }
    if (_invoiceItems.isEmpty) {
      setState(() => _errorMessage = 'Ən az bir xidmət əlavə edin');
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final invoiceRepo = context.read<InvoiceRepository>();
      final invoiceItemsRepo = context.read<InvoiceItemRepository>();
      final paymentRepo = context.read<PaymentRepository>();

      final totalAmount = _invoiceItems.fold<double>(0, (sum, item) => sum + (item['total'] as double));
      final discount = double.tryParse(_discountController.text) ?? 0;
      final tax = double.tryParse(_taxController.text) ?? 0;

      final invoice = Invoice.create(
        patientId: _selectedPatientId!,
        appointmentId: _selectedAppointmentId!,
        totalAmount: totalAmount,
        discount: discount,
        tax: tax,
        status: _selectedPaymentMethod != null ? 'paid' : 'pending',
        paymentMethod: _selectedPaymentMethod,
      );

      await invoiceRepo.save(invoice);

      final auth = context.read<AuthService>();
      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: auth.currentUser?.id ?? '',
        userName: auth.currentUser?.fullName ?? 'System',
        userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
        action: AuditAction.create,
        entityType: 'Invoice',
        entityId: invoice.id,
        entityName: invoice.patientId,
        changes: {'totalAmount': invoice.totalAmount, 'status': invoice.status},
      );

      for (final item in _invoiceItems) {
        final invoiceItem = InvoiceItem.create(
          invoiceId: invoice.id,
          description: item['description'] as String,
          quantity: item['quantity'] as int,
          unitPrice: item['unitPrice'] as double,
        );
        await invoiceItemsRepo.save(invoiceItem);
      }

      if (_selectedPaymentMethod != null) {
        final payment = Payment.create(
          appointmentId: _selectedAppointmentId!,
          patientId: _selectedPatientId!,
          amount: invoice.netAmount,
          method: _selectedPaymentMethod!,
          status: 'completed',
        );
        await paymentRepo.save(payment);
      }

      _selectedPatientId = null;
      _selectedAppointmentId = null;
      _amountController.clear();
      _discountController.text = '0';
      _taxController.text = '0';
      _selectedPaymentMethod = null;
      _invoiceItems.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(invoice.status == 'paid' ? 'Ödəniş uğurla qeyd edildi' : 'Faktura yaradıldı'),
          ),
        );
      }
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Xəta: $e');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _addInvoiceItem() {
    setState(() {
      _invoiceItems.add({
        'description': '',
        'quantity': 1,
        'unitPrice': 0.0,
        'total': 0.0,
      });
    });
  }

  void _removeInvoiceItem(int index) {
    setState(() => _invoiceItems.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientRepo = context.read<PatientRepository>();
    final appointmentRepo = context.read<AppointmentRepository>();
    final invoiceRepo = context.read<InvoiceRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Faktura və Ödəniş',
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
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.error),
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            children: [
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: patientRepo.all(),
                      builder: (context, snapshot) {
                        final patients = snapshot.data as List<Patient>? ?? [];
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Pasient',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          value: _selectedPatientId,
                          items: patients
                              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedPatientId = v);
                            _selectedAppointmentId = null;
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: FutureBuilder(
                      future: appointmentRepo.all(),
                      builder: (context, snapshot) {
                        final appointments = snapshot.data as List<Appointment>? ?? [];
                        final filtered = _selectedPatientId != null
                            ? appointments.where((a) => a.patientId == _selectedPatientId).toList()
                            : appointments;
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Randevu',
                            prefixIcon: Icon(Icons.event_note_rounded),
                          ),
                          value: _selectedAppointmentId,
                          items: filtered
                              .map((a) => DropdownMenuItem(value: a.id, child: Text(DateFormat('yyyy-MM-dd').format(a.dateTime))))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedAppointmentId = v),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Endirim (AZN)',
                        prefixIcon: Icon(Icons.discount_rounded),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: TextFormField(
                      controller: _taxController,
                      decoration: const InputDecoration(
                        labelText: 'Vergi (AZN)',
                        prefixIcon: Icon(Icons.account_balance_rounded),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                children: [
                  const Text('Xidmətlər:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _addInvoiceItem,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Əlavə et'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing2),
              if (_invoiceItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Text(
                    'Hələ xidmət əlavə edilməyib',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ...List.generate(_invoiceItems.length, (index) {
                final item = _invoiceItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing3),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: item['description'] as String?,
                            decoration: const InputDecoration(labelText: 'Açıqlama', isDense: true),
                            onChanged: (v) => item['description'] = v,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        Expanded(
                          child: TextFormField(
                            initialValue: (item['quantity'] as int).toString(),
                            decoration: const InputDecoration(labelText: 'Miqdar', isDense: true),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final qty = int.tryParse(v) ?? 1;
                              item['quantity'] = qty;
                              item['total'] = qty * (item['unitPrice'] as double);
                            },
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        Expanded(
                          child: TextFormField(
                            initialValue: (item['unitPrice'] as double).toStringAsFixed(2),
                            decoration: const InputDecoration(labelText: 'Qiymət', isDense: true),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final price = double.tryParse(v) ?? 0;
                              item['unitPrice'] = price;
                              item['total'] = (item['quantity'] as int) * price;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: AppTheme.error, size: 20),
                          onPressed: () => _removeInvoiceItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppTheme.spacing4),
              if (_invoiceItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cəmi:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${_invoiceItems.fold<double>(0, (sum, item) => sum + (item['total'] as double)).toStringAsFixed(2)} AZN',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppTheme.spacing3),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Ödəniş üsulu',
                  prefixIcon: Icon(Icons.payment_rounded),
                ),
                value: _selectedPaymentMethod,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Nağd')),
                  DropdownMenuItem(value: 'card', child: Text('Kart')),
                  DropdownMenuItem(value: 'insurance', child: Text('Sığorta')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank köçürmə')),
                ],
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              ),
              const SizedBox(height: AppTheme.spacing4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isCreating ? null : _createInvoice,
                  icon: _isCreating
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(_selectedPaymentMethod != null ? 'Ödənişli faktura yarat' : 'Faktura yarat'),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              const Divider(),
              const SizedBox(height: AppTheme.spacing2),
              Text('Fakturalar', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppTheme.spacing2),
              FutureBuilder(
                future: invoiceRepo.all(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final invoices = snapshot.data as List<Invoice>? ?? [];
                  if (invoices.isEmpty) {
                    return Text('Hələ faktura yoxdur', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final inv = invoices[index];
                      final statusColor = inv.status == 'paid' ? AppTheme.success : AppTheme.warning;
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.12),
                            child: Icon(Icons.receipt_long_rounded, color: statusColor),
                          ),
                          title: Text('Pasient: ${inv.patientId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${inv.netAmount.toStringAsFixed(2)} AZN • ${inv.status}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download_rounded, color: AppTheme.primary),
                                onPressed: () {
                                  final buffer = StringBuffer();
                                  buffer.writeln('Faktura #${inv.id.substring(0, 8)}');
                                  buffer.writeln('Pasient: ${inv.patientId}');
                                  buffer.writeln('Randevu: ${inv.appointmentId}');
                                  buffer.writeln('Məbləğ: ${inv.totalAmount.toStringAsFixed(2)} AZN');
                                  buffer.writeln('Endirim: ${inv.discount.toStringAsFixed(2)} AZN');
                                  buffer.writeln('Vergi: ${inv.tax.toStringAsFixed(2)} AZN');
                                  buffer.writeln('Net: ${inv.netAmount.toStringAsFixed(2)} AZN');
                                  buffer.writeln('Status: ${inv.status}');
                                  buffer.writeln('Tarix: ${DateFormat('yyyy-MM-dd HH:mm').format(inv.createdAt)}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Faktura eksport edildi (${buffer.length} bayt)')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Fakturanı sil'),
                                      content: const Text('Bu fakturanı silmək istədiyinizə əminsiniz?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
                                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await invoiceRepo.delete(inv.id);
                                    final auth = context.read<AuthService>();
                                    final audit = context.read<AuditLogService>();
                                    await audit.log(
                                      userId: auth.currentUser?.id ?? '',
                                      userName: auth.currentUser?.fullName ?? 'System',
                                      userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
                                      action: AuditAction.delete,
                                      entityType: 'Invoice',
                                      entityId: inv.id,
                                      entityName: inv.patientId,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faktura silindi')));
                                      setState(() {});
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
