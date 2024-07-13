import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

String server = '192.168.1.14';
//String server = '191.101.78.';
String port = '5000';
String resposta = '{' 'Calculado' ':' 'none' '}';

Future<String> sendText(String funcao, String texto, String user) async {
  try {
    final response = await http.post(
      Uri.parse('http://$server:$port/$funcao'),
      body: {'texto': texto, 'user': user},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      resposta = response.body;
      return resposta;
    } else {
      return 'Error: ${response.reasonPhrase}';
    }
  } on TimeoutException catch (_) {
    return '{"Erro": "O servidor demorou a responder."}';
  }
}

Future<String> sendTextAndImages(
    String funcao, String texto, List imageList) async {
  try {
    final url = Uri.parse('http://$server:$port/$funcao');
    final request = http.MultipartRequest('POST', url);
    request.fields['func'] = funcao;
    request.fields['text'] = texto;
    request.fields['user'] = FirebaseAuth.instance.currentUser!.uid;
    for (final image in imageList) {
      final bytes = await image.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes('images', bytes,
          filename: image.path.split('/').last);
      request.files.add(multipartFile);
    }
    final response = await request.send().timeout(const Duration(seconds: 2));
    if (response.statusCode == 200) {
      return ('Sucesso!');
    } else {
      return ('Falha ao enviar imagens.');
    }
  } on TimeoutException catch (_) {
    return ('{' 'Erro' ':' 'O servidor demorou a responder..' '}');
  }
}
