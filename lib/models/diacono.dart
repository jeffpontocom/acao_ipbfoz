class Diacono {
  late String uid;

  late String nome; // OBRIGATORIO
  late String email; // OBRIGATORIO
  late int telefone; // OBRIGATORIO

  Diacono({
    required this.nome,
    required this.email,
    required this.telefone,
  });

  Diacono.fromJson(Map<String, Object?> json)
      : this(
          nome: (json['nome'] ?? '') as String,
          email: (json['email'] ?? '') as String,
          telefone: (json['telefone'] ?? '0') as int,
        );

  Map<String, Object?> toJson() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
    };
  }

  // Instanciador Singleton
  //Diacono._constructor();
  //static late Diacono _instance = Diacono._constructor();
  //static Diacono get instance => _instance;
}
