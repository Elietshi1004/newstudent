import 'package:flutter/widgets.dart';
import 'package:newstudent/ui/screens/auth/pages/login_page.dart';

class AuthUI extends StatefulWidget {
  const AuthUI({super.key});

  @override
  State<AuthUI> createState() => _AuthUIState();
}

class _AuthUIState extends State<AuthUI> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
