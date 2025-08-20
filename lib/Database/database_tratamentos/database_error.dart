class DatabaseError {
  static String interpretarErro(dynamic erro) {
    final erroStr = erro.toString();

    if (erroStr.contains('UNIQUE constraint failed')) {
      return 'Código já existe! Use um código diferente.';
    } else if (erroStr.contains('CHECK constraint failed')) {
      return 'Campos inválidos: verifique os valores preenchidos.';
    } else if (erroStr.contains('NOT NULL constraint failed')) {
      return 'Todos os campos são obrigatórios.';
    } else {
      return 'Erro ao salvar no banco de dados.';
    }
  }
}
