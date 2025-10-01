--
-- PostgreSQL database dump
--

\restrict WlxWywGIIJ8ijT2hWc5PleVIWhvnVfG33NrQWvmbPbjZ9z3PxeRbYwySOfjJcTv

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-2.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: app_config app_config_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."app_config"
    ADD CONSTRAINT "app_config_pkey" PRIMARY KEY ("id");


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");


--
-- Name: bookings bookings_slot_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_slot_id_key" UNIQUE ("slot_id");


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certificates"
    ADD CONSTRAINT "certificates_pkey" PRIMARY KEY ("id");


--
-- Name: certifications certifications_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_pkey" PRIMARY KEY ("id");


--
-- Name: certifications certifications_user_id_course_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_user_id_course_id_key" UNIQUE ("user_id", "course_id");


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."courses"
    ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("id");


--
-- Name: courses courses_slug_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."courses"
    ADD CONSTRAINT "courses_slug_key" UNIQUE ("slug");


--
-- Name: drip_plans drip_plans_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_plans"
    ADD CONSTRAINT "drip_plans_pkey" PRIMARY KEY ("id");


--
-- Name: drip_rules drip_rules_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_pkey" PRIMARY KEY ("id");


--
-- Name: editor_styles editor_styles_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."editor_styles"
    ADD CONSTRAINT "editor_styles_pkey" PRIMARY KEY ("id");


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_pkey" PRIMARY KEY ("id");


--
-- Name: enrollments enrollments_user_id_course_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_user_id_course_id_key" UNIQUE ("user_id", "course_id");


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id");


--
-- Name: guest_claim_tokens guest_claim_tokens_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."guest_claim_tokens"
    ADD CONSTRAINT "guest_claim_tokens_pkey" PRIMARY KEY ("token");


--
-- Name: lesson_media lesson_media_lesson_id_position_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lesson_media"
    ADD CONSTRAINT "lesson_media_lesson_id_position_key" UNIQUE ("lesson_id", "position");


--
-- Name: lesson_media lesson_media_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lesson_media"
    ADD CONSTRAINT "lesson_media_pkey" PRIMARY KEY ("id");


--
-- Name: lessons lessons_module_id_position_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lessons"
    ADD CONSTRAINT "lessons_module_id_position_key" UNIQUE ("module_id", "position");


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lessons"
    ADD CONSTRAINT "lessons_pkey" PRIMARY KEY ("id");


--
-- Name: magic_links magic_links_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_pkey" PRIMARY KEY ("id");


--
-- Name: meditations meditations_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."meditations"
    ADD CONSTRAINT "meditations_pkey" PRIMARY KEY ("id");


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."memberships"
    ADD CONSTRAINT "memberships_pkey" PRIMARY KEY ("user_id");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--
-- Name: modules modules_course_id_position_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."modules"
    ADD CONSTRAINT "modules_course_id_position_key" UNIQUE ("course_id", "position");


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("id");


--
-- Name: notification_jobs notification_jobs_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_pkey" PRIMARY KEY ("id");


--
-- Name: notification_templates notification_templates_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_templates"
    ADD CONSTRAINT "notification_templates_pkey" PRIMARY KEY ("id");


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");


--
-- Name: pro_progress pro_progress_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_progress"
    ADD CONSTRAINT "pro_progress_pkey" PRIMARY KEY ("user_id", "requirement_id");


--
-- Name: pro_requirements pro_requirements_code_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_requirements"
    ADD CONSTRAINT "pro_requirements_code_key" UNIQUE ("code");


--
-- Name: pro_requirements pro_requirements_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_requirements"
    ADD CONSTRAINT "pro_requirements_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("user_id");


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_pkey" PRIMARY KEY ("id");


--
-- Name: purchases purchases_stripe_checkout_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_stripe_checkout_id_key" UNIQUE ("stripe_checkout_id");


--
-- Name: purchases purchases_stripe_payment_intent_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_stripe_payment_intent_key" UNIQUE ("stripe_payment_intent");


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."services"
    ADD CONSTRAINT "services_pkey" PRIMARY KEY ("id");


--
-- Name: tarot_requests tarot_requests_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_approvals teacher_approvals_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_approvals"
    ADD CONSTRAINT "teacher_approvals_pkey" PRIMARY KEY ("user_id");


--
-- Name: teacher_directory teacher_directory_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_pkey" PRIMARY KEY ("user_id");


--
-- Name: teacher_permissions teacher_permissions_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_pkey" PRIMARY KEY ("profile_id");


--
-- Name: teacher_requests teacher_requests_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_requests teacher_requests_user_id_key; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_user_id_key" UNIQUE ("user_id");


--
-- Name: teacher_slots teacher_slots_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_slots"
    ADD CONSTRAINT "teacher_slots_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "amr_id_pk" PRIMARY KEY ("id");


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."flow_state"
    ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE ("provider_id", "provider");


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE ("last_challenged_at");


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id");


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_client_id_key" UNIQUE ("client_id");


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_pkey" PRIMARY KEY ("id");


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE ("entity_id");


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY ("id");


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY ("id");


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_providers"
    ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY ("id");


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: admin_keys admin_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."admin_keys"
    ADD CONSTRAINT "admin_keys_pkey" PRIMARY KEY ("code");


--
-- Name: availability_slots availability_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."availability_slots"
    ADD CONSTRAINT "availability_slots_pkey" PRIMARY KEY ("id");


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_pkey" PRIMARY KEY ("id");


--
-- Name: certificates certificates_user_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_user_id_course_id_key" UNIQUE ("user_id", "course_id");


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_pkey" PRIMARY KEY ("code");


--
-- Name: course_enrollments course_enrollments_course_id_student_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_enrollments"
    ADD CONSTRAINT "course_enrollments_course_id_student_id_key" UNIQUE ("course_id", "student_id");


--
-- Name: course_enrollments course_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_enrollments"
    ADD CONSTRAINT "course_enrollments_pkey" PRIMARY KEY ("id");


--
-- Name: course_modules course_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_modules"
    ADD CONSTRAINT "course_modules_pkey" PRIMARY KEY ("id");


--
-- Name: course_quizzes course_quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_quizzes"
    ADD CONSTRAINT "course_quizzes_pkey" PRIMARY KEY ("id");


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("id");


--
-- Name: courses courses_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_slug_key" UNIQUE ("slug");


--
-- Name: lesson_media lesson_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."lesson_media"
    ADD CONSTRAINT "lesson_media_pkey" PRIMARY KEY ("id");


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."lessons"
    ADD CONSTRAINT "lessons_pkey" PRIMARY KEY ("id");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("id");


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_key" UNIQUE ("user_id");


--
-- Name: public_teacher_info public_teacher_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."public_teacher_info"
    ADD CONSTRAINT "public_teacher_info_pkey" PRIMARY KEY ("id");


--
-- Name: public_teacher_info public_teacher_info_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."public_teacher_info"
    ADD CONSTRAINT "public_teacher_info_user_id_key" UNIQUE ("user_id");


--
-- Name: quiz_attempts quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_attempts"
    ADD CONSTRAINT "quiz_attempts_pkey" PRIMARY KEY ("id");


--
-- Name: quiz_questions quiz_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_questions"
    ADD CONSTRAINT "quiz_questions_pkey" PRIMARY KEY ("id");


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."services"
    ADD CONSTRAINT "services_pkey" PRIMARY KEY ("id");


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscription_plans"
    ADD CONSTRAINT "subscription_plans_pkey" PRIMARY KEY ("id");


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id");


--
-- Name: tarot_readings tarot_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tarot_readings"
    ADD CONSTRAINT "tarot_readings_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_directory teacher_directory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_pkey" PRIMARY KEY ("id");


--
-- Name: teacher_directory teacher_directory_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_user_id_key" UNIQUE ("user_id");


--
-- Name: teacher_permissions teacher_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_pkey" PRIMARY KEY ("user_id");


--
-- Name: teacher_requests teacher_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_pkey" PRIMARY KEY ("id");


--
-- Name: user_certifications user_certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_certifications"
    ADD CONSTRAINT "user_certifications_pkey" PRIMARY KEY ("user_id", "area");


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_role_key" UNIQUE ("user_id", "role");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."subscription"
    ADD CONSTRAINT "pk_subscription" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."buckets_analytics"
    ADD CONSTRAINT "buckets_analytics_pkey" PRIMARY KEY ("id");


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_pkey" PRIMARY KEY ("bucket_id", "level", "name");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY ("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_idempotency_key_key; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_idempotency_key_key" UNIQUE ("idempotency_key");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."seed_files"
    ADD CONSTRAINT "seed_files_pkey" PRIMARY KEY ("path");


--
-- Name: certificates_user_title_key; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "certificates_user_title_key" ON "app"."certificates" USING "btree" ("user_id", "title");


--
-- Name: idx_certificates_user_title; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "idx_certificates_user_title" ON "app"."certificates" USING "btree" ("user_id", "title");


