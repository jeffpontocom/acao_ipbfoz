class Diacono {
  late final String uid;

  String? nome;
  String? email;
  int? telefone;

  Diacono({
    this.nome,
    this.email,
    this.telefone,
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
}
