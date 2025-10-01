# Visdom Supabase Schema Snapshot
_Generated: 2025-09-28_212728_

## Schema `app`
### app.app_config
- Columns (4): `created_by`:uuid, `free_course_limit`:integer, `id`:integer, `platform_fee_pct`:numeric
- RLS enabled: True
- Policies (3): app_config_delete_owner_only, app_config_select_owner_or_published_chain, app_config_update_owner_only

### app.bookings
- Columns (8): `created_at`:timestamp with time zone, `created_by`:uuid, `id`:uuid, `order_id`:uuid, `slot_id`:uuid, `status`:text, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): bookings_delete_owner_only, bookings_select_owner_or_published_chain, bookings_update_owner_only
- Triggers (1): trg_bookings_touch

### app.certificates
- Columns (9): `created_at`:timestamp with time zone, `created_by`:uuid, `evidence_url`:text, `id`:uuid, `notes`:text, `status`:text, `title`:text, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): certificates_delete_owner_only, certificates_select_owner_or_published_chain, certificates_update_owner_only
- Triggers (1): trg_certificates_touch

### app.certifications
- Columns (6): `course_id`:uuid, `created_by`:uuid, `id`:uuid, `issued_at`:timestamp with time zone, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): certifications_delete_owner_only, certifications_select_owner_or_published_chain, certifications_update_owner_only
- Triggers (1): trg_certifications_touch

### app.courses
- Columns (14): `branch`:text, `cover_url`:text, `created_at`:timestamp with time zone, `created_by`:uuid, `description`:text, `id`:uuid, `intro_video_url`:text, `is_free_intro`:boolean, `is_published`:boolean, `price_cents`:integer, `slug`:text, `title`:text …(+2 more)
- RLS enabled: True
- Policies (3): courses_delete_owner_only, courses_select_owner_or_published_chain, courses_update_owner_only
- Triggers (2): trg_courses_set_owner, trg_courses_touch

### app.enrollments
- Columns (5): `course_id`:uuid, `created_at`:timestamp with time zone, `id`:uuid, `source`:USER-DEFINED, `user_id`:uuid
- RLS enabled: True
- Policies (3): enrollments_delete_owner_only, enrollments_select_owner_or_published_chain, enrollments_update_owner_only

### app.events
- Columns (10): `created_at`:timestamp with time zone, `created_by`:uuid, `description`:text, `ends_at`:timestamp with time zone, `id`:uuid, `is_published`:boolean, `location`:text, `starts_at`:timestamp with time zone, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): events_delete_owner_only, events_select_owner_or_published_chain, events_update_owner_only
- Triggers (1): trg_events_touch

### app.lesson_media
- Columns (7): `created_at`:timestamp with time zone, `duration_seconds`:integer, `id`:uuid, `kind`:text, `lesson_id`:uuid, `position`:integer, `storage_path`:text
- RLS enabled: True
- Policies (3): lesson_media_delete_owner_only, lesson_media_select_owner_or_published_chain, lesson_media_update_owner_only

### app.lessons
- Columns (9): `content_markdown`:text, `created_at`:timestamp with time zone, `created_by`:uuid, `id`:uuid, `is_intro`:boolean, `module_id`:uuid, `position`:integer, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): lessons_delete_owner_only, lessons_select_owner_or_published_chain, lessons_update_owner_only
- Triggers (1): trg_lessons_touch

### app.meditations
- Columns (10): `audio_path`:text, `created_at`:timestamp with time zone, `created_by`:uuid, `description`:text, `duration_seconds`:integer, `id`:uuid, `is_public`:boolean, `teacher_id`:uuid, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): meditations_delete_owner_only, meditations_select_owner_or_published_chain, meditations_update_owner_only
- Triggers (1): trg_meditations_touch

### app.memberships
- Columns (6): `created_by`:uuid, `current_period_end`:timestamp with time zone, `plan`:USER-DEFINED, `status`:USER-DEFINED, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): memberships_delete_owner_only, memberships_select_owner_or_published_chain, memberships_update_owner_only
- Triggers (1): trg_memberships_touch