--
-- Name: idx_courses_branch; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_courses_branch" ON "app"."courses" USING "btree" ("branch");


--
-- Name: idx_courses_created_by; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_courses_created_by" ON "app"."courses" USING "btree" ("created_by");


--
-- Name: idx_courses_is_free_intro; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_courses_is_free_intro" ON "app"."courses" USING "btree" ("is_free_intro");


--
-- Name: idx_drip_plans_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_drip_plans_course" ON "app"."drip_plans" USING "btree" ("course_id");


--
-- Name: idx_drip_rules_plan; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_drip_rules_plan" ON "app"."drip_rules" USING "btree" ("plan_id");


--
-- Name: idx_editor_styles_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_editor_styles_course" ON "app"."editor_styles" USING "btree" ("course_id");


--
-- Name: idx_enroll_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_enroll_course" ON "app"."enrollments" USING "btree" ("course_id");


--
-- Name: idx_enroll_user; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_enroll_user" ON "app"."enrollments" USING "btree" ("user_id");


--
-- Name: idx_guest_claim_email; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_guest_claim_email" ON "app"."guest_claim_tokens" USING "btree" ("buyer_email");


--
-- Name: idx_guest_claim_purchase; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_guest_claim_purchase" ON "app"."guest_claim_tokens" USING "btree" ("purchase_id");


--
-- Name: idx_lessons_module; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_lessons_module" ON "app"."lessons" USING "btree" ("module_id");


--
-- Name: idx_magic_links_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_magic_links_course" ON "app"."magic_links" USING "btree" ("course_id");


--
-- Name: idx_media_lesson; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_media_lesson" ON "app"."lesson_media" USING "btree" ("lesson_id");


--
-- Name: idx_meditations_teacher; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_meditations_teacher" ON "app"."meditations" USING "btree" ("teacher_id");


--
-- Name: idx_messages_channel; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_messages_channel" ON "app"."messages" USING "btree" ("channel");


--
-- Name: idx_messages_sender; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_messages_sender" ON "app"."messages" USING "btree" ("sender_id");


--
-- Name: idx_modules_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_modules_course" ON "app"."modules" USING "btree" ("course_id");


--
-- Name: idx_notif_jobs_due; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_notif_jobs_due" ON "app"."notification_jobs" USING "btree" ("status", "scheduled_at");


--
-- Name: idx_orders_service; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_orders_service" ON "app"."orders" USING "btree" ("service_id");


--
-- Name: idx_orders_status; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_orders_status" ON "app"."orders" USING "btree" ("status");


--
-- Name: idx_orders_user; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_orders_user" ON "app"."orders" USING "btree" ("user_id");


--
-- Name: idx_profiles_role; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_profiles_role" ON "app"."profiles" USING "btree" ("role");


--
-- Name: idx_purchases_course; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_purchases_course" ON "app"."purchases" USING "btree" ("course_id");


--
-- Name: idx_purchases_email; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_purchases_email" ON "app"."purchases" USING "btree" ("buyer_email");


--
-- Name: idx_purchases_order; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "idx_purchases_order" ON "app"."purchases" USING "btree" ("order_id") WHERE ("order_id" IS NOT NULL);


--
-- Name: idx_purchases_user; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_purchases_user" ON "app"."purchases" USING "btree" ("user_id");


--
-- Name: idx_services_provider; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_services_provider" ON "app"."services" USING "btree" ("provider_id");


--
-- Name: idx_slots_teacher; Type: INDEX; Schema: app; Owner: -
--

CREATE INDEX "idx_slots_teacher" ON "app"."teacher_slots" USING "btree" ("teacher_id");


--
-- Name: uq_drip_rules; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "uq_drip_rules" ON "app"."drip_rules" USING "btree" ("plan_id", "module_id", COALESCE("page_id", '00000000-0000-0000-0000-000000000000'::"uuid"));


--
-- Name: uq_notification_jobs_natural; Type: INDEX; Schema: app; Owner: -
--

