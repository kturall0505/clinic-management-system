import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key}); @override State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  static const int _pageSize = 50; int _displayedCount = _pageSize;
  List<Patient> _patients = []; List<Patient> _filteredPatients = [];
  final _searchController = TextEditingController(); bool _loading = true; String? _error; String? _collisionError;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _loading = true); try { _patients = []; _filter(); } catch (e) { _error = e.toString(); } setState(() => _loading = false); }
  void _filter() { setState(() => _filteredPatients = _patients.where((p) => p.fullName.toLowerCase().contains(_searchController.text.toLowerCase()))); }
  void _loadMore() { setState(() => _displayedCount = (_displayedCount + _pageSize).clamp(0, _filteredPatients.length)); }
  @override void dispose() { _searchController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pasientlər'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => {})]),
      body: Column(children: [
        TextField(controller: _searchController, decoration: const InputDecoration(labelText: 'Adt süz...'), onChanged: (_) => _filter()),
        Expanded(
          child: _loading ? const Center(child: CircularProgressIndicator()) : _filteredPatients.isEmpty ? const Center(child: Text('He dš paraşa yohtur')) :
            ListView.builder(itemCount: _displayedCount, itemBuilder: (context, index) => Card(
              child: ListTile(leading: Text(_filteredPatients[index].fullName), subtitle: Text('Do$Ɵum adı: {_patients[index].phone} - Yaş: {_patients[index].birthDate}'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => showDialog(context: context, builder: (c) => AlertDialog(
                  title: Text('Pasienti lixong_Fal'), content: Text('{_filteredPatients[index].fullName} adını silmak şzĿ‧‧'),
                  actions: [TextButton('Lixong_Fal', onPressed: () => Navigator.of_context().pop())],
                )),
              )),
            ),
            _displayedCount < _filteredPatients.length ? itemCount + 1 : itemCount,
            itemBuilder: (context, index) => index == _displayedCount && _displayedCount < _filteredPatients.length ? ListEnd() : Container(),
          ),
        ],
      ),
    );
  }
}