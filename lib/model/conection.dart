import 'package:mysql1/mysql1.dart';

class Conection {
  final String host;
  final int port;
  final String user;
  final String password;
  final String? db;

  Conection({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    this.db,
  });

  ConnectionSettings getConnectionSettings() {
    return ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'host': host,
      'port': port,
      'user': user,
      'password': password,
      'db': db,
    };
  }

  factory Conection.fromMap(Map<String, dynamic> map) {
    return Conection(
      host: map['host'],
      port: map['port'],
      user: map['user'],
      password: map['password'],
      db: map['db'],
    );
  }
}
