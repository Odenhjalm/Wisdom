oden@oden-Vector:~/apps/Visdom$ flutter analyze
Resolving dependencies... 
Downloading packages... 
  _flutterfire_internals 1.3.59 (1.3.62 available)
  characters 1.4.0 (1.4.1 available)
  file_picker 8.3.7 (10.3.3 available)
  file_selector 1.0.3 (1.0.4 available)
  firebase_analytics 11.6.0 (12.0.2 available)
  firebase_analytics_platform_interface 4.4.3 (5.0.2 available)
  firebase_analytics_web 0.5.10+16 (0.6.0+2 available)
  firebase_core 3.15.2 (4.1.1 available)
  firebase_core_platform_interface 6.0.0 (6.0.1 available)
  firebase_core_web 2.24.1 (3.1.1 available)
  firebase_crashlytics 4.3.10 (5.0.2 available)
  firebase_crashlytics_platform_interface 3.8.10 (3.8.13 available)
  firebase_messaging 15.2.10 (16.0.2 available)
  firebase_messaging_platform_interface 4.6.10 (4.7.2 available)
  firebase_messaging_web 3.10.10 (4.0.2 available)
  firebase_remote_config 5.5.0 (6.0.2 available)
  firebase_remote_config_platform_interface 2.0.0 (2.0.3 available)
  firebase_remote_config_web 1.8.9 (1.8.12 available)
  flutter_dotenv 5.2.1 (6.0.0 available)
  flutter_lints 4.0.0 (6.0.0 available)
  flutter_markdown 0.7.7+1 (discontinued)
  flutter_riverpod 2.6.1 (3.0.0 available)
  flutter_secure_storage_linux 1.2.3 (2.0.1 available)
  flutter_secure_storage_macos 3.1.3 (4.0.0 available)
  flutter_secure_storage_platform_interface 1.1.2 (2.0.1 available)
  flutter_secure_storage_web 1.2.1 (2.0.0 available)
  flutter_secure_storage_windows 3.1.2 (4.0.0 available)
  go_router 14.8.1 (16.2.4 available)
  google_fonts 6.3.1 (6.3.2 available)
  gotrue 2.14.0 (2.15.0 available)
  js 0.6.7 (0.7.2 available)
  lints 4.0.0 (6.0.0 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  meta 1.16.0 (1.17.0 available)
  riverpod 2.6.1 (3.0.0 available)
  shared_preferences_android 2.4.12 (2.4.13 available)
  supabase 2.9.0 (2.9.1 available)
  supabase_flutter 2.10.0 (2.10.1 available)
  test_api 0.7.6 (0.7.7 available)
  url_launcher_android 6.3.21 (6.3.22 available)
Got dependencies!
1 package is discontinued.
39 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing Visdom...                                                     

   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/auth/presentation/new_password_page.dart:123:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/auth/presentation/new_password_page.dart:124:7 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/auth/presentation/new_password_page.dart:128:18 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/auth/presentation/new_password_page.dart:131:18 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/auth/presentation/settings_page.dart:19:19 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/auth/presentation/settings_page.dart:21:19 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/auth/presentation/settings_page.dart:48:19 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/auth/presentation/settings_page.dart:50:19 •
          use_build_context_synchronously
  error • The property 'message' can't be unconditionally accessed because the
         receiver can be 'null' •
         lib/features/community/presentation/home_page.dart:218:47 •
         unchecked_use_of_nullable_value
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/profile_page.dart:165:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/profile_page.dart:168:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/profile_page.dart:182:7 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/profile_page.dart:185:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/profile_page.dart:197:15 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/profile_page.dart:198:5 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/tarot_page.dart:109:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/community/presentation/tarot_page.dart:112:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/courses/presentation/course_page.dart:109:21 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/courses/presentation/course_page.dart:114:19 •
          use_build_context_synchronously
warning • Unused import: 'package:visdom/shared/utils/context_safe.dart' •
       lib/features/courses/presentation/quiz_take_page.dart:11:8 • unused_import
   info • 'groupValue' is deprecated and shouldn't be used. Use a RadioGroup
          ancestor to manage group value instead. This feature was deprecated
          after v3.32.0-0.0.pre •
          lib/features/courses/presentation/quiz_take_page.dart:316:17 •
          deprecated_member_use
   info • 'onChanged' is deprecated and shouldn't be used. Use RadioGroup to
          handle value change instead. This feature was deprecated after
          v3.32.0-0.0.pre •
          lib/features/courses/presentation/quiz_take_page.dart:317:17 •
          deprecated_member_use
   info • Don't use 'BuildContext's across async gaps •
          lib/features/landing/presentation/landing_page_legacy.dart:50:11 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/messages/presentation/messages_page.dart:74:17 •
          use_build_context_synchronously
warning • Unused import: 'package:visdom/shared/utils/context_safe.dart' •
       lib/features/payments/presentation/subscribe_screen.dart:6:8 •
       unused_import
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/payments/presentation/subscribe_screen.dart:94:9 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/payments/presentation/subscribe_screen.dart:216:39 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:181:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:183:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:185:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:220:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:288:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:385:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:387:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:400:17 •
          use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps •
          lib/features/studio/presentation/course_editor_page.dart:402:17 •
          use_build_context_synchronously

36 issues found. (ran in 1.5s)
oden@oden-Vector:~/apps/Visdom$ 