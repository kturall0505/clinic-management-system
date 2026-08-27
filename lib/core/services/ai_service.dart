import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../exceptions/app_exception.dart';
import '../models/models.dart';

class AiService {
  AiService({this.endpoint, http.Client? client})
      : _client = client ?? http.Client();

  final String? endpoint;
  final http.Client _client;

  Future<String> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Sual boş ola bilməz');
    }

    final url = endpoint;
    if (url != null && url.isNotEmpty) {
      try {
        final response = await _client
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'question': trimmed}),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final answer = body['answer'];
          if (answer is String && answer.isNotEmpty) {
            return answer;
          }
        }

        if (response.statusCode >= 500) {
          throw NetworkException('AI server xətası (${response.statusCode})');
        }
      } on TimeoutException catch (_) {
        debugPrint('AI request timed out, falling back to offline');
      } on SocketException catch (_) {
        debugPrint('AI network error, falling back to offline');
      } on FormatException catch (e) {
        debugPrint('AI response parse error: $e');
      } on Exception catch (e) {
        debugPrint('AI request failed: $e');
      }
    }

    return _offlineAnswer(trimmed);
  }

  Future<List<String>> suggestIcd10Codes(String symptoms) async {
    final trimmed = symptoms.trim();
    if (trimmed.isEmpty) return [];

    final url = endpoint;
    if (url != null && url.isNotEmpty) {
      try {
        final response = await _client
            .post(
              Uri.parse('$url/icd10'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'symptoms': trimmed}),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final codes = body['codes'];
          if (codes is List) {
            return codes.map((e) => e.toString()).toList();
          }
        }
      } on Exception catch (_) {}
    }

    return _offlineIcd10Suggestions(trimmed);
  }

  Future<List<String>> checkDrugInteractions(List<String> medications) async {
    if (medications.isEmpty || medications.length < 2) return [];

    final url = endpoint;
    if (url != null && url.isNotEmpty) {
      try {
        final response = await _client
            .post(
              Uri.parse('$url/drug-interactions'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'medications': medications}),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final interactions = body['interactions'];
          if (interactions is List) {
            return interactions.map((e) => e.toString()).toList();
          }
        }
      } on Exception catch (_) {}
    }

    return _offlineDrugInteractions(medications);
  }

  List<String> _offlineIcd10Suggestions(String symptoms) {
    final s = symptoms.toLowerCase();
    if (s.contains('baş') && s.contains('ağrı')) return ['R51.9', 'G43.9', 'G44.1'];
    if (s.contains('qızcıq') || s.contains('təzyiq')) return ['I10.9', 'I11.9'];
    if (s.contains('şəkər') || s.contains('diyabet')) return ['E11.9', 'E10.9'];
    if (s.contains('boğaz') || s.contains('öskürək')) return ['J00', 'J06.9', 'J20.9'];
    if (s.contains('qarın') || s.contains('ağrı')) return ['R10.9', 'K29.5'];
    if (s.contains('üşü') || s.contains('təzə')) return ['R50.9', 'J00'];
    if (s.contains('nəfəs') || s.contains('nəfəs')) return ['J45.9', 'J44.9'];
    if (s.contains('döş') || s.contains('ağrı')) return ['R07.9', 'I20.9'];
    return [];
  }

  List<String> _offlineDrugInteractions(List<String> medications) {
    final meds = medications.map((m) => m.toLowerCase()).toList();
    final warnings = <String>[];

    final pairs = <Set<String>>{
      {'aspirin', 'warfarin'},
      {'ibuprofen', 'lisinopril'},
      {'amoxicillin', 'methotrexate'},
      {'simvastatin', 'clarithromycin'},
      {'metformin', 'cimetidine'},
      {'omeprazole', 'clopidogrel'},
      {'fluoxetine', 'tramadol'},
      {'sertraline', 'nsaids'},
    };

    for (final pair in pairs) {
      if (meds.any((m) => pair.contains(m)) && meds.any((m) => pair.contains(m))) {
        final remaining = pair.toList()..removeWhere(meds.contains);
        warnings.add('⚠️ ${pair.toList().join(" + ")}: müalicəvi monitorinq tələb edə bilər');
      }
    }

    return warnings;
  }

  String _offlineAnswer(String question) {
    final q = question.toLowerCase();
    if (q.contains('randevu')) {
      return 'Randevu yaratmaq üçün "Randevular" bölməsinə keçin və '
          '"+" düyməsi ilə pasient, həkim və vaxtı seçin.';
    }
    if (q.contains('pasient') || q.contains('xəstə')) {
      return 'Pasient əlavə etmək üçün "Pasientlər" bölməsində "+" düyməsini '
          'basın. Allergiya və xroniki xəstəlikləri qeyd etməyi unutmayın.';
    }
    if (q.contains('həkim')) {
      return 'Həkim profili "Həkimlər" bölməsindən idarə olunur: ixtisas, '
          'qrafik və konsultasiya haqqı orada təyin edilir.';
    }
    if (q.contains('lisenziya') || q.contains('internet')) {
      return 'Sistem lokal işləyir, lakin gündə bir dəfə lisenziya serveri ilə '
          'əlaqə tələb olunur. Klinika məlumatları heç vaxt kənara ötürülmür.';
    }
    if (q.contains('ödəniş') || q.contains('pul')) {
      return 'Ödənişlər "Maliyyə" bölməsində izlənir. Nağd, POS və sığorta '
          'ödənişləri qeyd edilə bilər.';
    }
    if (q.contains('resept') || q.contains('dərman')) {
      return 'Elektron resept həkim panelindən yaradılır. Dərmanlar bazası '
          'inteqrasiyası ilə yan təsir yoxlaması aparılır.';
    }
    if (q.contains('icd') || q.contains('kodu')) {
      return 'ICD-10 kod təklifləri üçün simptomları AI asistente yazın. '
          'Məsələn: "baş ağrısı" və ya "qızcıq".';
    }
    if (q.contains('yan təsir') || q.contains('interaksiya')) {
      return 'Dərman interaksiya yoxlaması üçün resept yaradarkən '
          'sistem avtomatik olaraq yan təsirləri yoxlayacaq.';
    }
    return 'Sualınızı daha dəqiq yazın: randevu, pasient, həkim, lisenziya, '
        'ödəniş, resept, ICD-10 və ya dərman interaksiyası mövzularında kömək edə bilərəm.';
  }
}