### app.messages
- Columns (7): `channel`:text, `content`:text, `created_at`:timestamp with time zone, `created_by`:uuid, `id`:uuid, `sender_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): messages_delete_owner_only, messages_select_owner_or_published_chain, messages_update_owner_only
- Triggers (1): trg_messages_touch

### app.modules
- Columns (7): `course_id`:uuid, `created_at`:timestamp with time zone, `created_by`:uuid, `id`:uuid, `position`:integer, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): modules_delete_owner_only, modules_select_owner_or_published_chain, modules_update_owner_only
- Triggers (1): trg_modules_touch

### app.orders
- Columns (13): `amount_cents`:integer, `course_id`:uuid, `created_at`:timestamp with time zone, `created_by`:uuid, `currency`:text, `id`:uuid, `metadata`:jsonb, `service_id`:uuid, `status`:USER-DEFINED, `stripe_checkout_id`:text, `stripe_payment_intent`:text, `updated_at`:timestamp with time zone …(+1 more)
- RLS enabled: True
- Policies (3): orders_delete_owner_only, orders_select_owner_or_published_chain, orders_update_owner_only
- Triggers (1): trg_orders_touch

### app.pro_progress
- Columns (5): `completed_at`:timestamp with time zone, `created_by`:uuid, `requirement_id`:integer, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): pro_progress_delete_owner_only, pro_progress_select_owner_or_published_chain, pro_progress_update_owner_only
- Triggers (1): trg_pro_progress_touch

### app.pro_requirements
- Columns (5): `code`:text, `created_by`:uuid, `id`:integer, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): pro_requirements_delete_owner_only, pro_requirements_select_owner_or_published_chain, pro_requirements_update_owner_only
- Triggers (1): trg_pro_requirements_touch

### app.profiles
- Columns (10): `bio`:text, `created_at`:timestamp with time zone, `display_name`:text, `email`:text, `is_admin`:boolean, `photo_url`:text, `role`:USER-DEFINED, `role_v2`:USER-DEFINED, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): profiles_delete_owner_only, profiles_select_owner_or_published_chain, profiles_update_owner_only
- Triggers (1): trg_profiles_touch

### app.services
- Columns (9): `created_at`:timestamp with time zone, `created_by`:uuid, `description`:text, `id`:uuid, `is_active`:boolean, `price_cents`:integer, `provider_id`:uuid, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): services_delete_owner_only, services_select_owner_or_published_chain, services_update_owner_only
- Triggers (1): trg_services_touch

### app.tarot_requests
- Columns (10): `created_at`:timestamp with time zone, `created_by`:uuid, `deliverable_url`:text, `id`:uuid, `order_id`:uuid, `question`:text, `reader_id`:uuid, `requester_id`:uuid, `status`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (3): tarot_requests_delete_owner_only, tarot_requests_select_owner_or_published_chain, tarot_requests_update_owner_only
- Triggers (2): trg_tarot_requests_touch, trg_tarot_touch

### app.teacher_approvals
- Columns (5): `approved_at`:timestamp with time zone, `approved_by`:uuid, `created_by`:uuid, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): teacher_approvals_delete_owner_only, teacher_approvals_select_owner_or_published_chain, teacher_approvals_update_owner_only
- Triggers (1): trg_teacher_approvals_touch

### app.teacher_directory
- Columns (5): `created_at`:timestamp with time zone, `headline`:text, `rating`:numeric, `specialties`:ARRAY, `user_id`:uuid
- RLS enabled: True
- Policies (3): teacher_directory_delete_owner_only, teacher_directory_select_owner_or_published_chain, teacher_directory_update_owner_only

### app.teacher_permissions
- Columns (5): `can_edit_courses`:boolean, `can_publish`:boolean, `granted_at`:timestamp with time zone, `granted_by`:uuid, `profile_id`:uuid
- RLS enabled: True
- Policies (3): teacher_permissions_delete_owner_only, teacher_permissions_select_owner_or_published_chain, teacher_permissions_update_owner_only

### app.teacher_requests
- Columns (7): `created_at`:timestamp with time zone, `id`:uuid, `message`:text, `reviewed_by`:uuid, `status`:text, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: True
- Policies (3): teacher_requests_delete_owner_only, teacher_requests_select_owner_or_published_chain, teacher_requests_update_owner_only

### app.teacher_slots
- Columns (6): `created_at`:timestamp with time zone, `ends_at`:timestamp with time zone, `id`:uuid, `is_booked`:boolean, `starts_at`:timestamp with time zone, `teacher_id`:uuid
- RLS enabled: True
- Policies (3): teacher_slots_delete_owner_only, teacher_slots_select_owner_or_published_chain, teacher_slots_update_owner_only


## Schema `auth`
### auth.audit_log_entries
- Columns (5): `created_at`:timestamp with time zone, `id`:uuid, `instance_id`:uuid, `ip_address`:character varying, `payload`:json
- RLS enabled: False

### auth.flow_state
- Columns (12): `auth_code`:text, `auth_code_issued_at`:timestamp with time zone, `authentication_method`:text, `code_challenge`:text, `code_challenge_method`:USER-DEFINED, `created_at`:timestamp with time zone, `id`:uuid, `provider_access_token`:text, `provider_refresh_token`:text, `provider_type`:text, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False

### auth.identities
- Columns (9): `created_at`:timestamp with time zone, `email`:text, `id`:uuid, `identity_data`:jsonb, `last_sign_in_at`:timestamp with time zone, `provider`:text, `provider_id`:text, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False

### auth.instances
- Columns (5): `created_at`:timestamp with time zone, `id`:uuid, `raw_base_config`:text, `updated_at`:timestamp with time zone, `uuid`:uuid
- RLS enabled: False

### auth.mfa_amr_claims
- Columns (5): `authentication_method`:text, `created_at`:timestamp with time zone, `id`:uuid, `session_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: False

