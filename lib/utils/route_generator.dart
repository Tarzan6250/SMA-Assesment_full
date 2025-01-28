import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/favourites_screen.dart';
import 'package:flutter_application_1/screens/my_courses.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/play_courses.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/setting.dart';
import 'package:flutter_application_1/screens/question_slider.dart';
import 'package:flutter_application_1/widgets/login_form.dart';
import 'page_transition.dart';
import '../screens/test_edit.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return LoadingPageRoute(page: LoginPageMobile());
      case '/dashboard':
        if (args is UserModel) {
          return LoadingPageRoute(page: DashboardScreen(user: args));
        }
        return _errorRoute();
      case '/my_courses':
        if (args is UserModel) {
          return LoadingPageRoute(page: MyCourses(user: args));
        }
        return _errorRoute();
      case '/play_courses':
        if (args is UserModel) {
          return LoadingPageRoute(page: Playcourses(user: args));
        }
        return _errorRoute();
      case '/favourites':
        if (args is UserModel) {
          return LoadingPageRoute(page: FavouritesScreen(user: args));
        }
        return _errorRoute();
      case '/notifications':
        return LoadingPageRoute(page: NotificationScreen());
      case '/profile':
        if (args is UserModel) {
          return LoadingPageRoute(page: ProfileScreen(user: args));
        }
        return _errorRoute();
      case '/settings':
        if (args is UserModel) {
          return LoadingPageRoute(page: SettingsPage(user: args));
        }
        return _errorRoute();
      case '/quiz':
        return LoadingPageRoute(page: QuizSlider());
      case '/test-edit':
        return MaterialPageRoute(builder: (_) => TestEdit());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Error: Invalid route or missing user data'),
        ),
      ),
    );
  }
}
