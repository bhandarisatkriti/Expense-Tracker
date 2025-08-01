import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_1/homepage.dart';
// separate HomePage file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('users'); // no type param to avoid runtime issues

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Login Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5E35B1),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF5E35B1),
          secondary: const Color(0xFFFFC107),
          error: const Color(0xFFD32F2F),
        ),
      ),
      home: const LoginPage(), // show login page first
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
      },
    );
  }
}

//
// ------------------ LOGIN PAGE ------------------
//
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userBox = Hive.box('users');
  String _error = '';

  void login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() => _error = '');

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter username and password.');
      return;
    }

    if (!_userBox.containsKey(username)) {
      setState(() => _error = 'User not found. Please sign up first.');
      return;
    }

    if (_userBox.get(username) != password) {
      setState(() => _error = 'Incorrect password.');
      return;
    }

    // Navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5E35B1), Color(0xFF9575CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 24),
                  TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: login, child: const Text('Login'))),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: Text('Create an account', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
// ------------------ SIGNUP PAGE ------------------
//
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userBox = Hive.box('users');
  String _error = '';
  String _success = '';

  void signup() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _error = '';
      _success = '';
    });

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter username and password.');
      return;
    }

    if (_userBox.containsKey(username)) {
      setState(() => _error = 'Username already exists.');
      return;
    }

    _userBox.put(username, password);
    setState(() {
      _success = 'Signup successful! You can login now.';
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5E35B1), Color(0xFF9575CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sign Up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 24),
                  TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Choose Username', prefixIcon: Icon(Icons.person_add))),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Choose Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: signup, child: const Text('Sign Up'))),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  if (_success.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_success, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 