### auth.mfa_challenges
- Columns (7): `created_at`:timestamp with time zone, `factor_id`:uuid, `id`:uuid, `ip_address`:inet, `otp_code`:text, `verified_at`:timestamp with time zone, `web_authn_session_data`:jsonb
- RLS enabled: False

### auth.mfa_factors
- Columns (12): `created_at`:timestamp with time zone, `factor_type`:USER-DEFINED, `friendly_name`:text, `id`:uuid, `last_challenged_at`:timestamp with time zone, `phone`:text, `secret`:text, `status`:USER-DEFINED, `updated_at`:timestamp with time zone, `user_id`:uuid, `web_authn_aaguid`:uuid, `web_authn_credential`:jsonb
- RLS enabled: False

### auth.oauth_clients
- Columns (12): `client_id`:text, `client_name`:text, `client_secret_hash`:text, `client_uri`:text, `created_at`:timestamp with time zone, `deleted_at`:timestamp with time zone, `grant_types`:text, `id`:uuid, `logo_uri`:text, `redirect_uris`:text, `registration_type`:USER-DEFINED, `updated_at`:timestamp with time zone
- RLS enabled: False

### auth.one_time_tokens
- Columns (7): `created_at`:timestamp without time zone, `id`:uuid, `relates_to`:text, `token_hash`:text, `token_type`:USER-DEFINED, `updated_at`:timestamp without time zone, `user_id`:uuid
- RLS enabled: False

### auth.refresh_tokens
- Columns (9): `created_at`:timestamp with time zone, `id`:bigint, `instance_id`:uuid, `parent`:character varying, `revoked`:boolean, `session_id`:uuid, `token`:character varying, `updated_at`:timestamp with time zone, `user_id`:character varying
- RLS enabled: False

### auth.saml_providers
- Columns (9): `attribute_mapping`:jsonb, `created_at`:timestamp with time zone, `entity_id`:text, `id`:uuid, `metadata_url`:text, `metadata_xml`:text, `name_id_format`:text, `sso_provider_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: False

### auth.saml_relay_states
- Columns (8): `created_at`:timestamp with time zone, `flow_state_id`:uuid, `for_email`:text, `id`:uuid, `redirect_to`:text, `request_id`:text, `sso_provider_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: False

### auth.schema_migrations
- Columns (1): `version`:character varying
- RLS enabled: False

### auth.sessions
- Columns (11): `aal`:USER-DEFINED, `created_at`:timestamp with time zone, `factor_id`:uuid, `id`:uuid, `ip`:inet, `not_after`:timestamp with time zone, `refreshed_at`:timestamp without time zone, `tag`:text, `updated_at`:timestamp with time zone, `user_agent`:text, `user_id`:uuid
- RLS enabled: False

