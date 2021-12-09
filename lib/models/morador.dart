import 'package:cloud_firestore/cloud_firestore.dart';

class Morador {
  late String nome;
  late Timestamp nascimento;
  late int escolaridade;
  late String profissao;
  late bool especial;

  Morador({
    required this.nome,
    required this.nascimento,
    required this.escolaridade,
    required this.profissao,
    required this.especial,
  });

  Morador.fromJson(Map<String, Object?> json)
      : this(
          nome: (json['nome'] ?? '') as String,
          nascimento: (json['nascimento'] ??
              Timestamp.fromDate(DateTime.parse('2000-01-01'))) as Timestamp,
          escolaridade: (json['escolaridade'] ?? 0) as int,
          profissao: (json['profissao'] ?? '') as String,
          especial: (json['especial'] ?? false) as bool,
        );

  Map<String, Object?> toJson() {
    return {
      'nome': nome,
      'nascimento': nascimento,
      'escolaridade': escolaridade,
      'profissao': profissao,
      'especial': especial
    };
  }
}

int getIdade(Timestamp nascimento) {
  DateTime dataAtual = DateTime.now();
  DateTime dataNasc = nascimento.toDate();

  //Subtai para saber quantos anos se passaram após nascimento
  int idade = dataAtual.year - dataNasc.year;

  //data de nascimento não pode ser maior que data atual
  if (dataAtual.isBefore(dataNasc) || dataNasc.year == 1800) {
    return -1;
  }
  //Verifica se está fazendo aniversário hoje
  else if (dataAtual.month == dataNasc.month && dataAtual.day == dataNasc.day) {
    return idade;
  }
  //Verifica se vai fazer aniversário este ano
  else if (dataAtual.month < dataNasc.month ||
      (dataAtual.month == dataNasc.month && dataAtual.day < dataNasc.day)) {
    idade = idade - 1;
    return idade;
  }
  //Se nenhuma das opções anteriores, então já fez aniversário este ano
  else {
    return idade;
  }
}