CREATE UNIQUE INDEX "uq_notification_jobs_natural" ON "app"."notification_jobs" USING "btree" ("user_id", "course_id", "module_id", COALESCE("page_id", '00000000-0000-0000-0000-000000000000'::"uuid"), "scheduled_at");


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" USING "btree" ("user_id", "created_at");


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "flow_state_created_at_idx" ON "auth"."flow_state" USING "btree" ("created_at" DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "identities_email_idx" ON "auth"."identities" USING "btree" ("email" "text_pattern_ops");


--
-- Name: INDEX "identities_email_idx"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX "auth"."identities_email_idx" IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "idx_auth_code" ON "auth"."flow_state" USING "btree" ("auth_code");


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" USING "btree" ("user_id", "authentication_method");


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "mfa_challenge_created_at_idx" ON "auth"."mfa_challenges" USING "btree" ("created_at" DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" USING "btree" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM "friendly_name") <> ''::"text");


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "mfa_factors_user_id_idx" ON "auth"."mfa_factors" USING "btree" ("user_id");


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "oauth_clients_client_id_idx" ON "auth"."oauth_clients" USING "btree" ("client_id");


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "oauth_clients_deleted_at_idx" ON "auth"."oauth_clients" USING "btree" ("deleted_at");


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "one_time_tokens_relates_to_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("relates_to");


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "one_time_tokens_token_hash_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("token_hash");


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "one_time_tokens_user_id_token_type_key" ON "auth"."one_time_tokens" USING "btree" ("user_id", "token_type");


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" USING "btree" ("session_id", "revoked");


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_updated_at_idx" ON "auth"."refresh_tokens" USING "btree" ("updated_at" DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" USING "btree" ("sso_provider_id");


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_created_at_idx" ON "auth"."saml_relay_states" USING "btree" ("created_at" DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" USING "btree" ("for_email");


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" USING "btree" ("sso_provider_id");


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sessions_not_after_idx" ON "auth"."sessions" USING "btree" ("not_after" DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" USING "btree" ("user_id");


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" USING "btree" ("lower"("domain"));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" USING "btree" ("sso_provider_id");


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" USING "btree" ("lower"("resource_id"));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sso_providers_resource_id_pattern_idx" ON "auth"."sso_providers" USING "btree" ("resource_id" "text_pattern_ops");


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "unique_phone_factor_per_user" ON "auth"."mfa_factors" USING "btree" ("user_id", "phone");


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" USING "btree" ("user_id", "created_at");


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" USING "btree" ("email") WHERE ("is_sso_user" = false);


--
-- Name: INDEX "users_email_partial_key"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX "auth"."users_email_partial_key" IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_is_anonymous_idx" ON "auth"."users" USING "btree" ("is_anonymous");


--
-- Name: idx_attempts_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_attempts_user" ON "public"."quiz_attempts" USING "btree" ("user_id", "quiz_id");


--
-- Name: idx_availability_slots_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_availability_slots_teacher_id" ON "public"."availability_slots" USING "btree" ("teacher_id");


--
-- Name: idx_availability_slots_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_availability_slots_time" ON "public"."availability_slots" USING "btree" ("start_time", "end_time");


--
-- Name: idx_bookings_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_bookings_student_id" ON "public"."bookings" USING "btree" ("student_id");


--
-- Name: idx_bookings_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_bookings_teacher_id" ON "public"."bookings" USING "btree" ("teacher_id");


--
-- Name: idx_certificates_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_certificates_course" ON "public"."certificates" USING "btree" ("course_id");


--
-- Name: idx_certificates_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_certificates_user" ON "public"."certificates" USING "btree" ("user_id");


--
-- Name: idx_coupons_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_coupons_enabled" ON "public"."coupons" USING "btree" ("is_enabled");


--
-- Name: idx_coupons_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_coupons_expires" ON "public"."coupons" USING "btree" ("expires_at");


--
-- Name: idx_course_enrollments_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_enrollments_course_id" ON "public"."course_enrollments" USING "btree" ("course_id");


--
-- Name: idx_course_enrollments_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_enrollments_student_id" ON "public"."course_enrollments" USING "btree" ("student_id");


--
-- Name: idx_course_modules_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_modules_course" ON "public"."course_modules" USING "btree" ("course_id");


--
-- Name: idx_course_quizzes_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_course_quizzes_course" ON "public"."course_quizzes" USING "btree" ("course_id");


--
-- Name: idx_courses_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_courses_published" ON "public"."courses" USING "btree" ("is_published");


--
-- Name: idx_courses_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_courses_teacher_id" ON "public"."courses" USING "btree" ("teacher_id");


--
-- Name: idx_messages_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_messages_course_id" ON "public"."messages" USING "btree" ("course_id");


--
-- Name: idx_messages_sender_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_messages_sender_recipient" ON "public"."messages" USING "btree" ("sender_id", "recipient_id");


--
-- Name: idx_notifications_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_notifications_unread" ON "public"."notifications" USING "btree" ("user_id", "is_read") WHERE ("is_read" = false);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_notifications_user_id" ON "public"."notifications" USING "btree" ("user_id");


--
-- Name: idx_public_teacher_info_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_public_teacher_info_user_id" ON "public"."public_teacher_info" USING "btree" ("user_id");


--
-- Name: idx_quiz_attempts_quiz; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_quiz_attempts_quiz" ON "public"."quiz_attempts" USING "btree" ("quiz_id");


--
-- Name: idx_quiz_attempts_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_quiz_attempts_user" ON "public"."quiz_attempts" USING "btree" ("user_id");


--
-- Name: idx_quiz_questions_quiz; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_quiz_questions_quiz" ON "public"."quiz_questions" USING "btree" ("quiz_id");


--
-- Name: idx_subs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_subs_status" ON "public"."subscriptions" USING "btree" ("status");


--
-- Name: idx_subs_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_subs_user" ON "public"."subscriptions" USING "btree" ("user_id");


--
-- Name: idx_tarot_readings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_tarot_readings_status" ON "public"."tarot_readings" USING "btree" ("status");


--
-- Name: idx_tarot_readings_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_tarot_readings_student_id" ON "public"."tarot_readings" USING "btree" ("student_id");


--
-- Name: idx_tarot_readings_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_tarot_readings_teacher_id" ON "public"."tarot_readings" USING "btree" ("teacher_id");


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX "ix_realtime_subscription_entity" ON "realtime"."subscription" USING "btree" ("entity");


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX "messages_inserted_at_topic_index" ON ONLY "realtime"."messages" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX "subscription_subscription_id_entity_filters_key" ON "realtime"."subscription" USING "btree" ("subscription_id", "entity", "filters");


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_multipart_uploads_list" ON "storage"."s3_multipart_uploads" USING "btree" ("bucket_id", "key", "created_at");


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "idx_name_bucket_level_unique" ON "storage"."objects" USING "btree" ("name" COLLATE "C", "bucket_id", "level");


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_objects_bucket_id_name" ON "storage"."objects" USING "btree" ("bucket_id", "name" COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_objects_lower_name" ON "storage"."objects" USING "btree" (("path_tokens"["level"]), "lower"("name") "text_pattern_ops", "bucket_id", "level");


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_prefixes_lower_name" ON "storage"."prefixes" USING "btree" ("bucket_id", "level", (("string_to_array"("name", '/'::"text"))["level"]), "lower"("name") "text_pattern_ops");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "objects_bucket_id_level_idx" ON "storage"."objects" USING "btree" ("bucket_id", "level", "name" COLLATE "C");


--
-- Name: bookings trg_bookings_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_bookings_touch" BEFORE UPDATE ON "app"."bookings" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: certificates trg_certificates_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_certificates_touch" BEFORE UPDATE ON "app"."certificates" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: certifications trg_certifications_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_certifications_touch" BEFORE UPDATE ON "app"."certifications" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: courses trg_courses_set_owner; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_courses_set_owner" BEFORE INSERT ON "app"."courses" FOR EACH ROW EXECUTE FUNCTION "app"."_courses_set_owner"();


--
-- Name: courses trg_courses_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_courses_touch" BEFORE UPDATE ON "app"."courses" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: drip_plans trg_drip_plans_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_drip_plans_touch" BEFORE UPDATE ON "app"."drip_plans" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: drip_rules trg_drip_rules_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_drip_rules_touch" BEFORE UPDATE ON "app"."drip_rules" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: editor_styles trg_editor_styles_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_editor_styles_touch" BEFORE UPDATE ON "app"."editor_styles" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: enrollments trg_enroll_materialize; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_enroll_materialize" AFTER INSERT ON "app"."enrollments" FOR EACH ROW EXECUTE FUNCTION "app"."enrollments_materialize_trg_fn"();


--
-- Name: events trg_events_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_events_touch" BEFORE UPDATE ON "app"."events" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: lessons trg_lessons_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_lessons_touch" BEFORE UPDATE ON "app"."lessons" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: magic_links trg_magic_links_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_magic_links_touch" BEFORE UPDATE ON "app"."magic_links" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: meditations trg_meditations_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_meditations_touch" BEFORE UPDATE ON "app"."meditations" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: memberships trg_memberships_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_memberships_touch" BEFORE UPDATE ON "app"."memberships" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: messages trg_messages_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_messages_touch" BEFORE UPDATE ON "app"."messages" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: modules trg_modules_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_modules_touch" BEFORE UPDATE ON "app"."modules" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: notification_jobs trg_notification_jobs_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_notification_jobs_touch" BEFORE UPDATE ON "app"."notification_jobs" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: notification_templates trg_notification_templates_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_notification_templates_touch" BEFORE UPDATE ON "app"."notification_templates" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: orders trg_orders_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_orders_touch" BEFORE UPDATE ON "app"."orders" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: pro_progress trg_pro_progress_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_pro_progress_touch" BEFORE UPDATE ON "app"."pro_progress" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: pro_requirements trg_pro_requirements_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_pro_requirements_touch" BEFORE UPDATE ON "app"."pro_requirements" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: profiles trg_profiles_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_profiles_touch" BEFORE UPDATE ON "app"."profiles" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: services trg_services_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_services_touch" BEFORE UPDATE ON "app"."services" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: tarot_requests trg_tarot_requests_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_tarot_requests_touch" BEFORE UPDATE ON "app"."tarot_requests" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: tarot_requests trg_tarot_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_tarot_touch" BEFORE UPDATE ON "app"."tarot_requests" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: teacher_approvals trg_teacher_approvals_touch; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER "trg_teacher_approvals_touch" BEFORE UPDATE ON "app"."teacher_approvals" FOR EACH ROW EXECUTE FUNCTION "app"."touch_updated_at"();


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();


--
-- Name: user_roles on_teacher_role_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "on_teacher_role_created" AFTER INSERT ON "public"."user_roles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_teacher"();


--
-- Name: course_modules trg_course_modules_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_course_modules_created_by" BEFORE INSERT OR UPDATE ON "public"."course_modules" FOR EACH ROW EXECUTE FUNCTION "public"."_set_created_by"();


--
-- Name: course_modules trg_course_modules_set_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_course_modules_set_created_by" BEFORE INSERT OR UPDATE ON "public"."course_modules" FOR EACH ROW EXECUTE FUNCTION "public"."_set_created_by"();


--
-- Name: courses trg_courses_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_courses_created_by" BEFORE INSERT ON "public"."courses" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_by"();


--
-- Name: services trg_services_owner; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "trg_services_owner" BEFORE INSERT ON "public"."services" FOR EACH ROW EXECUTE FUNCTION "public"."set_owner"();


--
-- Name: availability_slots update_availability_slots_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_availability_slots_updated_at" BEFORE UPDATE ON "public"."availability_slots" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: bookings update_bookings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_bookings_updated_at" BEFORE UPDATE ON "public"."bookings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: course_enrollments update_course_enrollments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_course_enrollments_updated_at" BEFORE UPDATE ON "public"."course_enrollments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: courses update_courses_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_courses_updated_at" BEFORE UPDATE ON "public"."courses" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: lessons update_lessons_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_lessons_updated_at" BEFORE UPDATE ON "public"."lessons" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: messages update_messages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_messages_updated_at" BEFORE UPDATE ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: modules update_modules_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_modules_updated_at" BEFORE UPDATE ON "public"."modules" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: public_teacher_info update_public_teacher_info_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_public_teacher_info_updated_at" BEFORE UPDATE ON "public"."public_teacher_info" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: tarot_readings update_tarot_readings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_tarot_readings_updated_at" BEFORE UPDATE ON "public"."tarot_readings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: teacher_directory update_teacher_directory_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_teacher_directory_updated_at" BEFORE UPDATE ON "public"."teacher_directory" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: teacher_requests update_teacher_requests_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_teacher_requests_updated_at" BEFORE UPDATE ON "public"."teacher_requests" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER "tr_check_filters" BEFORE INSERT OR UPDATE ON "realtime"."subscription" FOR EACH ROW EXECUTE FUNCTION "realtime"."subscription_check_filters"();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "enforce_bucket_name_length_trigger" BEFORE INSERT OR UPDATE OF "name" ON "storage"."buckets" FOR EACH ROW EXECUTE FUNCTION "storage"."enforce_bucket_name_length"();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "objects_delete_delete_prefix" AFTER DELETE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "objects_insert_create_prefix" BEFORE INSERT ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."objects_insert_prefix_trigger"();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "objects_update_create_prefix" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW WHEN ((("new"."name" <> "old"."name") OR ("new"."bucket_id" <> "old"."bucket_id"))) EXECUTE FUNCTION "storage"."objects_update_prefix_trigger"();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "prefixes_create_hierarchy" BEFORE INSERT ON "storage"."prefixes" FOR EACH ROW WHEN (("pg_trigger_depth"() < 1)) EXECUTE FUNCTION "storage"."prefixes_insert_trigger"();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "prefixes_delete_hierarchy" AFTER DELETE ON "storage"."prefixes" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();


--
-- Name: bookings bookings_order_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "app"."orders"("id") ON DELETE SET NULL;


--
-- Name: bookings bookings_slot_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_slot_id_fkey" FOREIGN KEY ("slot_id") REFERENCES "app"."teacher_slots"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."bookings"
    ADD CONSTRAINT "bookings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: certificates certificates_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certificates"
    ADD CONSTRAINT "certificates_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: certifications certifications_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: certifications certifications_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."certifications"
    ADD CONSTRAINT "certifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: courses courses_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."courses"
    ADD CONSTRAINT "courses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: drip_plans drip_plans_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_plans"
    ADD CONSTRAINT "drip_plans_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: drip_plans drip_plans_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_plans"
    ADD CONSTRAINT "drip_plans_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: drip_rules drip_rules_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: drip_rules drip_rules_module_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "app"."modules"("id") ON DELETE CASCADE;


--
-- Name: drip_rules drip_rules_notify_template_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_notify_template_id_fkey" FOREIGN KEY ("notify_template_id") REFERENCES "app"."notification_templates"("id") ON DELETE SET NULL;


--
-- Name: drip_rules drip_rules_page_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_page_id_fkey" FOREIGN KEY ("page_id") REFERENCES "app"."lessons"("id") ON DELETE SET NULL;


--
-- Name: drip_rules drip_rules_plan_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."drip_rules"
    ADD CONSTRAINT "drip_rules_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "app"."drip_plans"("id") ON DELETE CASCADE;


--
-- Name: editor_styles editor_styles_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."editor_styles"
    ADD CONSTRAINT "editor_styles_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: editor_styles editor_styles_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."editor_styles"
    ADD CONSTRAINT "editor_styles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: enrollments enrollments_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: enrollments enrollments_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."enrollments"
    ADD CONSTRAINT "enrollments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: events events_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."events"
    ADD CONSTRAINT "events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: orders fk_orders_service_id; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "fk_orders_service_id" FOREIGN KEY ("service_id") REFERENCES "app"."services"("id") ON DELETE SET NULL;


--
-- Name: guest_claim_tokens guest_claim_tokens_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."guest_claim_tokens"
    ADD CONSTRAINT "guest_claim_tokens_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: guest_claim_tokens guest_claim_tokens_purchase_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."guest_claim_tokens"
    ADD CONSTRAINT "guest_claim_tokens_purchase_id_fkey" FOREIGN KEY ("purchase_id") REFERENCES "app"."purchases"("id") ON DELETE CASCADE;


--
-- Name: lesson_media lesson_media_lesson_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lesson_media"
    ADD CONSTRAINT "lesson_media_lesson_id_fkey" FOREIGN KEY ("lesson_id") REFERENCES "app"."lessons"("id") ON DELETE CASCADE;


--
-- Name: lessons lessons_module_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."lessons"
    ADD CONSTRAINT "lessons_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "app"."modules"("id") ON DELETE CASCADE;


--
-- Name: magic_links magic_links_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: magic_links magic_links_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: magic_links magic_links_style_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."magic_links"
    ADD CONSTRAINT "magic_links_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "app"."editor_styles"("id") ON DELETE SET NULL;


--
-- Name: meditations meditations_teacher_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."meditations"
    ADD CONSTRAINT "meditations_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."memberships"
    ADD CONSTRAINT "memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: modules modules_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."modules"
    ADD CONSTRAINT "modules_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_module_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "app"."modules"("id") ON DELETE CASCADE;


--
-- Name: notification_jobs notification_jobs_page_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_page_id_fkey" FOREIGN KEY ("page_id") REFERENCES "app"."lessons"("id") ON DELETE SET NULL;


--
-- Name: notification_jobs notification_jobs_template_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "app"."notification_templates"("id") ON DELETE SET NULL;


--
-- Name: notification_jobs notification_jobs_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_jobs"
    ADD CONSTRAINT "notification_jobs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: notification_templates notification_templates_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_templates"
    ADD CONSTRAINT "notification_templates_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: notification_templates notification_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."notification_templates"
    ADD CONSTRAINT "notification_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: orders orders_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "orders_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE SET NULL;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."orders"
    ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: pro_progress pro_progress_requirement_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_progress"
    ADD CONSTRAINT "pro_progress_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "app"."pro_requirements"("id") ON DELETE CASCADE;


--
-- Name: pro_progress pro_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."pro_progress"
    ADD CONSTRAINT "pro_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: purchases purchases_course_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "app"."courses"("id") ON DELETE CASCADE;


--
-- Name: purchases purchases_order_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "app"."orders"("id") ON DELETE SET NULL;


--
-- Name: purchases purchases_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."purchases"
    ADD CONSTRAINT "purchases_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: services services_provider_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."services"
    ADD CONSTRAINT "services_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: tarot_requests tarot_requests_order_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "app"."orders"("id") ON DELETE SET NULL;


--
-- Name: tarot_requests tarot_requests_reader_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_reader_id_fkey" FOREIGN KEY ("reader_id") REFERENCES "app"."profiles"("user_id") ON DELETE SET NULL;


--
-- Name: tarot_requests tarot_requests_requester_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."tarot_requests"
    ADD CONSTRAINT "tarot_requests_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_approvals teacher_approvals_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_approvals"
    ADD CONSTRAINT "teacher_approvals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_directory teacher_directory_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_directory"
    ADD CONSTRAINT "teacher_directory_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_permissions teacher_permissions_profile_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_requests teacher_requests_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "app"."profiles"("user_id");


--
-- Name: teacher_requests teacher_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_requests"
    ADD CONSTRAINT "teacher_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: teacher_slots teacher_slots_teacher_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY "app"."teacher_slots"
    ADD CONSTRAINT "teacher_slots_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "app"."profiles"("user_id") ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors"("id") ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: admin_keys admin_keys_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."admin_keys"
    ADD CONSTRAINT "admin_keys_issued_by_fkey" FOREIGN KEY ("issued_by") REFERENCES "auth"."users"("id");


--
-- Name: admin_keys admin_keys_redeemed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."admin_keys"
    ADD CONSTRAINT "admin_keys_redeemed_by_fkey" FOREIGN KEY ("redeemed_by") REFERENCES "auth"."users"("id");


--
-- Name: availability_slots availability_slots_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."availability_slots"
    ADD CONSTRAINT "availability_slots_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_slot_id_fkey" FOREIGN KEY ("slot_id") REFERENCES "public"."availability_slots"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: bookings bookings_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: certificates certificates_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: certificates certificates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."certificates"
    ADD CONSTRAINT "certificates_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: coupons coupons_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_issued_by_fkey" FOREIGN KEY ("issued_by") REFERENCES "auth"."users"("id");


--
-- Name: coupons coupons_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("id") ON DELETE SET NULL;


--
-- Name: course_modules course_modules_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_modules"
    ADD CONSTRAINT "course_modules_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: course_modules course_modules_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_modules"
    ADD CONSTRAINT "course_modules_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: course_quizzes course_quizzes_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_quizzes"
    ADD CONSTRAINT "course_quizzes_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: course_quizzes course_quizzes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."course_quizzes"
    ADD CONSTRAINT "course_quizzes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: courses courses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;


--
-- Name: courses courses_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: messages messages_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;


--
-- Name: messages messages_parent_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_parent_message_id_fkey" FOREIGN KEY ("parent_message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;


--
-- Name: messages messages_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: quiz_attempts quiz_attempts_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_attempts"
    ADD CONSTRAINT "quiz_attempts_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "public"."course_quizzes"("id") ON DELETE CASCADE;


--
-- Name: quiz_attempts quiz_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_attempts"
    ADD CONSTRAINT "quiz_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: quiz_questions quiz_questions_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."quiz_questions"
    ADD CONSTRAINT "quiz_questions_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "public"."course_quizzes"("id") ON DELETE CASCADE;


--
-- Name: services services_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."services"
    ADD CONSTRAINT "services_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("id") ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: tarot_readings tarot_readings_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tarot_readings"
    ADD CONSTRAINT "tarot_readings_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: tarot_readings tarot_readings_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tarot_readings"
    ADD CONSTRAINT "tarot_readings_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: teacher_permissions teacher_permissions_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_granted_by_fkey" FOREIGN KEY ("granted_by") REFERENCES "auth"."users"("id");


--
-- Name: teacher_permissions teacher_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."teacher_permissions"
    ADD CONSTRAINT "teacher_permissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: user_certifications user_certifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_certifications"
    ADD CONSTRAINT "user_certifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads"("id") ON DELETE CASCADE;


--
-- Name: app_config; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."app_config" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."bookings" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings bookings_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_delete" ON "app"."bookings" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: bookings bookings_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_insert" ON "app"."bookings" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: bookings bookings_owner_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_owner_insert" ON "app"."bookings" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: bookings bookings_owner_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_owner_update" ON "app"."bookings" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: bookings bookings_read_own_or_teacher; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_read_own_or_teacher" ON "app"."bookings" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: bookings bookings_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_select" ON "app"."bookings" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: bookings bookings_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "bookings_update" ON "app"."bookings" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: certifications cert_read_own_or_teacher; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "cert_read_own_or_teacher" ON "app"."certifications" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: certifications cert_teacher_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "cert_teacher_insert" ON "app"."certifications" FOR INSERT WITH CHECK ("app"."is_teacher"());


--
-- Name: certificates; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."certificates" ENABLE ROW LEVEL SECURITY;

--
-- Name: certificates certificates_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_delete" ON "app"."certificates" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: certificates certificates_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_insert" ON "app"."certificates" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: certificates certificates_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_select" ON "app"."certificates" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: certificates certificates_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certificates_update" ON "app"."certificates" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: certifications; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."certifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: certifications certifications_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_delete" ON "app"."certifications" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: certifications certifications_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_insert" ON "app"."certifications" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "certifications"."course_id") AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: certifications certifications_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_select" ON "app"."certifications" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "certifications"."course_id") AND (COALESCE("c"."is_published", false) = true))))));


