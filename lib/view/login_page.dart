import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/main.dart';
import '/app_data.dart';
import '/models/diacono.dart';
import '/utils/mensagens.dart';
import '/utils/util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /* VARIAVEIS */
  final _controleUsuario = TextEditingController();
  final _controleSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /* WIDGETS */
  Widget get logotipo {
    return Column(
      children: [
        const Hero(
          tag: 'logo',
          child: Image(
            image: AssetImage('assets/icons/ic_launcher.png'),
            height: 128,
            width: 128,
          ),
        ),
        Hero(
          tag: 'appname',
          child: Text(
            AppData.appName,
            style: const TextStyle(
              fontSize: 40,
              fontFamily: 'Pacifico',
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        const Text(
          'Igreja Presbiteriana de Foz do Iguaçu',
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        const SizedBox(height: 16),
        Text(
          AppData.version,
          style: const TextStyle(color: Colors.grey),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }

  /* METODOS */

  /// Validar Formulário
  bool _validarFormulario() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }

  /// Logar no sistema
  void _logar() async {
    if (!_validarFormulario()) return;
    // Abre circulo de progresso
    Mensagem.aguardar(context: context, mensagem: 'Entrando...');
    // Tenta acessar a conta
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: _controleUsuario.text, password: _controleSenha.text);
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
            AppData.usuario = documentSnapshot.data();
            AppData.usuario!.uid = credential.user!.uid;
            Modular.to.navigate('/');
          } else {
            AppData.usuario = Diacono(
              nome: '',
              email: credential.user!.email!,
              telefone: 0,
            );
            AppData.usuario!.uid = credential.user!.uid;
            Modular.to.navigate('/diacono');
          }
        });
        return;
      }
    } catch (e) {
      dev.log(e.toString(), name: 'LoginPage');
    }
    Navigator.pop(context); // Fecha progresso
    // Ao falhar abre dialogo
    Mensagem.simples(
        context: context,
        titulo: 'Erro',
        mensagem:
            'Verifique seu usuário e senha.\n\nApenas usuários previamente cadastrados podem acessar o sistema');
  }

  /// Esqueci minha senha
  Future<void> _esqueciSenha() async {
    //if (!_isEmail(_controleUsuario.text)) return;
    if (Util.validarEmail(_controleUsuario.text) != null) {
      _validarFormulario();
      return;
    }
    // Abre circulo de progresso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await auth.sendPasswordResetEmail(email: _controleUsuario.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Verifique a sua caixa de entrada para redefinir a sua senha!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Não foi possível localizar o email ${_controleUsuario.text} em nosso cadastro!'),
        ),
      );
    }
    Navigator.pop(context);
  }

  /* METODOS DO SISTEMA */
  @override
  void dispose() {
    _controleUsuario.dispose();
    _controleSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
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
                  runSpacing: 32,
                  spacing: 32,
                  children: [
                    // LOGOTIPO
                    logotipo,
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 200, maxWidth: 450),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // USUARIO
                            TextFormField(
                              controller: _controleUsuario,
                              validator: Util.validarEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.email_rounded),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            // SENHA
                            TextFormField(
                              controller: _controleSenha,
                              validator: Util.validarSenha,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(Icons.password_rounded),
                              ),
                              onFieldSubmitted: (_) => _logar(),
                            ),
                            const SizedBox(height: 24.0),
                            // BOTAO ENTRAR
                            ElevatedButton.icon(
                              icon: const Icon(Icons.login_rounded),
                              label: const Text('ENTRAR'),
                              onPressed: _logar,
                            ),
                            const SizedBox(height: 36.0),
                            // BOTAO ESQUECI SENHA
                            TextButton(
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: _esqueciSenha,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Texto Informativo
                    const SizedBox(
                      width: double.maxFinite,
                      child: Text(
                        'Apenas usuários cadastrados pelo administrador tem acesso ao sistema.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
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
}
