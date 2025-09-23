import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/landing/landing_page.dart';
import 'screens/courses/course_intro.dart';
import 'screens/courses/quiz_take.dart';
import 'screens/home/home_shell.dart';
import 'screens/teacher/course_editor.dart';
import 'screens/teacher/teacher_home.dart';
import 'screens/subscribe/subscribe_screen.dart';
import 'screens/auth/login.dart';
import 'screens/auth/signup.dart';
import 'screens/profile/profile_edit.dart';
import 'gate.dart';
import 'supabase_client.dart';
import 'screens/messages/chat_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: gate,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    final loggedIn = isLoggedIn;

    if (loggedIn && !gate.allowed) {
      gate.allow();
    } else if (!loggedIn && gate.allowed) {
      gate.reset();
    }

    if (loggedIn &&
        (loc == '/login' || loc == '/signup' || loc == '/' || loc == '/landing')) {
      return '/home';
    }

    final wantsHome = loc.startsWith('/home') || loc.startsWith('/teacher');
    if (wantsHome && !gate.allowed) {
      return '/';
    }
    if (loc.startsWith('/teacher') && !loggedIn) {
      return '/';
    }
    if (!loggedIn && loc.startsWith('/profile')) {
      return '/login';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/course-intro',
      name: 'course-intro',
      builder: (context, state) => const CourseIntroPage(),
    ),
    GoRoute(
      path: '/course-quiz',
      name: 'course-quiz',
      builder: (context, state) => const QuizTakePage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: '/profile/edit',
      name: 'profile-edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/subscribe',
      name: 'subscribe',
      builder: (context, state) => const SubscribeScreen(),
    ),
    GoRoute(
      path: '/teacher',
      name: 'teacher-home',
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: '/teacher/editor',
      name: 'teacher-editor',
      builder: (context, state) => CourseEditorScreen(
        courseId: state.uri.queryParameters['id'],
      ),
    ),
    GoRoute(
      path: '/messages/:uid',
      name: 'dm',
      builder: (context, state) => const ChatPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Fel')),
    body: Center(child: Text('Sidan hittades inte: ${state.error}')),
  ),
);

// Skärmarna definieras i respektive filer och importeras ovan.