### auth.sso_domains
- Columns (5): `created_at`:timestamp with time zone, `domain`:text, `id`:uuid, `sso_provider_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: False

### auth.sso_providers
- Columns (5): `created_at`:timestamp with time zone, `disabled`:boolean, `id`:uuid, `resource_id`:text, `updated_at`:timestamp with time zone
- RLS enabled: False

### auth.users
- Columns (35): `aud`:character varying, `banned_until`:timestamp with time zone, `confirmation_sent_at`:timestamp with time zone, `confirmation_token`:character varying, `confirmed_at`:timestamp with time zone, `created_at`:timestamp with time zone, `deleted_at`:timestamp with time zone, `email`:character varying, `email_change`:character varying, `email_change_confirm_status`:smallint, `email_change_sent_at`:timestamp with time zone, `email_change_token_current`:character varying …(+23 more)
- RLS enabled: False
- Triggers (1): on_auth_user_created


## Schema `extensions`
### extensions.pg_stat_statements
- Columns (49): `calls`:bigint, `dbid`:oid, `jit_deform_count`:bigint, `jit_deform_time`:double precision, `jit_emission_count`:bigint, `jit_emission_time`:double precision, `jit_functions`:bigint, `jit_generation_time`:double precision, `jit_inlining_count`:bigint, `jit_inlining_time`:double precision, `jit_optimization_count`:bigint, `jit_optimization_time`:double precision …(+37 more)
- RLS enabled: False

### extensions.pg_stat_statements_info
- Columns (2): `dealloc`:bigint, `stats_reset`:timestamp with time zone
- RLS enabled: False


## Schema `public`
### public.admin_keys
- Columns (5): `code`:text, `issued_at`:timestamp with time zone, `issued_by`:uuid, `redeemed_at`:timestamp with time zone, `redeemed_by`:uuid
- RLS enabled: False

### public.availability_slots
- Columns (11): `created_at`:timestamp with time zone, `description`:text, `duration_minutes`:integer, `end_time`:timestamp with time zone, `id`:uuid, `is_booked`:boolean, `price`:integer, `start_time`:timestamp with time zone, `teacher_id`:uuid, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (1): update_availability_slots_updated_at

### public.bookings
- Columns (10): `created_at`:timestamp with time zone, `id`:uuid, `notes`:text, `payment_status`:text, `slot_id`:uuid, `status`:text, `stripe_payment_intent_id`:text, `student_id`:uuid, `teacher_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (1): update_bookings_updated_at

