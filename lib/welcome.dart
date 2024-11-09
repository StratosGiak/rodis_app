import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indevche/constants.dart';
import 'package:indevche/record.dart';
import 'package:indevche/record_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _node = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_node),
      child: Scaffold(
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
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
          ),
        ]),
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
  final waiting = ValueNotifier(false);

  Future<Records> getRecords(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/records/by/$id'));
    final json =
        (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    return Records(
      records: json.map((element) => Record.fromJSON(element)).toList(),
    );
  }

  Future<Suggestions> getSuggestions() async {
    final response = await http.get(Uri.parse('$apiUrl/suggestions'));
    final json = (jsonDecode(response.body) as Map<String, dynamic>)
        .cast<String, List<dynamic>>();
    final suggestions = json.map(
      (key, value) => MapEntry(key,
          {for (var item in value) item['id'] as int: item['onoma'] as String}),
    );
    return Suggestions(
      products: suggestions['products']!,
      manufacturers: suggestions['manufacturers']!,
      statuses: suggestions['states']!,
    );
  }

  Future<void> onSubmit() async {
    if (waiting.value) return;
    if (_formKey.currentState!.validate()) {
      waiting.value = true;
      final response = await http.post(
        Uri.parse("$apiUrl/login"),
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
        waiting.value = false;
        return;
      }
      final {'token': token, 'user': user} =
          jsonDecode(response.body) as Map<String, dynamic>;
      final suggestions = await getSuggestions();
      final records = await getRecords(user['id']);
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
                  token: token,
                ),
              ),
              ChangeNotifierProvider(create: (context) => records),
              ChangeNotifierProvider(create: (context) => suggestions),
            ],
            builder: (context, child) => const RecordListScreen(),
          ),
        ),
      );
      waiting.value = false;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
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
                validator: (value) =>
                    value == null || value.isEmpty ? "Εισάγετε username" : null,
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
                    value == null || value.isEmpty ? "Εισάγετε password" : null,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
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
