import 'package:cadastro_produto/Database/database_tratamentos/database_error.dart';
import 'package:flutter/material.dart';
import '../ProdutoModel/produto_model.dart';
import '../Database/database.dart';

class ListaProduto extends StatefulWidget {
  const ListaProduto({super.key});

  @override
  State<ListaProduto> createState() => _ListaProdutoState();
}

class _ListaProdutoState extends State<ListaProduto> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _codigoController = TextEditingController();

  List<ProdutoModel> produtos = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    final lista = await DatabaseService.buscarProdutos();
    setState(() {
      produtos = lista;
    });
  }

  Future<void> _adicionarProduto() async {
    if (_formKey.currentState!.validate()) {
      final novo = ProdutoModel(
        nome: _nomeController.text,
        valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        codigo: int.tryParse(_codigoController.text) ?? 0,
      );

      try {
        await DatabaseService.inserirProduto(novo);
        _nomeController.clear();
        _valorController.clear();
        _codigoController.clear();
        _carregarProdutos();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto adicionado com sucesso!')),
        );
      } catch (e) {
        final msg = DatabaseError.interpretarErro(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }

  Future<void> _deletarProduto(int id) async {
    await DatabaseService.deletarProduto(id);
    _carregarProdutos();
  }

  Future<void> _editarProdutoDialog(ProdutoModel produto) async {
    final nomeController = TextEditingController(text: produto.nome);
    final valorController = TextEditingController(text: produto.valor.toString());
    final codigoController = TextEditingController(text: produto.codigo.toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: valorController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(labelText: 'Código'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novo = ProdutoModel(
                id: produto.id,
                nome: nomeController.text,
                valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
                codigo: int.tryParse(codigoController.text) ?? 0,
              );

              try {
                await DatabaseService.atualizarProduto(novo);
                Navigator.of(context).pop();
                _carregarProdutos();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produto atualizado com sucesso!')),
                );
              } catch (e) {
                final msg = DatabaseError.interpretarErro(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      appBar: AppBar(
        title: const Text('Cadastro de Produtos'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Formulário
            Card(
              color: const Color(0xFFFFF5E1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Novo Produto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(labelText: 'Nome do produto'),
                               validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _valorController,
                              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                              keyboardType: TextInputType.number,
                               validator: (v) => v == null || v.isEmpty ? 'Informe o valor' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _codigoController,
                              decoration: const InputDecoration(labelText: 'Código'),
                              keyboardType: TextInputType.number,
                               validator: (v) => v == null || v.isEmpty ? 'Informe o código' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                            onPressed: _adicionarProduto,
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de produtos
            Expanded(
              child: Card(
                color: const Color(0xFFFFF5E1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Produtos (${produtos.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      produtos.isEmpty
                          ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Nenhum produto cadastrado', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                          : Expanded(
                        child: ListView.builder(
                          itemCount: produtos.length,
                          itemBuilder: (_, index) {
                            final p = produtos[index];
                            return Card(
                              color: const Color(0xFFF8F3FF),
                              child: ListTile(
                                title: Text('${p.nome}'),
                                subtitle: Text('R\$ ${p.valor.toStringAsFixed(2)} - Código: ${p.codigo}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editarProdutoDialog(p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        if (p.id != null) {
                                          _deletarProduto(p.id!);
                                        }
                                      },

                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