### public.certificates
- Columns (4): `course_id`:uuid, `id`:uuid, `issued_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False

### public.coupons
- Columns (9): `code`:text, `expires_at`:timestamp with time zone, `grants`:jsonb, `is_enabled`:boolean, `issued_at`:timestamp with time zone, `issued_by`:uuid, `max_redemptions`:integer, `plan_id`:uuid, `redeemed_count`:integer
- RLS enabled: False

### public.course_enrollments
- Columns (5): `course_id`:uuid, `enrolled_at`:timestamp with time zone, `id`:uuid, `status`:text, `student_id`:uuid
- RLS enabled: False
- Triggers (1): update_course_enrollments_updated_at

### public.course_modules
- Columns (10): `body`:text, `course_id`:uuid, `created_at`:timestamp with time zone, `created_by`:uuid, `id`:uuid, `media_url`:text, `position`:integer, `title`:text, `type`:text, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (2): trg_course_modules_created_by, trg_course_modules_set_created_by

### public.course_quizzes
- Columns (6): `course_id`:uuid, `created_at`:timestamp with time zone, `created_by`:uuid, `id`:uuid, `pass_score`:integer, `title`:text
- RLS enabled: False

### public.courses
- Columns (16): `branch`:text, `cover_url`:text, `created_at`:timestamp with time zone, `created_by`:uuid, `description`:text, `id`:uuid, `is_free`:boolean, `is_free_intro`:boolean, `is_intro`:boolean, `is_published`:boolean, `price`:integer, `price_cents`:integer …(+4 more)
- RLS enabled: False
- Triggers (2): trg_courses_created_by, update_courses_updated_at

### public.lesson_media
- Columns (6): `created_at`:timestamp with time zone, `id`:uuid, `is_public`:boolean, `lesson_id`:uuid, `storage_path`:text, `type`:text
- RLS enabled: False

### public.lessons
- Columns (8): `content`:jsonb, `created_at`:timestamp with time zone, `free_preview`:boolean, `id`:uuid, `index`:integer, `module_id`:uuid, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (1): update_lessons_updated_at

### public.messages
- Columns (9): `content`:text, `course_id`:uuid, `created_at`:timestamp with time zone, `id`:uuid, `is_read`:boolean, `parent_message_id`:uuid, `recipient_id`:uuid, `sender_id`:uuid, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (1): update_messages_updated_at

### public.modules
- Columns (6): `course_id`:uuid, `created_at`:timestamp with time zone, `id`:uuid, `index`:integer, `title`:text, `updated_at`:timestamp with time zone
- RLS enabled: True
- Policies (1): public_modules_select_all
- Triggers (1): update_modules_updated_at

### public.notifications
- Columns (8): `created_at`:timestamp with time zone, `id`:uuid, `is_read`:boolean, `message`:text, `metadata`:jsonb, `title`:text, `type`:text, `user_id`:uuid
- RLS enabled: False

### public.profiles
- Columns (9): `avatar_url`:text, `bio`:text, `created_at`:timestamp with time zone, `email`:text, `full_name`:text, `id`:uuid, `role`:USER-DEFINED, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False
- Triggers (1): update_profiles_updated_at

### public.public_teacher_info
- Columns (7): `avatar_url`:text, `bio`:text, `created_at`:timestamp with time zone, `full_name`:text, `id`:uuid, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False
- Triggers (1): update_public_teacher_info_updated_at

### public.quiz_attempts
- Columns (7): `answers`:jsonb, `id`:uuid, `passed`:boolean, `quiz_id`:uuid, `score`:integer, `submitted_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False

### public.quiz_questions
- Columns (8): `correct`:jsonb, `created_at`:timestamp with time zone, `id`:uuid, `kind`:text, `options`:jsonb, `position`:integer, `prompt`:text, `quiz_id`:uuid
- RLS enabled: False

### public.services
- Columns (7): `certified_area`:text, `created_at`:timestamp with time zone, `description`:text, `id`:uuid, `owner`:uuid, `price_cents`:integer, `title`:text
- RLS enabled: False
- Triggers (1): trg_services_owner

### public.subscription_plans
- Columns (7): `created_at`:timestamp with time zone, `id`:uuid, `interval`:text, `is_active`:boolean, `name`:text, `price_cents`:integer, `trial_days`:integer
- RLS enabled: False

### public.subscriptions
- Columns (7): `amount_cents`:integer, `created_at`:timestamp with time zone, `current_period_end`:timestamp with time zone, `id`:uuid, `plan_id`:uuid, `status`:text, `user_id`:uuid
- RLS enabled: False

### public.tarot_readings
- Columns (14): `created_at`:timestamp with time zone, `delivery_type`:text, `id`:uuid, `payment_status`:text, `price`:integer, `question`:text, `response_audio_url`:text, `response_text`:text, `response_video_url`:text, `status`:text, `stripe_payment_intent_id`:text, `student_id`:uuid …(+2 more)
- RLS enabled: False
- Triggers (1): update_tarot_readings_updated_at

### public.teacher_directory
- Columns (10): `avatar_url`:text, `created_at`:timestamp with time zone, `display_name`:text, `headline`:text, `id`:uuid, `is_accepting`:boolean, `price_cents`:integer, `specialties`:ARRAY, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False
- Triggers (1): update_teacher_directory_updated_at

### public.teacher_permissions
- Columns (3): `granted_at`:timestamp with time zone, `granted_by`:uuid, `user_id`:uuid
- RLS enabled: False

### public.teacher_permissions_compat
- Columns (6): `can_edit_courses`:boolean, `can_publish`:boolean, `granted_at`:timestamp with time zone, `granted_by`:uuid, `profile_id`:uuid, `user_id`:uuid
- RLS enabled: False

