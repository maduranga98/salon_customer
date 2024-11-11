import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/Home%20Screen/home_screen.dart';
import 'package:customer_app/Login%20Pages/Registration/signUp_registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SigninRegistraion extends StatefulWidget {
  const SigninRegistraion({super.key});

  @override
  State<SigninRegistraion> createState() => _SigninRegistraionState();
}

class _SigninRegistraionState extends State<SigninRegistraion> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _isPasswordVisible = false;
  final mainColor = const Color(0xFF7B4B94); // Purple theme color
  final secondaryColor =
      const Color(0xFFF5E6FF); // Light purple for backgrounds

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Error',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );
        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        _showErrorDialog('Error signing in: ${e.toString()}');
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final uid = user.uid;

        // Check if the user is registered in Firestore
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // User exists in the database, navigate to the main page
          _showErrorDialog('This is not a registerd account');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // User is not registered, navigate to the registration page
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => UserRegistration()),
          // );
        }
      }
    } catch (e) {
      _showErrorDialog('Error signing in with Google: ${e.toString()}');
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(authCredential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorDialog('Error signing in with Apple: ${e.toString()}');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: FaIcon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.content_cut,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Text(
                    "Sign in to continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email field
                          TextFormField(
                            controller: _email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon:
                                  Icon(Icons.email_outlined, color: mainColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: mainColor, width: 2),
                              ),
                              labelStyle:
                                  GoogleFonts.poppins(color: Colors.grey[600]),
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.grey[400]),
                            ),
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: _password,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon:
                                  Icon(Icons.lock_outline, color: mainColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: mainColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: mainColor, width: 2),
                              ),
                              labelStyle:
                                  GoogleFonts.poppins(color: Colors.grey[600]),
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.grey[400]),
                            ),
                            style: GoogleFonts.poppins(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signInWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupRegistration()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            color: mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  _buildSectionHeader("OR CONTINUE WITH"),

                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        onPressed: _signInWithGoogle,
                        icon: FontAwesomeIcons.google,
                        label: "Google",
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        onPressed: _signInWithApple,
                        icon: FontAwesomeIcons.apple,
                        label: "Apple",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // QR Scanner section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Quick Access",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          // onPressed: () => Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => QRScannerScreen()),
                          // ),
                          icon: Icon(Icons.qr_code_scanner),
                          label: Text(
                            "Scan QR Code",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
