
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';






import '../../../services/goggle_SiginIn.dart';
import 'register.dart';
import 'sign_in_form.dart';

void showCustomDialog(BuildContext context, {required ValueChanged onValue}) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Container(
          height: 620,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 30),
                blurRadius: 60,
              ),
              const BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 30),
                blurRadius: 60,
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
              children: <Widget>[

                Column(
                  children: [
                    const Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 34,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Already have an Account? Then Sign in once for uninterrupt access",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SignInForm(),
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.black26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        "Sign up with Email or Google",
                       
                        style: TextStyle(color: Colors.black54),
                      ),
                      
                    ),
                  
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        
                          
                          IconButton(
                          padding: EdgeInsets.zero,
                          icon: SvgPicture.asset(
                            "assets/icons/email-svgrepo-com.svg",
                            height: 50,
                            width: 50,
                          ), onPressed: () { 
                            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );
                           }, 
                        ),
                        
                        IconButton(
                         onPressed: () async {
  final user = await AuthService().signInWithGoogle(context);
  if (user != null) {
    
  } else {
    // Handle the case where sign-in failed.
  }
},

                          padding: EdgeInsets.zero,
                          icon: SvgPicture.asset(
                            "assets/icons/google_icon.svg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
               
              ],
            ),
          ),
        ),
      )
      );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween;
      // if (anim.status == AnimationStatus.reverse) {
      //   tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
      // } else {
      //   tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      // }

      tween = Tween(begin: const Offset(0, -1), end: Offset.zero);

      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        ),
        // child: FadeTransition(
        //   opacity: anim,
        //   child: child,
        // ),
        child: child,
      );
    },
  ).then(onValue);
}