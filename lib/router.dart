import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdom/features/landing/presentation/landing_page.dart';
import 'package:wisdom/features/courses/presentation/course_intro_page.dart';
import 'package:wisdom/features/courses/presentation/quiz_take_page.dart';
import 'package:wisdom/features/community/presentation/home_shell.dart';
import 'package:wisdom/features/studio/presentation/course_editor_page.dart';
import 'package:wisdom/features/studio/presentation/teacher_home_page.dart';
import 'package:wisdom/features/payments/presentation/subscribe_screen.dart';
import 'package:wisdom/features/auth/presentation/login_page.dart';
import 'package:wisdom/features/auth/presentation/signup_page.dart';
import 'package:wisdom/features/community/presentation/profile_edit_page.dart';
import 'gate.dart';
import 'supabase_client.dart';
import 'package:wisdom/features/messages/presentation/chat_page.dart';

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
        (loc == '/login' ||
            loc == '/signup' ||
            loc == '/' ||
            loc == '/landing')) {
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