--
-- Name: certifications certifications_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "certifications_update" ON "app"."certifications" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: app_config cfg_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "cfg_public_read" ON "app"."app_config" FOR SELECT USING (true);


--
-- Name: courses; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."courses" ENABLE ROW LEVEL SECURITY;

--
-- Name: courses courses_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_delete" ON "app"."courses" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_free_intro_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_free_intro_read" ON "app"."courses" FOR SELECT TO "authenticated", "anon" USING (("is_free_intro" = true));


--
-- Name: courses courses_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_insert" ON "app"."courses" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_owner_manage; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_owner_manage" ON "app"."courses" TO "authenticated" USING ((("created_by" = "auth"."uid"()) OR "app"."is_admin"())) WITH CHECK ((("created_by" = "auth"."uid"()) OR "app"."is_admin"()));


--
-- Name: courses courses_owner_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_owner_read" ON "app"."courses" FOR SELECT TO "authenticated" USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_owner_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_owner_update" ON "app"."courses" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_public_read" ON "app"."courses" FOR SELECT USING ((("is_published" = true) OR "app"."is_teacher"()));


--
-- Name: courses courses_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_select" ON "app"."courses" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_select_or_publish; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_select_or_publish" ON "app"."courses" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (COALESCE("is_published", false) = true)));


