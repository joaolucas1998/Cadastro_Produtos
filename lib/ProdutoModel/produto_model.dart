import 'package:flutter/cupertino.dart';

class ProdutoModel {
  final int? id;
  final String nome;
  final double valor;
  final int codigo;

  const ProdutoModel({
    this.id,
    required this.nome,
    required this.valor,
    required this.codigo,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nome': nome,
    'valor': valor,
    'codigo': codigo,
  };

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      valor: (map['valor'] as num).toDouble(),
      codigo: map['codigo'] as int,
    );
  }
}

