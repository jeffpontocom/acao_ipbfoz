import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/app_data.dart';
import '/models/diacono.dart';
import '/utils/estilos.dart';
import '/utils/mensagens.dart';
import '/utils/util.dart';

class DiaconoPage extends StatefulWidget {
  final String diaconoId;

  const DiaconoPage({Key? key, required this.diaconoId}) : super(key: key);

  @override
  _DiaconoPageState createState() => _DiaconoPageState();
}

class _DiaconoPageState extends State<DiaconoPage> {
  late Diacono mDiacono;
  late bool editMode;

  @override
  void initState() {
    mDiacono = AppData.diaconos[widget.diaconoId] ?? Diacono();
    editMode = widget.diaconoId == AppData.usuario?.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Diácono'),
        titleSpacing: 0,
      ),
      body: mDiacono.email == null
          ? const Center(
              child: Text('Informações não encontradas!'),
            )
          : InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Center(
                child: Scrollbar(
                  isAlwaysShown: true,
                  showTrackOnHover: true,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Util.margemV(context),
                        horizontal: Util.margemH(context),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runAlignment: WrapAlignment.center,
                          runSpacing: 16,
                          spacing: 16,
                          children: [
                            Hero(
                              tag: widget.diaconoId,
                              child: const Icon(
                                Icons.account_circle,
                                size: 128.0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              mDiacono.email ?? '[ERRO]',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            TextFormField(
                              enabled: editMode,
                              initialValue: mDiacono.nome,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                mDiacono.nome = value;
                              },
                              decoration: Estilos.mInputDecoration
                                  .copyWith(labelText: 'Nome completo'),
                            ),
                            TextFormField(
                              enabled: editMode,
                              initialValue: Inputs.mascaraFone.getMaskedString(
                                  mDiacono.telefone.toString()),
                              inputFormatters: [Inputs.textoFone],
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                mDiacono.telefone = int.parse(
                                    Inputs.mascaraFone.clearMask(value));
                              },
                              decoration: Estilos.mInputDecoration
                                  .copyWith(labelText: 'Whatsapp'),
                            ),
                            const SizedBox(height: 16),
                            editMode
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: OutlinedButton.icon(
                                          label: const Text('SAIR'),
                                          icon:
                                              const Icon(Icons.logout_rounded),
                                          style: OutlinedButton.styleFrom(
                                              primary: Colors.white,
                                              backgroundColor: Colors.red),
                                          onPressed: () {
                                            Mensagem.aguardar(
                                                context: context,
                                                mensagem: 'Saindo...');
                                            FirebaseAuth.instance
                                                .signOut()
                                                .then((value) =>
                                                    Modular.to.navigate('/'));
                                          },
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(width: 12.0),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: OutlinedButton.icon(
                                          label: const Text('ATUALIZAR'),
                                          icon: const Icon(Icons.save_rounded),
                                          onPressed: () {
                                            _gravar();
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _gravar() {
    // Abre circulo de progresso
    Mensagem.aguardar(context: context, mensagem: 'Salvando dados...');
    try {
      FirebaseFirestore.instance
          .collection('diaconos')
          .doc(widget.diaconoId)
          .set(mDiacono.toJson())
          .then((value) {
        Navigator.pop(context);
      }).catchError((error) {
        dev.log("Falha ao adicionar diacono: $error", name: 'DiaconoPage');
        Navigator.pop(context);
      });
    } catch (e) {
      dev.log(e.toString(), name: 'DiaconoPage');
      Navigator.pop(context);
    }
  }
}