--
-- Name: courses courses_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_teacher_write" ON "app"."courses" USING (("app"."is_teacher"() AND (("created_by" = "auth"."uid"()) OR "app"."is_admin"()))) WITH CHECK (("app"."is_teacher"() AND (("created_by" = "auth"."uid"()) OR "app"."is_admin"())));


--
-- Name: courses courses_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_update" ON "app"."courses" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: courses courses_write_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "courses_write_own" ON "app"."courses" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: drip_plans; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."drip_plans" ENABLE ROW LEVEL SECURITY;

--
-- Name: drip_plans drip_plans_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_delete" ON "app"."drip_plans" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: drip_plans drip_plans_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_insert" ON "app"."drip_plans" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: drip_plans drip_plans_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_select" ON "app"."drip_plans" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: drip_plans drip_plans_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_plans_update" ON "app"."drip_plans" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: drip_rules; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."drip_rules" ENABLE ROW LEVEL SECURITY;

--
-- Name: drip_rules drip_rules_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_delete" ON "app"."drip_rules" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: drip_rules drip_rules_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_insert" ON "app"."drip_rules" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: drip_rules drip_rules_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_select" ON "app"."drip_rules" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: drip_rules drip_rules_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "drip_rules_update" ON "app"."drip_rules" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "app"."drip_plans" "p"
  WHERE (("p"."id" = "drip_rules"."plan_id") AND "app"."owns_course"("p"."course_id")))));


--
-- Name: editor_styles; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."editor_styles" ENABLE ROW LEVEL SECURITY;

--
-- Name: editor_styles editor_styles_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_delete" ON "app"."editor_styles" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: editor_styles editor_styles_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_insert" ON "app"."editor_styles" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: editor_styles editor_styles_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_select" ON "app"."editor_styles" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: editor_styles editor_styles_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "editor_styles_update" ON "app"."editor_styles" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: enrollments enroll_insert_self; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "enroll_insert_self" ON "app"."enrollments" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: enrollments enroll_read_own_or_teacher; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "enroll_read_own_or_teacher" ON "app"."enrollments" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: enrollments; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."enrollments" ENABLE ROW LEVEL SECURITY;

--
-- Name: events; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."events" ENABLE ROW LEVEL SECURITY;

--
-- Name: events events_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_delete" ON "app"."events" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: events events_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_insert" ON "app"."events" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: events events_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_public_read" ON "app"."events" FOR SELECT USING ((("is_published" = true) OR "app"."is_teacher"()));


--
-- Name: events events_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_select" ON "app"."events" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: events events_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_teacher_write" ON "app"."events" USING ("app"."is_teacher"()) WITH CHECK ("app"."is_teacher"());


--
-- Name: events events_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "events_update" ON "app"."events" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: guest_claim_tokens; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."guest_claim_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_media; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."lesson_media" ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."lessons" ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons lessons_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_delete" ON "app"."lessons" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: lessons lessons_free_intro_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_free_intro_read" ON "app"."lessons" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."is_free_intro" = true)))));


--
-- Name: lessons lessons_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_insert" ON "app"."lessons" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: lessons lessons_owner_manage; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_owner_manage" ON "app"."lessons" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))));


--
-- Name: lessons lessons_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_read" ON "app"."lessons" FOR SELECT USING (("app"."is_teacher"() OR (EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."is_published" = true) AND (("lessons"."is_intro" = true) OR "app"."can_access_course"("auth"."uid"(), "c"."id")))))));


--
-- Name: lessons lessons_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_select" ON "app"."lessons" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: lessons lessons_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_teacher_write" ON "app"."lessons" USING (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))))) WITH CHECK (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM ("app"."modules" "m"
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))));


--
-- Name: lessons lessons_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "lessons_update" ON "app"."lessons" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: magic_links; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."magic_links" ENABLE ROW LEVEL SECURITY;

--
-- Name: magic_links magic_links_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_delete" ON "app"."magic_links" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: magic_links magic_links_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_insert" ON "app"."magic_links" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: magic_links magic_links_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_select" ON "app"."magic_links" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: magic_links magic_links_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "magic_links_update" ON "app"."magic_links" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: meditations med_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "med_read" ON "app"."meditations" FOR SELECT USING ((("is_public" = true) OR ("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: meditations med_write_owner; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "med_write_owner" ON "app"."meditations" USING ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: lesson_media media_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "media_read" ON "app"."lesson_media" FOR SELECT USING (("app"."is_teacher"() OR (EXISTS ( SELECT 1
   FROM (("app"."lessons" "l"
     JOIN "app"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND ("c"."is_published" = true) AND (("l"."is_intro" = true) OR "app"."can_access_course"("auth"."uid"(), "c"."id")))))));


--
-- Name: lesson_media media_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "media_teacher_write" ON "app"."lesson_media" USING (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM (("app"."lessons" "l"
     JOIN "app"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))))) WITH CHECK (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM (("app"."lessons" "l"
     JOIN "app"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "app"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))));


--
-- Name: meditations; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."meditations" ENABLE ROW LEVEL SECURITY;

--
-- Name: meditations meditations_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_delete" ON "app"."meditations" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: meditations meditations_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_insert" ON "app"."meditations" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: meditations meditations_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_select" ON "app"."meditations" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: meditations meditations_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "meditations_update" ON "app"."meditations" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: memberships memb_admin_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memb_admin_write" ON "app"."memberships" USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: memberships memb_read_own_or_admin; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memb_read_own_or_admin" ON "app"."memberships" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_admin"()));


--
-- Name: memberships; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."memberships" ENABLE ROW LEVEL SECURITY;

--
-- Name: memberships memberships_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_delete" ON "app"."memberships" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: memberships memberships_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_insert" ON "app"."memberships" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: memberships memberships_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_select" ON "app"."memberships" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: memberships memberships_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "memberships_update" ON "app"."memberships" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: messages; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages messages_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_delete" ON "app"."messages" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: messages messages_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_insert" ON "app"."messages" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: messages messages_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_read" ON "app"."messages" FOR SELECT USING ("app"."can_read_channel"("channel"));


--
-- Name: messages messages_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_select" ON "app"."messages" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: messages messages_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "messages_update" ON "app"."messages" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: modules; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."modules" ENABLE ROW LEVEL SECURITY;

--
-- Name: modules modules_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_delete" ON "app"."modules" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: modules modules_free_intro_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_free_intro_read" ON "app"."modules" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND ("c"."is_free_intro" = true)))));


--
-- Name: modules modules_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_insert" ON "app"."modules" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: modules modules_owner_manage; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_owner_manage" ON "app"."modules" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))));


