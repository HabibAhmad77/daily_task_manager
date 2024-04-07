import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_progress_tracker/app_constants.dart';
import 'package:my_progress_tracker/controllers/Auth_Controller.dart';
import 'package:my_progress_tracker/services/login_service.dart';
import 'package:my_progress_tracker/ui/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey[600],
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = false;
  bool passwordVisible = false;
  SharedPreferences? sharedPreferences;
  String? device_token;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        sharedPreferences = prefs;
        rememberMe = sharedPreferences!.getBool('rememberMe') ?? false;
        if (rememberMe) {
          _emailController.text = sharedPreferences!.getString('email') ?? '';
          _passwordController.text =
              sharedPreferences!.getString('password') ?? '';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 48.0),
                Hero(
                  tag: 'logo',
                  child: CircleAvatar(
                    radius: 100.0,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 48.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        obscureText: !passwordVisible,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        print(device_token);
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text("Remember Me"),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            // Login logic here
                            try {
                              final token = await LoginApi.login(
                                  _emailController.text.toString(),
                                  _passwordController.text.toString(),
                                  device_token.toString());

                              if (token.isNotEmpty) {
                                setState(() {
                                  isLoading = false;
                                  Constants.token = token.toString();
                                  // SharedPreferencesHelper.saveUserToken(token);
                                  print('value is saved===');
                                });
                                var def =
                                    SharedPreferencesHelper.getUserToken();
                                print('this is def $def');
                                print(token);

                                if (rememberMe && sharedPreferences != null) {
                                  sharedPreferences!
                                      .setBool('rememberMe', true);
                                  sharedPreferences!.setString('email',
                                      _emailController.text.toString());
                                  sharedPreferences!.setString('password',
                                      _passwordController.text.toString());
                                } else if (!rememberMe &&
                                    sharedPreferences != null) {
                                  sharedPreferences!.clear();
                                }
                                sharedPreferences!.setBool('isLoggedIn', true);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const HomePage()));
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                showToast(
                                    'Please enter Correct Email/Password');
                              }
                            } catch (error) {
                              setState(() {
                                isLoading = false;
                              });
                              showToast('Please enter Correct Email/Password');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text('LOGIN'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
