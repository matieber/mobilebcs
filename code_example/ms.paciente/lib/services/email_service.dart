import 'dart:async';
import 'package:mercadosalud/app/app.logger.dart';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  final _logger = getLogger('EmailService');

  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendMail',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 5)));

  static late final templateEmail;
  static late final templateCancelAssignment;
  static late final templateCancelAssignmentPaciente;
  static late final templateDiploma;

  EmailService() {
    var source = '''
    <img src=https://mercado-salud-68892.firebaseapp.com/favicon.png>
	  {{# names }}
            <div>{{ lastname }}, {{ firstname }}</div>
	  {{/ names }}
	  {{^ names }}
	    <div>No names.</div>
	  {{/ names }}
	  {{! I am a comment. }}
	''';

    templateEmail = new Template(source);

    var cancelAssignment = '''
    Estimado paciente:<br> 
      
        Su turno para el día {{ date }} a las {{ hour }} ha sido cancelado por el profesional {{ doctor }}.
        Disculpe las molestias.
        <br> 
        <br> 

 <div>
        <img src=https://mercado-salud-68892.firebaseapp.com/favicon.png> Mercado Salud
        </div>
	''';

    templateCancelAssignment = new Template(cancelAssignment);

    var cancelAssignmentPaciente = '''
    Estimado profesional:<br> 
      
        Su turno para el día {{ date }} a las {{ hour }} ha sido cancelado por el paciente {{ paciente }}.
        Disculpe las molestias.
        <br> 
        <br> 

 <div>
        <img src=https://mercado-salud-68892.firebaseapp.com/favicon.png> Mercado Salud
        </div>
	''';

    templateCancelAssignmentPaciente = new Template(cancelAssignmentPaciente);

    var diploma = '''
    Estimado {{ doctor }}:<br> 
      
        Su {{ documento }} ha sido validado.
        <br> 
        Cordialmente,
        <br> 
        <br> 
        

 <div>
        <img src=https://mercado-salud-68892.firebaseapp.com/favicon.png> Mercado Salud
        </div>
	''';

    templateDiploma = new Template(diploma);
  }

  Future<dynamic> sendEmail(
      {required String to,
      required String subject,
      required String body,
      String from = 'Mercado Salud <mercado.salud.dev@gmail.com>'}) async {
    return await _sendEmailLocal(to: to, subject: subject, body: body);
  }

  Future<void> pruebaEmail() async {
    var output = EmailService.templateEmail.renderString({
      'names': [
        {'firstname': 'Greg', 'lastname': 'Lowe'},
        {'firstname': 'Bob', 'lastname': 'Johnson'}
      ]
    });
    final res = await sendEmail(
        to: 'alfredo.teyseyre@isistan.unicen.edu.ar',
        subject: 'Prueba template',
        body: output);
    _logger.d("res email: $res");
  }

  Future<dynamic> _sendEmailServer(
      {required String to,
      required String subject,
      required String body,
      String from = 'Mercado Salud <mercado.salud.dev@gmail.com>'}) async {
    try {
      final params = <String, dynamic>{
        'to': to,
        'subject': subject,
        'html': body,
        'from': from
      };
      final HttpsCallableResult result = await callable.call(params);

      print(result.data['response']);
      return result.data['response'];
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }

  Future<dynamic> _sendEmailLocal(
      {required String to,
      required String subject,
      required String body,
      String from = 'mercado.salud.dev@gmail.com'}) async {
    // Habilitar https://myaccount.google.com/lesssecureapps
    String password = '2021BasavilbasO!FolioT!2021';

    final smtpServer = gmail(from, password);

    // Create our message.
    final message = mailer.Message()
      ..from = mailer.Address(from, 'Mercado Salud')
      ..recipients.add(to)
      ..subject = subject
      ..html = body;

    try {
      final sendReport = await mailer.send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on mailer.MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<dynamic> cancelAssignment({
    required String to,
    required String subject,
    required String date,
    required String hour,
    required String doctor,
  }) async {
    var output = EmailService.templateCancelAssignment
        .renderString({'date': date, 'hour': hour, 'doctor': doctor});
    final res = await sendEmail(to: to, subject: subject, body: output);
    _logger.d("res email: $res");
    return res;
  }

  Future<dynamic> cancelAssignmentPaciente({
    required String to,
    required String subject,
    required String date,
    required String hour,
    required String paciente,
  }) async {
    var output = EmailService.templateCancelAssignmentPaciente
        .renderString({'date': date, 'hour': hour, 'paciente': paciente});
    final res = await sendEmail(to: to, subject: subject, body: output);
    _logger.d("res email: $res");
    return res;
  }

  Future<dynamic> DoctorValidado({
    required String documento,
    required String to,
    required String doctor,
    required String subject,
  }) async {
    var output = EmailService.templateDiploma
        .renderString({'doctor': doctor, 'documento': documento});
    final res = await sendEmail(to: to, subject: subject, body: output);
    _logger.d("res email: $res");
    return res;
  }
}
