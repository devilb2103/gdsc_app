import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const SignedOutState());
  bool _canTriggerAuthActions = true;

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } on FirebaseAuthException catch (e) {
      emit(LogInErrorState(e.message.toString()));
    }
    emit(const SignedOutState());
  }

  Future<void> logInEmailPass(String email, String password) async {
    if (!_canTriggerAuthActions) return;
    _canTriggerAuthActions = false;
    emit(const ProcessingState());

    //auth code goes here
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        emit(const LogInErrorState(
            "please verify your account using the verification sent on your email c:"));
        await signOut();
        _canTriggerAuthActions = true;
        return;
      }
      emit(const LoggedInState());
    } on FirebaseAuthException catch (e) {
      emit(LogInErrorState(e.message.toString()));
      emit(const SignedOutState());
    }

    _canTriggerAuthActions = true;
  }

  Future<void> loginGithub() async {
    if (!_canTriggerAuthActions) return;
    _canTriggerAuthActions = false;
    emit(const ProcessingState());

    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(githubProvider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(githubProvider);
      }

      emit(const LoggedInState());
    } on FirebaseAuthException catch (e) {
      emit(LogInErrorState(e.message.toString()));
      emit(const SignedOutState());
    }
    // Trigger the authentication flow
    _canTriggerAuthActions = true;
  }

  Future<void> loginGoogle() async {
    if (!_canTriggerAuthActions) return;
    _canTriggerAuthActions = false;
    emit(const ProcessingState());

    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithProvider(googleProvider);
      }

      emit(const LoggedInState());
    } on FirebaseAuthException catch (e) {
      emit(LogInErrorState(e.message.toString()));
      emit(const SignedOutState());
    }
    // Trigger the authentication flow
    _canTriggerAuthActions = true;
  }

  Future<void> sendResetPassword(String email) async {
    if (!_canTriggerAuthActions) return;
    _canTriggerAuthActions = false;

    emit(const ProcessingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(const SignedUpState("A recovery email has been sent c:"));
    } on FirebaseAuthException catch (e) {
      emit(SignUpErrorState(e.message.toString()));
    }
    emit(const SignedOutState());

    _canTriggerAuthActions = true;
  }

  Future<void> signUpEmailPass(String email, String password) async {
    if (!_canTriggerAuthActions) return;
    _canTriggerAuthActions = false;
    emit(const ProcessingState());
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      emit(const SignedUpState(
          "Account created successfully. Please verify your email to proceed"));
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      emit(SignUpErrorState(e.message.toString()));
    }
    emit(const SignedOutState());
    _canTriggerAuthActions = true;
  }
}