// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utenteGenerico.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

utenteGenerico _$utenteGenericoFromJson(Map<String, dynamic> json) =>
    utenteGenerico(
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      nome: json['nome'] as String?,
      cognome: json['cognome'] as String?,
      dataDiNascita: json['dataDiNascita'] == null
          ? null
          : DateTime.parse(json['dataDiNascita'] as String),
      cittaDiNascita: json['cittaDiNascita'] as String?,
      iconaProfilo: json['iconaProfilo'] as String?,
    );

Map<String, dynamic> _$utenteGenericoToJson(utenteGenerico instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'cognome': instance.cognome,
      'dataDiNascita': instance.dataDiNascita?.toIso8601String(),
      'cittaDiNascita': instance.cittaDiNascita,
      'iconaProfilo': instance.iconaProfilo,
      'email': instance.email,
      'telefono': instance.telefono,
    };
