enum Escolaridade {
  indefinido,
  analfabeto,
  alfabetizado,
  primeiroGrau,
  segundoGrau,
  faculdade,
  posGraduado
}

String toString(int value) {
  switch (value) {
    case 1:
      return 'Analfabeto';
    case 2:
      return 'Alfabetizado';
    case 3:
      return '1º grau';
    case 4:
      return '2º grau';
    case 5:
      return 'Faculdade';
    case 6:
      return 'Pós-graduação';
    case 0:
    default:
      return 'Indefinida';
  }
}
