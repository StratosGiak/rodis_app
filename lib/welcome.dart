import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indevche/record_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png'),
            const SizedBox(
              height: 60.0,
            ),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse("http://192.168.1.22/api/login"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text,
        }),
      );
      if (!mounted) return;
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Λάθος στοιχεία')));
        return;
      }
      final {'token': token, 'user': user} =
          jsonDecode(response.body) as Map<String, dynamic>;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Provider(
            create: (_) => User(
              id: user['id'],
              username: user['username'],
              name: user["name"],
              token: token,
            ),
            builder: (context, child) => const RecordListScreen(),
          ),
        ),
      );
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
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 72,
              child: TextFormField(
                controller: usernameController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Εισάγετε username" : null,
                decoration: const InputDecoration(
                  hintText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              height: 72,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Εισάγετε password" : null,
                decoration: const InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
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
                  child: const Text("Log in"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  User({
    required this.id,
    required this.username,
    required this.name,
    required this.token,
  });

  final int id;
  final String username;
  final String name;
  final String token;
}
