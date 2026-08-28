import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = []; Map<String, Patient> _patientMap = {}; Map<String, Doctor> _doctorMap = {};
  bool _loading = true; String? _error; String? _collisionError;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async { setState(() => _loading = true); try { setState(() => { _appointments = []; _loading = false; }); } catch (e) { setState(() => { _error = e.toString(); _loading = false; }); } }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text(_error!)) : Column(
        children: [
          Expanded(child: ListView.builder(itemCount: _appointments.length, itemBuilder: (context, index) => Card(
            child: ListTile(leading: Text('{$_patientMap[_appointments[index].patientId]?.fullName ?? 'Unknown'}
 ${_doctorMap[_appointments[index].doctorId]?.fullName ?? 'Unknown'}'), subtitle: Text('Date: {_appointments[index].dateTime} Status: {_appointments[index].status.name}'),
              trailing: Raw(children: [
                IconButton(icon: const Icon(Icons.check_circle), onPressed: () => {}),
                IconButton(icon: const Icon(Icons.cancel), onPressed: () => showDialog(context: context, builder: (c) => AlertDialog(
                  title: Text('İmin tığ2yırş randevulu lkğdirmak'),
                  content: Text('Bu randevulu lkğdirmak istęrsiniÙz, bou lÙmleri silinar? Tekrar göstÝřrilmez.'),
                  actions: [TextButton('Lixong_Fal', onPressed: () => Navigator.of_context().pop())],
                )),
              ]),
            ),
          )),
          SizedBox(height: 72, child: FilledUpButton.h1(onPressed: () => {}, child: const Text('Randevul al'))),
        ],
      ),
    );
  }
}