--
-- Name: modules modules_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_read" ON "app"."modules" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND ("c"."is_published" OR "app"."is_teacher"())))));


--
-- Name: modules modules_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_select" ON "app"."modules" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (COALESCE("c"."is_published", false) = true))))));


--
-- Name: modules modules_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_teacher_write" ON "app"."modules" USING (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"())))))) WITH CHECK (("app"."is_teacher"() AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "modules"."course_id") AND (("c"."created_by" = "auth"."uid"()) OR "app"."is_admin"()))))));


--
-- Name: modules modules_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "modules_update" ON "app"."modules" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: notification_jobs notif_jobs_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_delete" ON "app"."notification_jobs" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: notification_jobs notif_jobs_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_insert" ON "app"."notification_jobs" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: notification_jobs notif_jobs_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_select" ON "app"."notification_jobs" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."owns_course"("course_id")));


--
-- Name: notification_jobs notif_jobs_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_jobs_update" ON "app"."notification_jobs" FOR UPDATE USING ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_delete" ON "app"."notification_templates" FOR DELETE USING ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_insert" ON "app"."notification_templates" FOR INSERT WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_select" ON "app"."notification_templates" FOR SELECT USING ("app"."owns_course"("course_id"));


--
-- Name: notification_templates notif_tpl_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "notif_tpl_update" ON "app"."notification_templates" FOR UPDATE USING ("app"."owns_course"("course_id")) WITH CHECK ("app"."owns_course"("course_id"));


--
-- Name: notification_jobs; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."notification_jobs" ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_templates; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."notification_templates" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders orders_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_delete" ON "app"."orders" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: orders orders_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_insert" ON "app"."orders" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "orders"."course_id") AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: orders orders_insert_self; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_insert_self" ON "app"."orders" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: orders orders_read_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_read_own" ON "app"."orders" FOR SELECT USING (("user_id" = "auth"."uid"()));


--
-- Name: orders orders_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_select" ON "app"."orders" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE (("c"."id" = "orders"."course_id") AND (COALESCE("c"."is_published", false) = true))))));


--
-- Name: orders orders_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_update" ON "app"."orders" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: orders orders_update_service; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "orders_update_service" ON "app"."orders" FOR UPDATE USING ("app"."is_admin"());


--
-- Name: pro_progress; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."pro_progress" ENABLE ROW LEVEL SECURITY;

--
-- Name: pro_progress pro_progress_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_delete" ON "app"."pro_progress" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_progress pro_progress_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_insert" ON "app"."pro_progress" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: pro_progress pro_progress_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_select" ON "app"."pro_progress" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_progress pro_progress_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_progress_update" ON "app"."pro_progress" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."pro_requirements" ENABLE ROW LEVEL SECURITY;

--
-- Name: pro_requirements pro_requirements_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_delete" ON "app"."pro_requirements" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements pro_requirements_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_insert" ON "app"."pro_requirements" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements pro_requirements_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_select" ON "app"."pro_requirements" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: pro_requirements pro_requirements_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "pro_requirements_update" ON "app"."pro_requirements" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: profiles; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_admin_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_admin_update" ON "app"."profiles" FOR UPDATE USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: profiles profiles_insert_self; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_insert_self" ON "app"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: profiles profiles_read_own_or_admin; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_read_own_or_admin" ON "app"."profiles" FOR SELECT USING ((("auth"."uid"() = "user_id") OR "app"."is_teacher"()));


--
-- Name: profiles profiles_update_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "profiles_update_own" ON "app"."profiles" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: purchases; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."purchases" ENABLE ROW LEVEL SECURITY;

--
-- Name: purchases purchases_owner_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "purchases_owner_select" ON "app"."purchases" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: services; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."services" ENABLE ROW LEVEL SECURITY;

--
-- Name: services services_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_delete" ON "app"."services" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: services services_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_insert" ON "app"."services" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: services services_owner_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_owner_write" ON "app"."services" USING ((("provider_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("provider_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: services services_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_public_read" ON "app"."services" FOR SELECT USING ((("is_active" = true) OR "app"."is_teacher"()));


--
-- Name: services services_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_select" ON "app"."services" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: services services_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "services_update" ON "app"."services" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: teacher_slots slots_read_teacher_or_public_future; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "slots_read_teacher_or_public_future" ON "app"."teacher_slots" FOR SELECT USING (("app"."is_teacher"() OR (("is_booked" = false) AND ("starts_at" > "now"()))));


--
-- Name: teacher_slots slots_teacher_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "slots_teacher_write" ON "app"."teacher_slots" USING ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("teacher_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: tarot_requests tarot_insert_requester; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_insert_requester" ON "app"."tarot_requests" FOR INSERT WITH CHECK (("requester_id" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_read_parties; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_read_parties" ON "app"."tarot_requests" FOR SELECT USING ((("requester_id" = "auth"."uid"()) OR ("reader_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: tarot_requests; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."tarot_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: tarot_requests tarot_requests_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_delete" ON "app"."tarot_requests" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_requests_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_insert" ON "app"."tarot_requests" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_requests_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_select" ON "app"."tarot_requests" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_requests_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_requests_update" ON "app"."tarot_requests" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: tarot_requests tarot_update_parties; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tarot_update_parties" ON "app"."tarot_requests" FOR UPDATE USING ((("requester_id" = "auth"."uid"()) OR ("reader_id" = "auth"."uid"()) OR "app"."is_teacher"())) WITH CHECK ((("requester_id" = "auth"."uid"()) OR ("reader_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: teacher_directory tdir_admin_write; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tdir_admin_write" ON "app"."teacher_directory" USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: teacher_directory tdir_public_read; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tdir_public_read" ON "app"."teacher_directory" FOR SELECT USING (true);


--
-- Name: teacher_approvals; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_approvals" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_approvals teacher_approvals_delete; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_delete" ON "app"."teacher_approvals" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: teacher_approvals teacher_approvals_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_insert" ON "app"."teacher_approvals" FOR INSERT WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: teacher_approvals teacher_approvals_select; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_select" ON "app"."teacher_approvals" FOR SELECT USING (("created_by" = "auth"."uid"()));


--
-- Name: teacher_approvals teacher_approvals_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "teacher_approvals_update" ON "app"."teacher_approvals" FOR UPDATE USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: teacher_directory; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_directory" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_requests; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_slots; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE "app"."teacher_slots" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions tp_delete_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_delete_own" ON "app"."teacher_permissions" FOR DELETE TO "authenticated" USING (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_permissions tp_insert_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_insert_own" ON "app"."teacher_permissions" FOR INSERT TO "authenticated" WITH CHECK (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_permissions tp_select_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_select_own" ON "app"."teacher_permissions" FOR SELECT TO "authenticated" USING (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_permissions tp_update_own; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "tp_update_own" ON "app"."teacher_permissions" FOR UPDATE TO "authenticated" USING (("profile_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("profile_id" = ( SELECT "auth"."uid"() AS "uid")));


--
-- Name: teacher_requests treq_admin_update; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "treq_admin_update" ON "app"."teacher_requests" FOR UPDATE USING ("app"."is_admin"()) WITH CHECK ("app"."is_admin"());


--
-- Name: teacher_requests treq_owner_insert; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "treq_owner_insert" ON "app"."teacher_requests" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: teacher_requests treq_read_owner_or_admin; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY "treq_read_owner_or_admin" ON "app"."teacher_requests" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "app"."is_teacher"()));


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings Admins can manage all bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all bookings" ON "public"."bookings" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: courses Admins can manage all courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all courses" ON "public"."courses" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: course_enrollments Admins can manage all enrollments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all enrollments" ON "public"."course_enrollments" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: lesson_media Admins can manage all lesson media; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all lesson media" ON "public"."lesson_media" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: lessons Admins can manage all lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all lessons" ON "public"."lessons" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: modules Admins can manage all modules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all modules" ON "public"."modules" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: public_teacher_info Admins can manage all public teacher info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all public teacher info" ON "public"."public_teacher_info" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: user_roles Admins can manage all roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all roles" ON "public"."user_roles" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: teacher_directory Admins can manage all teacher directory entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all teacher directory entries" ON "public"."teacher_directory" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: teacher_requests Admins can manage all teacher requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all teacher requests" ON "public"."teacher_requests" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: tarot_readings Admins can view all readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all readings" ON "public"."tarot_readings" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: availability_slots Admins can view all slots; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all slots" ON "public"."availability_slots" USING ("public"."has_role"("auth"."uid"(), 'admin'::"public"."app_role"));


--
-- Name: lessons Anyone can view free preview lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view free preview lessons" ON "public"."lessons" FOR SELECT USING ((("free_preview" = true) AND (EXISTS ( SELECT 1
   FROM ("public"."modules" "m"
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."is_published" = true))))));


--
-- Name: public_teacher_info Anyone can view public teacher info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view public teacher info" ON "public"."public_teacher_info" FOR SELECT USING (true);


--
-- Name: modules Anyone can view published course modules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view published course modules" ON "public"."modules" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "modules"."course_id") AND ("courses"."is_published" = true)))));


--
-- Name: teacher_directory Anyone can view teacher directory; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view teacher directory" ON "public"."teacher_directory" FOR SELECT USING (true);


--
-- Name: lessons Enrolled students can view lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enrolled students can view lessons" ON "public"."lessons" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (("public"."modules" "m"
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
     JOIN "public"."course_enrollments" "ce" ON (("ce"."course_id" = "c"."id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("ce"."student_id" = "auth"."uid"()) AND ("ce"."status" = 'active'::"text")))));


--
-- Name: courses Everyone can view published courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Everyone can view published courses" ON "public"."courses" FOR SELECT USING ((("is_published" = true) OR ("auth"."uid"() = "teacher_id")));


--
-- Name: bookings Students can create bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can create bookings" ON "public"."bookings" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));


--
-- Name: tarot_readings Students can create readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can create readings" ON "public"."tarot_readings" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));


--
-- Name: course_enrollments Students can enroll themselves; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can enroll themselves" ON "public"."course_enrollments" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));


--
-- Name: bookings Students can update their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can update their bookings" ON "public"."bookings" FOR UPDATE USING (("auth"."uid"() = "student_id"));


--
-- Name: availability_slots Students can view available slots; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view available slots" ON "public"."availability_slots" FOR SELECT USING (("auth"."uid"() IS NOT NULL));


--
-- Name: bookings Students can view their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view their bookings" ON "public"."bookings" FOR SELECT USING (("auth"."uid"() = "student_id"));


--
-- Name: course_enrollments Students can view their enrollments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view their enrollments" ON "public"."course_enrollments" FOR SELECT USING (("auth"."uid"() = "student_id"));


--
-- Name: tarot_readings Students can view their own readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Students can view their own readings" ON "public"."tarot_readings" FOR SELECT USING (("auth"."uid"() = "student_id"));


--
-- Name: public_teacher_info Teachers can insert their own public info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can insert their own public info" ON "public"."public_teacher_info" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: course_enrollments Teachers can manage enrollments in their courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage enrollments in their courses" ON "public"."course_enrollments" USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "course_enrollments"."course_id") AND ("courses"."teacher_id" = "auth"."uid"())))));


--
-- Name: lesson_media Teachers can manage media for their lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage media for their lessons" ON "public"."lesson_media" USING ((EXISTS ( SELECT 1
   FROM (("public"."lessons" "l"
     JOIN "public"."modules" "m" ON (("m"."id" = "l"."module_id")))
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("l"."id" = "lesson_media"."lesson_id") AND ("c"."teacher_id" = "auth"."uid"())))));


