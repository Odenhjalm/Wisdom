oden@oden-Vector:~/apps/Visdom/mcp-supabase-http$ flutter run
Changing current working directory to: /home/oden/apps/Visdom
Connected devices:
Linux (desktop) • linux  • linux-x64      • Ubuntu 24.04.3 LTS 6.14.0-32-generic
Chrome (web)    • chrome • web-javascript • Google Chrome 140.0.7339.127
[1]: Linux (linux)
[2]: Chrome (chrome)
Please choose one (or "q" to quit): 1
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
Launching lib/main.dart on Linux in debug mode...
ERROR: lib/features/studio/data/certificates_repository.dart:24:13: Error: The method 'eq' isn't defined for the type 'PostgrestTransformBuilder<List<Map<String, dynamic>>>'.
ERROR:  - 'PostgrestTransformBuilder' is from 'package:postgrest/src/postgrest_builder.dart' ('../../.pub-cache/hosted/pub.dev/postgrest-2.4.2/lib/src/postgrest_builder.dart').
ERROR:  - 'List' is from 'dart:core'.
ERROR:  - 'Map' is from 'dart:core'.
ERROR: Try correcting the name to the name of an existing method, or defining a method named 'eq'.
ERROR:       query.eq('status', 'verified');
ERROR:             ^^
ERROR: lib/features/studio/data/certificates_repository.dart:40:13: Error: The method 'eq' isn't defined for the type 'PostgrestTransformBuilder<List<Map<String, dynamic>>>'.
ERROR:  - 'PostgrestTransformBuilder' is from 'package:postgrest/src/postgrest_builder.dart' ('../../.pub-cache/hosted/pub.dev/postgrest-2.4.2/lib/src/postgrest_builder.dart').
ERROR:  - 'List' is from 'dart:core'.
ERROR:  - 'Map' is from 'dart:core'.
ERROR: Try correcting the name to the name of an existing method, or defining a method named 'eq'.
ERROR:       query.eq('status', 'verified');
ERROR:             ^^
ERROR: lib/domain/services/auth_service.dart:27:38: Error: The getter 'app' isn't defined for the type 'SupabaseClient'.
ERROR:  - 'SupabaseClient' is from 'package:supabase/src/supabase_client.dart' ('../../.pub-cache/hosted/pub.dev/supabase-2.9.0/lib/src/supabase_client.dart').
ERROR: Try correcting the name to the name of an existing getter, or defining a getter or field named 'app'.
ERROR:       final approval = await _client.app
ERROR:                                      ^^^
ERROR: lib/domain/services/auth_service.dart:34:41: Error: The getter 'app' isn't defined for the type 'SupabaseClient'.
ERROR:  - 'SupabaseClient' is from 'package:supabase/src/supabase_client.dart' ('../../.pub-cache/hosted/pub.dev/supabase-2.9.0/lib/src/supabase_client.dart').
ERROR: Try correcting the name to the name of an existing getter, or defining a getter or field named 'app'.
ERROR:       final certificate = await _client.app
ERROR:                                         ^^^
ERROR: Target kernel_snapshot_program failed: Exception
Building Linux application...                                           
Error: Build process failed
oden@oden-Vector:~/apps/Visdom/mcp-supabase-http$ 