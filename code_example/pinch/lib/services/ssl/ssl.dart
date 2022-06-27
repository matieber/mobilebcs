import 'package:encrypt/encrypt.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:basic_utils/basic_utils.dart';
import 'dart:io';
import 'package:apinch/locator_service.dart' as di;
import 'package:logger/logger.dart';

class APinchSSLService {
  List<int> data = [
    01,
    02,
    03,
    04,
    05,
    06,
    07,
    08,
    09,
    0,
    01,
    02,
    03,
    05,
    85,
    85
  ];
  Encrypter _encrypter;
  String _bad;
  IV _iv;
  Codec<String, String> _stringToBase64;

  APinchSSLService() {
    Uint8List keylist = Uint8List.fromList(data);
    final key = Key(keylist);
    _iv = IV(keylist);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _bad = utf8.decode([10]);
    _stringToBase64 = utf8.fuse(base64);
  }

  String decrypt(String msg) {
    //decode--------------------------------

//  echo "clientip=1.1.1.1, clientmac=24:41:8c:03:51:d9, gatewayname=F8:D1:11:A5:F9:A8, tok=d0abedcb, gatewayaddress=192.168.101.21:2050, authdir=opennds_auth, originurl=http%3a%2f%2fnmcheck.gno"
//| openssl enc  -aes-128-cbc -base64 -K 01020304050607080900010203055555 -iv 01020304050607080900010203055555
//| base64 -w 0
//VXFwbDV3Vk85YlNyc0k4U0E1RTRmd2t3OE9GNnlBVDhDcWEvVkp2bFREKzdTN294YnZ4aXN3RjNwOEJHSGNDcApqSGl6ZHZCMVRRRVFCaEMvMmk2NmNpZ3hDd095Q0NCVk1td21raG5vY05MeFdxNFN3NnV0TlNlTHM2ZWI5SXV0CmNUdjEzS0RydEpQSW5GL0NpZXpPKzBRZnlnRTZxZTVpcVVVTndMUHN5MDBiU0ZacFpVejRkbElKdFVBWitCNWUKb2U1UUNrSXFFaXpRUjRBa1RhNlprcXJTK2ZCRUlCR1MrZEU1ZmVTWjAzeTJhdFJHdjBJOURqUGw2ODZVUWVQQQo=%

//echo VXFwbDV3Vk85YlNyc0k4U0E1RTRmd2t3OE9GNnlBVDhDcWEvVkp2bFREKzdTN294YnZ4aXN3RjNwOEJHSGNDcApqSGl6ZHZCMVRRRVFCaEMvMmk2NmNpZ3hDd095Q0NCVk1td21raG5vY05MeFdxNFN3NnV0TlNlTHM2ZWI5SXV0CmNUdjEzS0RydEpQSW5GL0NpZXpPKzBRZnlnRTZxZTVpcVVVTndMUHN5MDBiU0ZacFpVejRkbElKdFVBWitCNWUKb2U1UUNrSXFFaXpRUjRBa1RhNlprcXJTK2ZCRUlCR1MrZEU1ZmVTWjAzeTJhdFJHdjBJOURqUGw2ODZVUWVQQQo=
//| base64 -d
// | openssl enc -d -aes-128-cbc -base64 -K 01020304050607080900010203055555 -iv 01020304050607080900010203055555

//String encoded = stringToBase64.encode(cText2);
//String decoded = stringToBase64.decode(cText2);

    final logger = di.sl<Logger>();
    logger.d("Encrypted: $msg");
    // base64 -d

    String decoded3 = _stringToBase64.decode(msg);
    decoded3 = decoded3.replaceAll(_bad, "");
    //print("dec: $decoded3");

    // openssl enc -d -aes-128-cbc -base64 -K 01020304050607080900010203055555 -iv 01020304050607080900010203055555
    final decrypted3 =
        _encrypter.decrypt(Encrypted.fromBase64(decoded3), iv: _iv);
    //print(decrypted3);
    logger.d("Decrypted: $decrypted3");
    return decrypted3;
  }

  //encode--------------------------------

  String encrypt(String msg) {
    //final msg =
    //  "clientip=1.1.1.1, clientmac=24:41:8c:03:51:d9, gatewayname=F8:D1:11:A5:F9:A8, tok=d0abedcb, gatewayaddress=192.168.101.21:2050, authdir=opennds_auth, originurl=http%3a%2f%2fnmcheck.gno";
//openssl enc  -aes-128-cbc -base64 -K 01020304050607080900010203055555 -iv 01020304050607080900010203055555
    final encrypted3 = _encrypter.encrypt(msg, iv: _iv);
    //print("enc: $encrypted3");
    final logger = di.sl<Logger>();
    logger.d("Decrypted: $msg");

    String encrypted3base64 = encrypted3.base64;
    //print("enc base64: $encrypted3base64");
    final encrypted3base64nl =
        StringUtils.addCharAtPosition(encrypted3base64, "\n", 64, repeat: true);
    //print("enc base64 nl: $encrypted3base64nl");

    //base64 -w 0
    String encoded = _stringToBase64.encode(encrypted3base64nl);
    //print("enc final: $encoded");
    logger.d("Encrypted: $encoded");
    return encoded;
  }
}
