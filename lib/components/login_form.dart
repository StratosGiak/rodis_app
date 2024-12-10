import 'package:flutter/material.dart';
import 'package:rodis_service/api_handler.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/suggestions.dart';
import 'package:rodis_service/models/user.dart';
import 'package:rodis_service/screens/record_list_screen.dart';
import 'package:provider/provider.dart';

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
  late final apiHandler = context.read<ApiHandler>();

  final loginErrorSnackbar = const SnackBar(content: Text('Λάθος στοιχεία'));
  final connectionErrorSnackbar =
      const SnackBar(content: Text('Η σύνδεση με τον σέρβερ απέτυχε'));
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
        final user = await apiHandler
            .postLogin(usernameController.text, passwordController.text)
            .timeout(const Duration(seconds: 6));
        if (!mounted) return;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(loginErrorSnackbar);
          waiting.value = false;
          return;
        }
        final suggestions = Suggestions.fromJSON(
          await apiHandler.getSuggestions(),
        );
        final records =
            Records(records: await apiHandler.getRecordsBy(user['id']));
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                Provider(
                  create: (_) => User(
                    id: user['id'],
                    username: usernameController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(connectionErrorSnackbar);
      } finally {
        waiting.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
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
                  keyboardType: TextInputType.name,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.username],
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
                  autocorrect: false,
                  autofillHints: const [AutofillHints.password],
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
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
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
      ),
    );
  }
}
