import '/models/entrega.dart';
import '/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FamiliaEntregas extends StatefulWidget {
  FamiliaEntregas(this.familia);
  final DocumentReference<Familia> familia;

  @override
  _FamiliaEntregasState createState() => _FamiliaEntregasState();
}

class _FamiliaEntregasState extends State<FamiliaEntregas> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot<Entrega>>(
              stream: widget.familia
                  .collection('entregas')
                  .orderBy('data', descending: false)
                  .withConverter<Entrega>(
                    fromFirestore: (snapshots, _) =>
                        Entrega.fromJson(snapshots.data()!),
                    toFirestore: (documento, _) => documento.toJson(),
                  )
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.hasError) {
                  return Center(
                    child: Text(snapshots.error.toString()),
                  );
                }
                if (!snapshots.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshots.data!.size == 0) {
                  return Center(
                    child: Text('Nenhuma entrega realizada ainda.'),
                  );
                }
                final data = snapshots.data;
                return Center(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: data!.size,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(data.docs[index].id),
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
