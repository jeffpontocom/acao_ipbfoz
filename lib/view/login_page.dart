import '/main.dart';
import '../models/diacono.dart';
import '../ui/styles.dart';
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

  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AÇÃO SOCIAL | Login'),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
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
                    // USUARIO
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: mTextFieldDecoration.copyWith(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_rounded)),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) => !_isEmail(value!)
                          ? "Informe um endereço de e-mail valido"
                          : null,
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    // SENHA
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: mTextFieldDecoration.copyWith(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.password_rounded)),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) => value!.length < 6
                          ? "Senha deve conter no mínimo 6 caracteres"
                          : null,
                      onChanged: (value) {
                        password = value;
                      },
                      onFieldSubmitted: (value) {
                        _logar();
                      },
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    OutlinedButton.icon(
                      icon: Icon(Icons.login_rounded),
                      label: Text('ENTRAR'),
                      style:
                          mOutlinedButtonStyle.merge(OutlinedButton.styleFrom(
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
                    TextButton(
                      child: Text(
                        'Esqueci minha senha',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        _reenviarSenha();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isEmail(String value) {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(regex);
    return value.isNotEmpty && regExp.hasMatch(value);
  }

  bool _validar() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }

  void _logar() async {
    if (!_validar()) return;
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
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            usuarioLogado = new Diacono(
              nome: '',
              email: credential.user!.email!,
              telefone: 0,
            );
            usuarioLogado.uid = credential.user!.uid;
            Navigator.pushReplacementNamed(context, '/diacono');
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
                'Apenas usuários previamente cadastrados podem acessar o sistema.\n\n' +
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

  Future<void> _reenviarSenha() async {
    if (!_isEmail(email)) return;
    try {
      await auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Verifique a sua caixa de entrada para redefinir a sua senha!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Não foi possível localizar o email $email em nosso cadastro!'),
        ),
      );
    }
  }
}
