enum Beneficios {
  nenhum,
  bolsa_familia,
  aposentadoria,
  pensao,
  auxilio_emergencial,
}

String getBeneficiosString(Beneficios value) {
  switch (value.index) {
    case 0:
      return 'Nenhum';
    case 1:
      return 'Bolsa Família';
    case 2:
      return 'Aposentadoria';
    case 3:
      return 'Pensão';
    case 4:
      return 'Auxílio Emergencial';
    default:
      return 'Erro: Não listado';
  }
}