--
-- Name: courses Teachers can manage their courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their courses" ON "public"."courses" USING (("auth"."uid"() = "teacher_id"));


--
-- Name: lessons Teachers can manage their own course lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their own course lessons" ON "public"."lessons" USING ((EXISTS ( SELECT 1
   FROM ("public"."modules" "m"
     JOIN "public"."courses" "c" ON (("c"."id" = "m"."course_id")))
  WHERE (("m"."id" = "lessons"."module_id") AND ("c"."teacher_id" = "auth"."uid"())))));


--
-- Name: modules Teachers can manage their own course modules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their own course modules" ON "public"."modules" USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "modules"."course_id") AND ("courses"."teacher_id" = "auth"."uid"())))));


--
-- Name: teacher_directory Teachers can manage their own directory entry; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their own directory entry" ON "public"."teacher_directory" USING (("auth"."uid"() = "user_id"));


--
-- Name: availability_slots Teachers can manage their slots; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can manage their slots" ON "public"."availability_slots" USING (("auth"."uid"() = "teacher_id"));


--
-- Name: tarot_readings Teachers can update assigned readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can update assigned readings" ON "public"."tarot_readings" FOR UPDATE USING (("auth"."uid"() = "teacher_id"));


--
-- Name: bookings Teachers can update their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can update their bookings" ON "public"."bookings" FOR UPDATE USING (("auth"."uid"() = "teacher_id"));


--
-- Name: public_teacher_info Teachers can update their own public info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can update their own public info" ON "public"."public_teacher_info" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: tarot_readings Teachers can view assigned readings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can view assigned readings" ON "public"."tarot_readings" FOR SELECT USING (("auth"."uid"() = "teacher_id"));


--
-- Name: course_enrollments Teachers can view enrollments in their courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can view enrollments in their courses" ON "public"."course_enrollments" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "course_enrollments"."course_id") AND ("courses"."teacher_id" = "auth"."uid"())))));


--
-- Name: bookings Teachers can view their bookings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Teachers can view their bookings" ON "public"."bookings" FOR SELECT USING (("auth"."uid"() = "teacher_id"));


--
-- Name: teacher_requests Users can create their own teacher requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can create their own teacher requests" ON "public"."teacher_requests" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: profiles Users can only view their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can only view their own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: messages Users can send messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can send messages" ON "public"."messages" FOR INSERT WITH CHECK (("auth"."uid"() = "sender_id"));


--
-- Name: messages Users can update their messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their messages" ON "public"."messages" FOR UPDATE USING (("auth"."uid"() = "sender_id"));


--
-- Name: notifications Users can update their notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their notifications" ON "public"."notifications" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: lesson_media Users can view public media; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view public media" ON "public"."lesson_media" FOR SELECT USING (("is_public" = true));


--
-- Name: messages Users can view their messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their messages" ON "public"."messages" FOR SELECT USING ((("auth"."uid"() = "sender_id") OR ("auth"."uid"() = "recipient_id") OR (("course_id" IS NOT NULL) AND ((EXISTS ( SELECT 1
   FROM "public"."course_enrollments"
  WHERE (("course_enrollments"."course_id" = "messages"."course_id") AND ("course_enrollments"."student_id" = "auth"."uid"()) AND ("course_enrollments"."status" = 'active'::"text")))) OR (EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "messages"."course_id") AND ("courses"."teacher_id" = "auth"."uid"()))))))));


--
-- Name: notifications Users can view their notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: user_roles Users can view their own roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own roles" ON "public"."user_roles" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: teacher_requests Users can view their own teacher requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own teacher requests" ON "public"."teacher_requests" FOR SELECT USING (("auth"."uid"() = "user_id"));


--
-- Name: admin_keys; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."admin_keys" ENABLE ROW LEVEL SECURITY;

--
-- Name: availability_slots; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."availability_slots" ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."bookings" ENABLE ROW LEVEL SECURITY;

--
-- Name: certificates cert insert teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert insert teacher" ON "public"."certificates" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: certificates cert read own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert read own" ON "public"."certificates" FOR SELECT USING (("user_id" = "auth"."uid"()));


--
-- Name: user_certifications cert read own/admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert read own/admin" ON "public"."user_certifications" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: user_certifications cert write own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert write own" ON "public"."user_certifications" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: certificates cert_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert_select_own" ON "public"."certificates" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--
-- Name: certificates cert_teacher_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cert_teacher_insert" ON "public"."certificates" FOR INSERT TO "authenticated" WITH CHECK ("public"."user_is_teacher"());


--
-- Name: certificates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."certificates" ENABLE ROW LEVEL SECURITY;

--
-- Name: course_modules cm read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm read" ON "public"."course_modules" FOR SELECT USING (true);


--
-- Name: course_modules cm write teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm write teacher" ON "public"."course_modules" USING ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: course_modules cm_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm_select_all" ON "public"."course_modules" FOR SELECT USING (true);


--
-- Name: course_modules cm_teacher_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cm_teacher_write" ON "public"."course_modules" TO "authenticated" USING ("public"."user_is_teacher"()) WITH CHECK ("public"."user_is_teacher"());


--
-- Name: coupons; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."coupons" ENABLE ROW LEVEL SECURITY;

--
-- Name: coupons coupons admin delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin delete" ON "public"."coupons" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: coupons coupons admin insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin insert" ON "public"."coupons" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: coupons coupons admin select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin select" ON "public"."coupons" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: coupons coupons admin update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "coupons admin update" ON "public"."coupons" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))) WITH CHECK (true);


--
-- Name: course_enrollments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."course_enrollments" ENABLE ROW LEVEL SECURITY;

--
-- Name: course_modules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."course_modules" ENABLE ROW LEVEL SECURITY;

--
-- Name: course_quizzes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."course_quizzes" ENABLE ROW LEVEL SECURITY;

--
-- Name: courses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."courses" ENABLE ROW LEVEL SECURITY;

--
-- Name: courses courses delete own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses delete own" ON "public"."courses" FOR DELETE USING (("created_by" = "auth"."uid"()));


--
-- Name: courses courses insert teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses insert teacher" ON "public"."courses" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions" "t"
  WHERE ("t"."user_id" = "auth"."uid"()))));


--
-- Name: courses courses read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses read" ON "public"."courses" FOR SELECT USING (true);


