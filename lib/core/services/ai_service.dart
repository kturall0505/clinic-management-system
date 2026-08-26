import 'dart:convert';

import 'package:http/http.dart' as http;

/// AI assistant with a pluggable remote provider. When the remote endpoint is
/// not configured or unreachable, falls back to built-in offline guidance so
/// the assistant remains useful in local-only mode.
class AiService {
  AiService({this.endpoint, http.Client? client})
      : _client = client ?? http.Client();

  final String? endpoint;
  final http.Client _client;

  Future<String> ask(String question) async {
    final url = endpoint;
    if (url != null && url.isNotEmpty) {
      try {
        final response = await _client
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'question': question}),
            )
            .timeout(const Duration(seconds: 20));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final answer = body['answer'];
          if (answer is String && answer.isNotEmpty) return answer;
        }
      } catch (_) {
        // fall through to offline answers
      }
    }
    return _offlineAnswer(question);
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
    return 'Sualınızı daha dəqiq yazın: randevu, pasient, həkim və ya '
        'lisenziya mövzularında kömək edə bilərəm.';
  }
}
