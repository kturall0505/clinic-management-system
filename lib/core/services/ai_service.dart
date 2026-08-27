import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../exceptions/app_exception.dart';

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
    return 'Sualınızı daha dəqiq yazın: randevu, pasient, həkim, lisenziya, '
        'ödəniş və ya resept mövzularında kömək edə bilərəm.';
  }
}
