/* import 'package:acao_ipbfoz/main.dart';
import 'package:acao_ipbfoz/models/diacono.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, Diacono> diaconos = new Map();

void loadDiaconos() async {
  await FirebaseFirestore.instance
      .collection('diaconos')
      .withConverter<Diacono>(
          fromFirestore: (snapshot, _) => Diacono.fromJson(snapshot.data()!),
          toFirestore: (diacono, _) => diacono.toJson())
      .get()
      .then(
    (QuerySnapshot<Diacono> querySnapshots) {
      if (querySnapshots.size > 0) {
        querySnapshots.docs.forEach((element) {
          diaconos.addAll({element.id: element.data()});
          if (auth.currentUser != null && auth.currentUser!.uid == element.id) {
            usuario = element.data();
            usuario!.uid = element.id;
            print('Dados do usuário logado carregado com sucesso!');
          }
        });
        print('Lista de diaconos carregada com sucesso!');
      }
    },
  );
} */
