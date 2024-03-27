
import 'package:flutter/material.dart';
import 'package:gerenciador_terefas/model/tarefa.dart';
import 'package:gerenciador_terefas/pages/filtro_page.dart';
import 'package:gerenciador_terefas/widgets/conteudo_form_dialog.dart';

class ListaTarefaPage extends StatefulWidget{

  @override
  _ListaTarefaPageState createState() => _ListaTarefaPageState();
}

class _ListaTarefaPageState extends State<ListaTarefaPage>{

  final _tarefas = <Tarefa> [];
  var _ultimoId = 0;

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(context),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        child: Icon(Icons.add),
        tooltip: 'Nova Tarefa',
      ),
    );
  }

  AppBar _criarAppBar(BuildContext context){
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      title: Text('Tarefas'),
      centerTitle: false,
      actions: [
        IconButton(
            onPressed: _abrirFiltro,
            icon: const Icon(Icons.filter_list),
        )
      ],
    );
  }

  Widget _criarBody(){
    if(_tarefas.isEmpty){
      return  const Center(
        child: Text('Tudo certo por aqui!!!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index){
          final tarefa = _tarefas[index];
          return PopupMenuButton<String>(
            child: ListTile(
              title: Text('${tarefa.id} - ${tarefa.descricao}'),
              subtitle: Text(tarefa.prazoFormatado == '' ? 'Sem prazo definido' :
              'Prazo - ${tarefa.prazoFormatado}'),
            ),
              itemBuilder: (BuildContext context) => criarItensMenuPopUp(),
            onSelected: (String valorSelecionado){
              if (valorSelecionado == ACAO_EDITAR){
                _abrirForm(tarefaAtual: tarefa, indice: index);
              }else{
                _excluir(index);
              }
            },
          );
    },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: _tarefas.length,
    );
  }

  void _abrirFiltro(){
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.ROUTE_NAME).then((alterouValor) {
      if(alterouValor == true){

      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopUp(){
    return [
       const PopupMenuItem(
        value: ACAO_EDITAR,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                child: Text('Editar'),
              )
            ],
          )
      ),
      const PopupMenuItem(
          value: ACAO_EXCLUIR,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Excluir'),
              )
            ],
          )
      )
    ];
  }

  Future _excluir(int indice){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return  AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red,),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Atenção', style: TextStyle(color: Colors.red),),
                )
              ],
            ),
            content: const Text('Esse registro será deletado definitivamente!'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar')
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _tarefas.removeAt(indice);
                    });
                  },
                  child: Text('Ok')
              ),
            ],
          );
        }
    );

  }

  void _abrirForm({Tarefa? tarefaAtual, int? indice}){
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(tarefaAtual == null ? 'Nova tarefa' :
            'Alterar Tarefa ${tarefaAtual.id}'),
            content: ConteudoFormDialog(key: key, tarefaAtual: tarefaAtual),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
              ),
              TextButton(
                  onPressed: () {
                    if (key.currentState!.dadosValidados() &&
                    key.currentState != null){
                      setState(() {
                        final novaTarefa = key.currentState!.novaTarefa;
                        if( indice == null){
                          novaTarefa.id = ++ _ultimoId;
                          _tarefas.add(novaTarefa);
                        }else{
                          _tarefas[indice] = novaTarefa;
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Salvar'),
              )
            ],
          );
        }
    );
  }
}