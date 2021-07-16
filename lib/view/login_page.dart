import '/models/diacono.dart';
import '/ui/decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 32.0,
        title: Text('AÇÃO SOCIAL | Login'),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('assets/icons/ic_launcher.png'),
                  height: 128,
                  width: 128,
                ),
                SizedBox(
                  height: 24.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'E-mail'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: mTextFieldDecoration.copyWith(labelText: 'Senha'),
                  onSubmitted: (value) {
                    _logar();
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.login_rounded),
                  label: Text('ENTRAR'),
                  style: mOutlinedButtonStyle.merge(OutlinedButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                  )),
                  onPressed: () {
                    _logar();
                  },
                ),
                SizedBox(
                  height: 36.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logar() async {
    // Abre circulo de progresso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    // Tenta acessar a conta
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        FirebaseFirestore.instance
            .collection('diaconos')
            .doc(credential.user!.uid)
            .withConverter<Diacono>(
                fromFirestore: (snapshot, _) =>
                    Diacono.fromJson(snapshot.data()!),
                toFirestore: (pacote, _) => pacote.toJson())
            .get()
            .then((DocumentSnapshot<Diacono> documentSnapshot) {
          Navigator.pop(context); // Fecha progresso
          if (documentSnapshot.exists) {
            Navigator.pop(context);
          } else {
            Diacono.instance.email = credential.user!.email!;
            Diacono.instance.uid = credential.user!.uid;
            Navigator.pushReplacementNamed(context, 'diacono');
          }
        });
        return;
      }
    } catch (e) {
      print(e);
    }
    Navigator.pop(context); // Fecha progresso
    // Ao falhar abre dialogo
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Não foi possível logar'),
            content: Text('Verifique seu usuário e senha.\n\n' +
                'Apenas diáconos previamente cadastrados podem acessar o sistema.\n\n' +
                'Qualquer dúvida fale com o administrador do sistema.'),
            actions: <Widget>[
              new OutlinedButton(
                child: new Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
