
import 'package:gerenciador_terefas/database/database_provider.dart';
import 'package:gerenciador_terefas/model/tarefa.dart';

class TarefaDao{
  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(Tarefa tarefa) async{
    final db = await dbProvider.database;
    final valores = tarefa.toMap();
    if(tarefa.id == null){
      tarefa.id = await db.insert(Tarefa.nome_tabela, valores);
      return true;
    }else {
      final registrosAtualizados = await db.update(
          Tarefa.nome_tabela, valores,
          where: '${Tarefa.campo_id} = ?',
          whereArgs: [tarefa.id]);

      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async{
    final db = await dbProvider.database;
    final removerRegistro = await db.delete(Tarefa.nome_tabela,
    where: '${Tarefa.campo_id} = ?', whereArgs: [id]);

    return removerRegistro > 0;
  }

  Future<List<Tarefa>> Lista({
    String filtro = '',
    String campoOrdenacao = Tarefa.campo_id,
    bool usarOrdemDecrescente = false,
}) async{
    final db = await dbProvider.database;

    String? where;
    if(filtro.isNotEmpty){
      where = "UPPER(${Tarefa.campo_descricao}) LIKE '${filtro.toUpperCase()}%'";
    }

    var orderBy= campoOrdenacao;
    if (usarOrdemDecrescente){
      orderBy += ' DESC';
    }

    final resultado = await db.query(Tarefa.nome_tabela,
    columns: [Tarefa.campo_id, Tarefa.campo_descricao, Tarefa.campo_prazo, Tarefa.campo_finalizado],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => Tarefa.fromMap(m)).toList();
  }
}