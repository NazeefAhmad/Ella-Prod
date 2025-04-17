import 'package:get/get.dart';

class LanguageConfig extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'app_name': 'Ella A.I',
          'welcome': 'Welcome',
          'login': 'Login',
          'signup': 'Sign Up',
          'email': 'Email',
          'password': 'Password',
          'forgot_password': 'Forgot Password?',
          'or': 'OR',
          'continue_with': 'Continue with',
          'dont_have_account': "Don't have an account?",
          'already_have_account': 'Already have an account?',
        },
        'es_ES': {
          'app_name': 'Ella A.I',
          'welcome': 'Bienvenido',
          'login': 'Iniciar Sesión',
          'signup': 'Registrarse',
          'email': 'Correo Electrónico',
          'password': 'Contraseña',
          'forgot_password': '¿Olvidaste tu contraseña?',
          'or': 'O',
          'continue_with': 'Continuar con',
          'dont_have_account': '¿No tienes una cuenta?',
          'already_have_account': '¿Ya tienes una cuenta?',
        },
      };
} 