import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../authentication/email_verification_page.dart';

class EmailVerificationGuard extends StatelessWidget {
  final Widget child;

  const EmailVerificationGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        
        if (user == null) {
          return child;
        }

        return FutureBuilder<bool>(
          future: authProvider.isEmailVerified(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final isVerified = snapshot.data ?? false;
            if (!isVerified) {
              return EmailVerificationPage(
                email: user.email!,
                name: authProvider.userProfile?.name ?? user.email!.split('@')[0],
              );
            }

            return child;
          },
        );
      },
    );
  }
}