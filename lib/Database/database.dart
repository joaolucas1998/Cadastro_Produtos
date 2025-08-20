import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../ProdutoModel/produto_model.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = '$dbPath/produtos.db';

    return await databaseFactoryFfi.openDatabase(path, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL CHECK (TRIM(nome) != ''),
            valor REAL NOT NULL CHECK (valor > 0),
            codigo INTEGER UNIQUE NOT NULL CHECK (codigo != 0)
          )
        ''');

        await db.execute('''
          CREATE TABLE logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dataHora TEXT NOT NULL,
            tipoOperacao TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TRIGGER log_insert_produto
          AFTER INSERT ON produtos
          BEGIN
            INSERT INTO logs (dataHora, tipoOperacao)
            VALUES (datetime('now', 'localtime'), 'INSERT');
          END;
        ''');

        await db.execute('''
          CREATE TRIGGER log_update_produto
          AFTER UPDATE ON produtos
          BEGIN
            INSERT INTO logs (dataHora, tipoOperacao)
            VALUES (datetime('now', 'localtime'), 'UPDATE');
          END;
        ''');

        await db.execute('''
          CREATE TRIGGER log_delete_produto
          AFTER DELETE ON produtos
          BEGIN
            INSERT INTO logs (dataHora, tipoOperacao)
            VALUES (datetime('now', 'localtime'), 'DELETE');
          END;
        ''');

      },
    ));
  }

  // Inserir produto
  static Future<int> inserirProduto(ProdutoModel produto) async {
    final db = await database;
    return await db.insert('produtos', produto.toMap());
  }

  // Buscar todos os produtos
  static Future<List<ProdutoModel>> buscarProdutos() async {
    final db = await database;
    final maps = await db.query('produtos');

    return maps.map((map) => ProdutoModel.fromMap(map)).toList();
  }

  // Atualizar produto
  static Future<int> atualizarProduto(ProdutoModel produto) async {
    final db = await database;
    return await db.update(
      'produtos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  // Deletar produto
  static Future<int> deletarProduto(int id) async {
    final db = await database;
    return await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
