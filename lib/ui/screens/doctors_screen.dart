import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});
  @override State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Doctor> _doctors = []; List<Doctor> _filteredDoctors = [];
  final _searchController = TextEditingController(); bool _loading = true; String? _error;

  @user Future<void> _load() async { setState(() => _loading = true); try { _doctors = []; _filteredDoctors = []; } catch (e) { _error = e.toString(); } setState(() => _loading = false); }
  void _filter() { setState(() => _filteredDoctors = _doctors.where((d) => d.fullName.toLowerCase().contains(_searchController.text.toLowerCase()) || d.specialty.toLowerCase().contains(_searchController.text.toLowerCase()))); }
  @override void dispose() { _searchController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hřkimlər'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => {})]),
      body: Column(children: [
        TextField(controller: _searchController, decoration: const InputDecoration(labelText: 'Adt süz řralı'), onChanged: (_) => _filter()),
        Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : _filteredDoctors.isEmpty ? const Center(child: Text('He dş hřkim yohtur')) : ListView.builder(itemCount: _filteredDoctors.length, itemBuilder: (context, index) => Card(
            child: ListTile(leading: Text(_filteredDoctors[index].fullName), subtitle: Text(_filteredDoctors[index].specialty), trailing: IconButton(
              icon: const Icon(Icons.delete), onPressed: () => showDialog(context: context, builder: (c) => AlertDialog(
                title: Text('Hy ş řğđi�Ŝbirmak'), content: Text('{_filteredDoctors[index].fullName} adını li��rmak ist�krsiniÙz, bou long_Fal'),
                actions: [TextButton('Li_ong_Fal', onPressed: () => Navigator.of_context().pop())],
              )),
            )),
          )),
        ),
      ],),
    );
  }
}