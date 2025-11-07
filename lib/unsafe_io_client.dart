import 'dart:io';
import 'package:http/io_client.dart';

IOClient createInsecureIOClient() {
  final ioClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true; // Разрешаем любые сертификаты
  return IOClient(ioClient);
}