--
-- Name: courses courses update own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "courses update own" ON "public"."courses" FOR UPDATE USING (("created_by" = "auth"."uid"()));


--
-- Name: course_quizzes cq_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cq_select_all" ON "public"."course_quizzes" FOR SELECT USING (true);


--
-- Name: course_quizzes cq_teacher_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "cq_teacher_write" ON "public"."course_quizzes" TO "authenticated" USING ("public"."user_is_teacher"()) WITH CHECK ("public"."user_is_teacher"());


--
-- Name: admin_keys keys admin insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "keys admin insert" ON "public"."admin_keys" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: admin_keys keys admin select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "keys admin select" ON "public"."admin_keys" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: admin_keys keys admin update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "keys admin update" ON "public"."admin_keys" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))) WITH CHECK (true);


--
-- Name: lesson_media; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."lesson_media" ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."lessons" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: modules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."modules" ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscription_plans plans read all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "plans read all" ON "public"."subscription_plans" FOR SELECT USING (true);


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles read" ON "public"."profiles" FOR SELECT USING (true);


--
-- Name: profiles profiles update own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles update own" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));


--
-- Name: public_teacher_info; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."public_teacher_info" ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_attempts qa insert self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa insert self" ON "public"."quiz_attempts" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));


--
-- Name: quiz_attempts qa read own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa read own" ON "public"."quiz_attempts" FOR SELECT USING (("user_id" = "auth"."uid"()));


--
-- Name: quiz_attempts qa_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa_insert_own" ON "public"."quiz_attempts" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: quiz_attempts qa_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qa_select_own" ON "public"."quiz_attempts" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));


--
-- Name: quiz_questions qq read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq read" ON "public"."quiz_questions" FOR SELECT USING (true);


--
-- Name: quiz_questions qq write teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq write teacher" ON "public"."quiz_questions" USING ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: quiz_questions qq_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq_select_all" ON "public"."quiz_questions" FOR SELECT USING (true);


--
-- Name: quiz_questions qq_teacher_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "qq_teacher_write" ON "public"."quiz_questions" TO "authenticated" USING ("public"."user_is_teacher"()) WITH CHECK ("public"."user_is_teacher"());


--
-- Name: course_quizzes quiz read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "quiz read" ON "public"."course_quizzes" FOR SELECT USING (true);


--
-- Name: course_quizzes quiz write teacher; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "quiz write teacher" ON "public"."course_quizzes" USING ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))));


--
-- Name: quiz_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."quiz_attempts" ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_questions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."quiz_questions" ENABLE ROW LEVEL SECURITY;

--
-- Name: services; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."services" ENABLE ROW LEVEL SECURITY;

--
-- Name: services services read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "services read" ON "public"."services" FOR SELECT USING (true);


--
-- Name: services services write own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "services write own" ON "public"."services" USING (("owner" = "auth"."uid"())) WITH CHECK (("owner" = "auth"."uid"()));


--
-- Name: subscriptions subs nobody delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs nobody delete" ON "public"."subscriptions" FOR DELETE USING (false);


--
-- Name: subscriptions subs nobody insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs nobody insert" ON "public"."subscriptions" FOR INSERT WITH CHECK (false);


--
-- Name: subscriptions subs nobody update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs nobody update" ON "public"."subscriptions" FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: subscriptions subs read own/admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "subs read own/admin" ON "public"."subscriptions" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: subscription_plans; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscription_plans" ENABLE ROW LEVEL SECURITY;

--
-- Name: subscriptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."subscriptions" ENABLE ROW LEVEL SECURITY;

--
-- Name: tarot_readings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."tarot_readings" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions teacher admin delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "teacher admin delete" ON "public"."teacher_permissions" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: teacher_permissions teacher admin insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "teacher admin insert" ON "public"."teacher_permissions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))));


--
-- Name: teacher_permissions teacher read own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "teacher read own" ON "public"."teacher_permissions" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: teacher_directory; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."teacher_directory" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."teacher_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."teacher_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: user_certifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."user_certifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE "realtime"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Authenticated users can upload to their own folder in public-me; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Authenticated users can upload to their own folder in public-me" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'public-media'::"text") AND (("auth"."uid"())::"text" = ("storage"."foldername"("name"))[1])));


--
-- Name: objects Public media is readable by everyone; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Public media is readable by everyone" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public-media'::"text"));


--
-- Name: objects SELECT 1r7zrx6_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "SELECT 1r7zrx6_0" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'media'::"text"));


--
-- Name: objects Users can delete their own files in public-media; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Users can delete their own files in public-media" ON "storage"."objects" FOR DELETE USING ((("bucket_id" = 'public-media'::"text") AND (("auth"."uid"())::"text" = ("storage"."foldername"("name"))[1])));


--
-- Name: objects Users can update their own files in public-media; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Users can update their own files in public-media" ON "storage"."objects" FOR UPDATE USING ((("bucket_id" = 'public-media'::"text") AND (("auth"."uid"())::"text" = ("storage"."foldername"("name"))[1])));


--
-- Name: objects avatars public read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars public read" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects avatars user delete; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars user delete" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects avatars user insert; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars user insert" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects avatars user update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars user update" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'avatars'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects avatars_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars_read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects avatars_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "avatars_write" ON "storage"."objects" USING ((("bucket_id" = 'avatars'::"text") AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text"))) WITH CHECK ((("bucket_id" = 'avatars'::"text") AND ("split_part"("name", '/'::"text", 1) = ("auth"."uid"())::"text")));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."buckets_analytics" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects course-media read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course-media read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'course-media'::"text"));


--
-- Name: objects course-media teacher write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course-media teacher write" ON "storage"."objects" USING ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"()))))) WITH CHECK ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."teacher_permissions"
  WHERE ("teacher_permissions"."user_id" = "auth"."uid"())))));


--
-- Name: objects course_media_public_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_public_read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'course-media'::"text"));


--
-- Name: objects course_media_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_read" ON "storage"."objects" FOR SELECT USING ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE ((("c"."id")::"text" = "split_part"("objects"."name", '/'::"text", 1)) AND (("c"."is_published" = true) OR ("c"."created_by" = "auth"."uid"())))))));


--
-- Name: objects course_media_teacher_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_teacher_write" ON "storage"."objects" TO "authenticated" USING ((("bucket_id" = 'course-media'::"text") AND "public"."user_is_teacher"())) WITH CHECK ((("bucket_id" = 'course-media'::"text") AND "public"."user_is_teacher"()));


--
-- Name: objects course_media_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "course_media_write" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'course-media'::"text") AND (EXISTS ( SELECT 1
   FROM "app"."courses" "c"
  WHERE ((("c"."id")::"text" = "split_part"("objects"."name", '/'::"text", 1)) AND ("c"."created_by" = "auth"."uid"()))))));


--
-- Name: objects media_teacher_update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "media_teacher_update" ON "storage"."objects" FOR UPDATE USING ((("bucket_id" = 'media'::"text") AND "app"."is_teacher"())) WITH CHECK ((("bucket_id" = 'media'::"text") AND "app"."is_teacher"()));


--
-- Name: objects media_teacher_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "media_teacher_write" ON "storage"."objects" FOR INSERT WITH CHECK ((("bucket_id" = 'media'::"text") AND "app"."is_teacher"()));


--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."prefixes" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects public read media; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public read media" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING (("bucket_id" = 'media'::"text"));


--
-- Name: objects public-assets admin write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public-assets admin write" ON "storage"."objects" USING ((("bucket_id" = 'public-assets'::"text") AND (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text")))))) WITH CHECK ((("bucket_id" = 'public-assets'::"text") AND (EXISTS ( SELECT 1
   FROM "auth"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."raw_app_meta_data" ->> 'role'::"text") = 'admin'::"text"))))));


--
-- Name: objects public-assets read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public-assets read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public-assets'::"text"));


--
-- Name: objects public_assets_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public_assets_read" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'public-assets'::"text"));


--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects update to authenticated 1prfdz4_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "update to authenticated 1prfdz4_0" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'media'::"text") AND "app"."is_teacher_uid"("auth"."uid"())));


--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION "supabase_realtime" WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_graphql_placeholder" ON "sql_drop"
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION "extensions"."set_graphql_placeholder"();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_cron_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION "extensions"."grant_pg_cron_access"();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_graphql_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION "extensions"."grant_pg_graphql_access"();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_net_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION "extensions"."grant_pg_net_access"();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "pgrst_ddl_watch" ON "ddl_command_end"
   EXECUTE FUNCTION "extensions"."pgrst_ddl_watch"();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "pgrst_drop_watch" ON "sql_drop"
   EXECUTE FUNCTION "extensions"."pgrst_drop_watch"();


--
-- PostgreSQL database dump complete
--

\unrestrict WlxWywGIIJ8ijT2hWc5PleVIWhvnVfG33NrQWvmbPbjZ9z3PxeRbYwySOfjJcTv

