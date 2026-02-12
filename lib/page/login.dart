import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              /// ================= LOGO =================
              SizedBox(
                height: 200,
                child: Center(
                  child: Image.asset(
                    'assets/logoD.png',
                    height: 200,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// ================= TITLE =================
              const Text(
                "Login to your Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF59595A),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= EMAIL =================
              TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ================= PASSWORD =================
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// ================= SIGN IN =================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              /// ================= OR =================
              Center(
                child: Text(
                  "- Or sign in with -",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),

              const SizedBox(height: 24),

              /// ================= SOCIAL LOGIN =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SocialCircleButton(imagePath: 'assets/goggle.png'),
                  SizedBox(width: 16),
                  SocialCircleButton(imagePath: 'assets/facebook.png'),
                  SizedBox(width: 16),
                  SocialCircleButton(imagePath: 'assets/twitter.png'),
                ],
              ),

              const SizedBox(height: 220),

              /// ================= SIGN UP =================
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= SOCIAL BUTTON =================
class SocialCircleButton extends StatelessWidget {
  final String imagePath;
  const SocialCircleButton({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60, // ⬅️ lebih besar
      height: 60, // ⬅️ lebih besar
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14), // ⬅️ logo ikut besar
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
