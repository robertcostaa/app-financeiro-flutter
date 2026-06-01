import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _localRepository = UserRepository();
  final FirebaseAuthRepository _firebaseRepository = FirebaseAuthRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _firebaseRepository.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _errorMessage = 'Não foi possível autenticar o usuário.';
        return false;
      }

      UserModel? localUser =
          await _localRepository.getByEmail(email.trim().toLowerCase());

      if (localUser == null) {
        final profile =
            await _firebaseRepository.getUserProfile(firebaseUser.uid);

        final name = profile?['name']?.toString() ??
            firebaseUser.displayName ??
            'Usuário';

        await _localRepository.createUser(
          UserModel(
            name: name,
            email: email.trim().toLowerCase(),
            password: '',
          ),
        );

        localUser =
            await _localRepository.getByEmail(email.trim().toLowerCase());
      }

      if (localUser == null) {
        _errorMessage = 'Erro ao carregar usuário local.';
        return false;
      }

      _currentUser = localUser;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao fazer login: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final normalizedEmail = email.trim().toLowerCase();

      await _firebaseRepository.register(
        name: name,
        email: normalizedEmail,
        password: password,
      );

      await _localRepository.createUser(
        UserModel(
          name: name.trim(),
          email: normalizedEmail,
          password: '',
        ),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _firebaseRepository.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Erro de autenticação: ${e.message ?? e.code}';
    }
  }
}
