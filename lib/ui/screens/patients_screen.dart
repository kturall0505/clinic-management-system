import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});
  @override State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Patient> _patients = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _patients = [];
    setState(() => _loading = false);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => {})]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? const Center(child: Text('No patients'))
              : ListView.builder(
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final p = _patients[index];
                    return Card(
                      child: ListTile(
                        leading: Text(p.fullName),
                        subtitle: Text('${p.phone}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Delete patient'),
                              content: Text('Delete ${p.fullName}?'),
                              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Delete'))],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}