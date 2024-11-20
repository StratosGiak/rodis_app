import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rodis_service/constants.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/suggestions.dart';
import 'package:rodis_service/models/user.dart';
import 'package:rodis_service/screens/record_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rodis_service/utils.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final waiting = ValueNotifier(false);

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    waiting.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (waiting.value) return;
    if (_formKey.currentState!.validate()) {
      waiting.value = true;
      try {
        final response = await http
            .post(
              Uri.parse("$apiUrl/login"),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({
                "username": usernameController.text,
                "password": passwordController.text,
              }),
            )
            .timeout(const Duration(seconds: 6));

        if (!mounted) return;
        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Λάθος στοιχεία')));
          waiting.value = false;
          return;
        }
        final {'token': token, 'user': user} =
            jsonDecode(response.body) as Map<String, dynamic>;
        final suggestions = Suggestions.fromJSON(await getSuggestions());
        final records = Records(records: await getRecords(user['id']));
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                Provider(
                  create: (_) => User(
                    id: user['id'],
                    username: user['username'],
                    name: user["name"],
                  ),
                ),
                ChangeNotifierProvider(create: (context) => records),
                ChangeNotifierProvider(create: (context) => suggestions),
                ChangeNotifierProvider(create: (context) => suggestions),
              ],
              builder: (context, child) => const RecordListScreen(),
            ),
          ),
        );
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Η σύνδεση με τον σέρβερ απέτυχε')),
        );
      } finally {
        waiting.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              child: TextFormField(
                controller: usernameController,
                validator: (value) => value == null || value.isEmpty
                    ? "Εισάγετε όνομα χρήστη"
                    : null,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              height: 80,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Εισάγετε κωδικό" : null,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                onFieldSubmitted: (value) => onSubmit(),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 40,
                width: 80,
                child: TextButton(
                  onPressed: onSubmit,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.35),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: waiting,
                    builder: (context, value, child) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: value
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.0,
                              ),
                            )
                          : const Text("Log in"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