### public.teacher_requests
- Columns (6): `created_at`:timestamp with time zone, `id`:uuid, `note`:text, `status`:text, `updated_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False
- Triggers (1): update_teacher_requests_updated_at

### public.user_certifications
- Columns (3): `area`:text, `granted_at`:timestamp with time zone, `user_id`:uuid
- RLS enabled: False

### public.user_roles
- Columns (4): `created_at`:timestamp with time zone, `id`:uuid, `role`:USER-DEFINED, `user_id`:uuid
- RLS enabled: False
- Triggers (1): on_teacher_role_created


## Schema `realtime`
### realtime.messages
- Columns (8): `event`:text, `extension`:text, `id`:uuid, `inserted_at`:timestamp without time zone, `payload`:jsonb, `private`:boolean, `topic`:text, `updated_at`:timestamp without time zone
- RLS enabled: False

### realtime.schema_migrations
- Columns (2): `inserted_at`:timestamp without time zone, `version`:bigint
- RLS enabled: False

### realtime.subscription
- Columns (7): `claims`:jsonb, `claims_role`:regrole, `created_at`:timestamp without time zone, `entity`:regclass, `filters`:ARRAY, `id`:bigint, `subscription_id`:uuid
- RLS enabled: False
- Triggers (1): tr_check_filters


## Schema `storage`
### storage.buckets
- Columns (11): `allowed_mime_types`:ARRAY, `avif_autodetection`:boolean, `created_at`:timestamp with time zone, `file_size_limit`:bigint, `id`:text, `name`:text, `owner`:uuid, `owner_id`:text, `public`:boolean, `type`:USER-DEFINED, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (1): enforce_bucket_name_length_trigger

### storage.buckets_analytics
- Columns (5): `created_at`:timestamp with time zone, `format`:text, `id`:text, `type`:USER-DEFINED, `updated_at`:timestamp with time zone
- RLS enabled: False

### storage.migrations
- Columns (4): `executed_at`:timestamp without time zone, `hash`:character varying, `id`:integer, `name`:character varying
- RLS enabled: False

### storage.objects
- Columns (13): `bucket_id`:text, `created_at`:timestamp with time zone, `id`:uuid, `last_accessed_at`:timestamp with time zone, `level`:integer, `metadata`:jsonb, `name`:text, `owner`:uuid, `owner_id`:text, `path_tokens`:ARRAY, `updated_at`:timestamp with time zone, `user_metadata`:jsonb …(+1 more)
- RLS enabled: False
- Triggers (4): objects_delete_delete_prefix, objects_insert_create_prefix, objects_update_create_prefix, update_objects_updated_at

### storage.prefixes
- Columns (5): `bucket_id`:text, `created_at`:timestamp with time zone, `level`:integer, `name`:text, `updated_at`:timestamp with time zone
- RLS enabled: False
- Triggers (2): prefixes_create_hierarchy, prefixes_delete_hierarchy

### storage.s3_multipart_uploads
- Columns (9): `bucket_id`:text, `created_at`:timestamp with time zone, `id`:text, `in_progress_size`:bigint, `key`:text, `owner_id`:text, `upload_signature`:text, `user_metadata`:jsonb, `version`:text
- RLS enabled: False

### storage.s3_multipart_uploads_parts
- Columns (10): `bucket_id`:text, `created_at`:timestamp with time zone, `etag`:text, `id`:uuid, `key`:text, `owner_id`:text, `part_number`:integer, `size`:bigint, `upload_id`:text, `version`:text
- RLS enabled: False


## Schema `supabase_migrations`
### supabase_migrations.schema_migrations
- Columns (5): `created_by`:text, `idempotency_key`:text, `name`:text, `statements`:ARRAY, `version`:text
- RLS enabled: False


## Schema `vault`
### vault.decrypted_secrets
- Columns (9): `created_at`:timestamp with time zone, `decrypted_secret`:text, `description`:text, `id`:uuid, `key_id`:uuid, `name`:text, `nonce`:bytea, `secret`:text, `updated_at`:timestamp with time zone
- RLS enabled: False

### vault.secrets
- Columns (8): `created_at`:timestamp with time zone, `description`:text, `id`:uuid, `key_id`:uuid, `name`:text, `nonce`:bytea, `secret`:text, `updated_at`:timestamp with time zone
- RLS enabled: False

