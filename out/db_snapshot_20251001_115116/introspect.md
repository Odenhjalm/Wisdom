     ?column?      
-------------------
 # Databasöversikt
(1 row)

 ?column? 
----------
 
(1 row)

     ?column?      
-------------------
 Databas: postgres
(1 row)

                                             ?column?                                              
---------------------------------------------------------------------------------------------------
 Serverversion: PostgreSQL 17.4 on aarch64-unknown-linux-gnu, compiled by gcc (GCC) 13.2.0, 64-bit
(1 row)

 ?column? 
----------
 
(1 row)

   ?column?    
---------------
 ## Extensions
(1 row)

                              Aktiva extensions                               
------------------------------------------------------------------------------
 pg_graphql, pg_stat_statements, pgcrypto, plpgsql, supabase_vault, uuid-ossp
(1 row)

 ?column? 
----------
 
(1 row)

  ?column?  
------------
 ## Scheman
(1 row)

                                                Scheman                                                
-------------------------------------------------------------------------------------------------------
 app, auth, extensions, graphql, graphql_public, public, realtime, storage, supabase_migrations, vault
(1 row)

 ?column? 
----------
 
(1 row)

   ?column?    
---------------
 ## Enum-typer
(1 row)

  schema  |        enum_type        |                                                               labels                                                               
----------+-------------------------+------------------------------------------------------------------------------------------------------------------------------------
 app      | channel                 | push, email, in_app
 app      | drip_mode               | relative, absolute
 app      | enrollment_source       | free_intro, purchase, membership, grant
 app      | magic_action            | open_url, deep_link, navigate_course, start_meditation, enroll_course
 app      | membership_plan         | none, basic, pro, lifetime
 app      | membership_status       | inactive, active, past_due, canceled
 app      | order_status            | pending, requires_action, paid, canceled, failed, refunded
 app      | role_type               | user, member, teacher, admin
 app      | user_role               | user, professional, teacher
 auth     | aal_level               | aal1, aal2, aal3
 auth     | code_challenge_method   | s256, plain
 auth     | factor_status           | unverified, verified
 auth     | factor_type             | totp, webauthn, phone
 auth     | oauth_registration_type | dynamic, manual
 auth     | one_time_token_type     | confirmation_token, reauthentication_token, recovery_token, email_change_token_new, email_change_token_current, phone_change_token
 public   | app_role                | student, teacher, admin
 public   | user_role               | user, teacher, admin
 realtime | action                  | INSERT, UPDATE, DELETE, TRUNCATE, ERROR
 realtime | equality_op             | eq, neq, lt, lte, gt, gte, in
 storage  | buckettype              | STANDARD, ANALYTICS
(20 rows)

 ?column? 
----------
 
(1 row)

              ?column?               
-------------------------------------
 ## Tabeller & kolumner (sammandrag)
(1 row)

    table_schema     |         table_name         |                                       columns                                        
---------------------+----------------------------+--------------------------------------------------------------------------------------
 app                 | app_config                 | id integer NOT NULL DEFAULT 1                                                       +
                     |                            | free_course_limit integer NOT NULL DEFAULT 5                                        +
                     |                            | platform_fee_pct numeric NOT NULL DEFAULT 10                                        +
                     |                            | created_by uuid DEFAULT auth.uid()
 app                 | bookings                   | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | slot_id uuid NOT NULL                                                               +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | order_id uuid                                                                       +
                     |                            | status text NOT NULL DEFAULT 'pending'::text                                        +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | certificates               | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | title text NOT NULL                                                                 +
                     |                            | status text NOT NULL DEFAULT 'pending'::text                                        +
                     |                            | evidence_url text                                                                   +
                     |                            | notes text                                                                          +
                     |                            | created_at timestamp with time zone DEFAULT now()                                   +
                     |                            | updated_at timestamp with time zone DEFAULT now()                                   +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()
 app                 | certifications             | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | issued_at timestamp with time zone NOT NULL DEFAULT now()                           +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | courses                    | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | slug text NOT NULL                                                                  +
                     |                            | title text NOT NULL                                                                 +
                     |                            | description text                                                                    +
                     |                            | cover_url text                                                                      +
                     |                            | is_free_intro boolean NOT NULL DEFAULT false                                        +
                     |                            | price_cents integer NOT NULL DEFAULT 0                                              +
                     |                            | is_published boolean NOT NULL DEFAULT false                                         +
                     |                            | created_by uuid NOT NULL                                                            +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | intro_video_url text                                                                +
                     |                            | video_url text                                                                      +
                     |                            | branch text
 app                 | drip_plans                 | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | name text NOT NULL                                                                  +
                     |                            | mode USER-DEFINED NOT NULL DEFAULT 'relative'::app.drip_mode                        +
                     |                            | start_at date                                                                       +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL
 app                 | drip_rules                 | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | plan_id uuid NOT NULL                                                               +
                     |                            | module_id uuid NOT NULL                                                             +
                     |                            | page_id uuid                                                                        +
                     |                            | offset_days integer                                                                 +
                     |                            | release_at date                                                                     +
                     |                            | notify_template_id uuid                                                             +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL
 app                 | editor_styles              | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | name text NOT NULL                                                                  +
                     |                            | font_family text NOT NULL DEFAULT 'System'::text                                    +
                     |                            | base_font_size integer NOT NULL DEFAULT 16                                          +
                     |                            | color_primary text NOT NULL DEFAULT '#6C5CE7'::text                                 +
                     |                            | color_accent text NOT NULL DEFAULT '#A66BFF'::text                                  +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL
 app                 | enrollments                | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | source USER-DEFINED NOT NULL DEFAULT 'purchase'::app.enrollment_source              +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | events                     | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | created_by uuid NOT NULL                                                            +
                     |                            | title text NOT NULL                                                                 +
                     |                            | description text                                                                    +
                     |                            | starts_at timestamp with time zone NOT NULL                                         +
                     |                            | ends_at timestamp with time zone                                                    +
                     |                            | location text                                                                       +
                     |                            | is_published boolean NOT NULL DEFAULT false                                         +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | guest_claim_tokens         | token uuid NOT NULL DEFAULT uuid_generate_v4()                                      +
                     |                            | buyer_email text NOT NULL                                                           +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | purchase_id uuid NOT NULL                                                           +
                     |                            | used boolean NOT NULL DEFAULT false                                                 +
                     |                            | expires_at timestamp with time zone NOT NULL DEFAULT (now() + '14 days'::interval)  +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | lesson_media               | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | lesson_id uuid NOT NULL                                                             +
                     |                            | kind text NOT NULL                                                                  +
                     |                            | storage_path text NOT NULL                                                          +
                     |                            | duration_seconds integer                                                            +
                     |                            | position integer NOT NULL DEFAULT 0                                                 +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | lessons                    | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | module_id uuid NOT NULL                                                             +
                     |                            | title text NOT NULL                                                                 +
                     |                            | content_markdown text                                                               +
                     |                            | is_intro boolean NOT NULL DEFAULT false                                             +
                     |                            | position integer NOT NULL DEFAULT 0                                                 +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | magic_links                | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | label text NOT NULL                                                                 +
                     |                            | action USER-DEFINED NOT NULL                                                        +
                     |                            | payload jsonb NOT NULL DEFAULT '{}'::jsonb                                          +
                     |                            | style_id uuid                                                                       +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL
 app                 | meditations                | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | teacher_id uuid NOT NULL                                                            +
                     |                            | title text NOT NULL                                                                 +
                     |                            | description text                                                                    +
                     |                            | audio_path text NOT NULL                                                            +
                     |                            | duration_seconds integer                                                            +
                     |                            | is_public boolean NOT NULL DEFAULT true                                             +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | memberships                | user_id uuid NOT NULL                                                               +
                     |                            | plan USER-DEFINED NOT NULL DEFAULT 'none'::app.membership_plan                      +
                     |                            | status USER-DEFINED NOT NULL DEFAULT 'inactive'::app.membership_status              +
                     |                            | current_period_end timestamp with time zone                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()
 app                 | messages                   | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | channel text NOT NULL                                                               +
                     |                            | sender_id uuid NOT NULL                                                             +
                     |                            | content text NOT NULL                                                               +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | modules                    | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | title text NOT NULL                                                                 +
                     |                            | position integer NOT NULL DEFAULT 0                                                 +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | notification_jobs          | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | module_id uuid NOT NULL                                                             +
                     |                            | page_id uuid                                                                        +
                     |                            | scheduled_at timestamp with time zone NOT NULL                                      +
                     |                            | template_id uuid                                                                    +
                     |                            | status text NOT NULL DEFAULT 'pending'::text                                        +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL
 app                 | notification_templates     | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | template_key text NOT NULL                                                          +
                     |                            | locale text NOT NULL DEFAULT 'sv-SE'::text                                          +
                     |                            | title text NOT NULL                                                                 +
                     |                            | body text NOT NULL                                                                  +
                     |                            | channel USER-DEFINED NOT NULL DEFAULT 'push'::app.channel                           +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL
 app                 | orders                     | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | course_id uuid                                                                      +
                     |                            | amount_cents integer NOT NULL                                                       +
                     |                            | currency text NOT NULL DEFAULT 'sek'::text                                          +
                     |                            | status USER-DEFINED NOT NULL DEFAULT 'pending'::app.order_status                    +
                     |                            | stripe_checkout_id text                                                             +
                     |                            | stripe_payment_intent text                                                          +
                     |                            | metadata jsonb                                                                      +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | service_id uuid                                                                     +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()
 app                 | pro_progress               | user_id uuid NOT NULL                                                               +
                     |                            | requirement_id integer NOT NULL                                                     +
                     |                            | completed_at timestamp with time zone DEFAULT now()                                 +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | pro_requirements           | id integer NOT NULL DEFAULT nextval('app.pro_requirements_id_seq'::regclass)        +
                     |                            | code text NOT NULL                                                                  +
                     |                            | title text NOT NULL                                                                 +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | profiles                   | user_id uuid NOT NULL                                                               +
                     |                            | email text                                                                          +
                     |                            | display_name text                                                                   +
                     |                            | bio text                                                                            +
                     |                            | photo_url text                                                                      +
                     |                            | role USER-DEFINED NOT NULL DEFAULT 'user'::app.role_type                            +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | is_admin boolean NOT NULL DEFAULT false                                             +
                     |                            | role_v2 USER-DEFINED NOT NULL DEFAULT 'user'::app.user_role
 app                 | purchases                  | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | order_id uuid                                                                       +
                     |                            | user_id uuid                                                                        +
                     |                            | buyer_email text NOT NULL                                                           +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | stripe_checkout_id text                                                             +
                     |                            | stripe_payment_intent text                                                          +
                     |                            | status text NOT NULL DEFAULT 'succeeded'::text                                      +
                     |                            | amount_cents integer                                                                +
                     |                            | currency text                                                                       +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | services                   | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | provider_id uuid NOT NULL                                                           +
                     |                            | title text NOT NULL                                                                 +
                     |                            | description text                                                                    +
                     |                            | price_cents integer NOT NULL DEFAULT 0                                              +
                     |                            | is_active boolean NOT NULL DEFAULT true                                             +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | tarot_requests             | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | requester_id uuid NOT NULL                                                          +
                     |                            | reader_id uuid                                                                      +
                     |                            | question text NOT NULL                                                              +
                     |                            | status text NOT NULL DEFAULT 'open'::text                                           +
                     |                            | order_id uuid                                                                       +
                     |                            | deliverable_url text                                                                +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()
 app                 | teacher_approvals          | user_id uuid NOT NULL                                                               +
                     |                            | approved_by uuid                                                                    +
                     |                            | approved_at timestamp with time zone                                                +
                     |                            | created_by uuid NOT NULL DEFAULT auth.uid()                                         +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | teacher_directory          | user_id uuid NOT NULL                                                               +
                     |                            | headline text                                                                       +
                     |                            | specialties ARRAY                                                                   +
                     |                            | rating numeric                                                                      +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | teacher_permissions        | profile_id uuid NOT NULL                                                            +
                     |                            | can_edit_courses boolean NOT NULL DEFAULT false                                     +
                     |                            | can_publish boolean NOT NULL DEFAULT false                                          +
                     |                            | granted_by uuid                                                                     +
                     |                            | granted_at timestamp with time zone
 app                 | teacher_requests           | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | message text                                                                        +
                     |                            | status text NOT NULL DEFAULT 'pending'::text                                        +
                     |                            | reviewed_by uuid                                                                    +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 app                 | teacher_slots              | id uuid NOT NULL DEFAULT uuid_generate_v4()                                         +
                     |                            | teacher_id uuid NOT NULL                                                            +
                     |                            | starts_at timestamp with time zone NOT NULL                                         +
                     |                            | ends_at timestamp with time zone NOT NULL                                           +
                     |                            | is_booked boolean NOT NULL DEFAULT false                                            +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 auth                | audit_log_entries          | instance_id uuid                                                                    +
                     |                            | id uuid NOT NULL                                                                    +
                     |                            | payload json                                                                        +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | ip_address character varying(64) NOT NULL DEFAULT ''::character varying
 auth                | flow_state                 | id uuid NOT NULL                                                                    +
                     |                            | user_id uuid                                                                        +
                     |                            | auth_code text NOT NULL                                                             +
                     |                            | code_challenge_method USER-DEFINED NOT NULL                                         +
                     |                            | code_challenge text NOT NULL                                                        +
                     |                            | provider_type text NOT NULL                                                         +
                     |                            | provider_access_token text                                                          +
                     |                            | provider_refresh_token text                                                         +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | authentication_method text NOT NULL                                                 +
                     |                            | auth_code_issued_at timestamp with time zone
 auth                | identities                 | provider_id text NOT NULL                                                           +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | identity_data jsonb NOT NULL                                                        +
                     |                            | provider text NOT NULL                                                              +
                     |                            | last_sign_in_at timestamp with time zone                                            +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | email text                                                                          +
                     |                            | id uuid NOT NULL DEFAULT gen_random_uuid()
 auth                | instances                  | id uuid NOT NULL                                                                    +
                     |                            | uuid uuid                                                                           +
                     |                            | raw_base_config text                                                                +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone
 auth                | mfa_amr_claims             | session_id uuid NOT NULL                                                            +
                     |                            | created_at timestamp with time zone NOT NULL                                        +
                     |                            | updated_at timestamp with time zone NOT NULL                                        +
                     |                            | authentication_method text NOT NULL                                                 +
                     |                            | id uuid NOT NULL
 auth                | mfa_challenges             | id uuid NOT NULL                                                                    +
                     |                            | factor_id uuid NOT NULL                                                             +
                     |                            | created_at timestamp with time zone NOT NULL                                        +
                     |                            | verified_at timestamp with time zone                                                +
                     |                            | ip_address inet NOT NULL                                                            +
                     |                            | otp_code text                                                                       +
                     |                            | web_authn_session_data jsonb
 auth                | mfa_factors                | id uuid NOT NULL                                                                    +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | friendly_name text                                                                  +
                     |                            | factor_type USER-DEFINED NOT NULL                                                   +
                     |                            | status USER-DEFINED NOT NULL                                                        +
                     |                            | created_at timestamp with time zone NOT NULL                                        +
                     |                            | updated_at timestamp with time zone NOT NULL                                        +
                     |                            | secret text                                                                         +
                     |                            | phone text                                                                          +
                     |                            | last_challenged_at timestamp with time zone                                         +
                     |                            | web_authn_credential jsonb                                                          +
                     |                            | web_authn_aaguid uuid
 auth                | oauth_clients              | id uuid NOT NULL                                                                    +
                     |                            | client_id text NOT NULL                                                             +
                     |                            | client_secret_hash text NOT NULL                                                    +
                     |                            | registration_type USER-DEFINED NOT NULL                                             +
                     |                            | redirect_uris text NOT NULL                                                         +
                     |                            | grant_types text NOT NULL                                                           +
                     |                            | client_name text                                                                    +
                     |                            | client_uri text                                                                     +
                     |                            | logo_uri text                                                                       +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | deleted_at timestamp with time zone
 auth                | one_time_tokens            | id uuid NOT NULL                                                                    +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | token_type USER-DEFINED NOT NULL                                                    +
                     |                            | token_hash text NOT NULL                                                            +
                     |                            | relates_to text NOT NULL                                                            +
                     |                            | created_at timestamp without time zone NOT NULL DEFAULT now()                       +
                     |                            | updated_at timestamp without time zone NOT NULL DEFAULT now()
 auth                | refresh_tokens             | instance_id uuid                                                                    +
                     |                            | id bigint NOT NULL DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass)          +
                     |                            | token character varying(255)                                                        +
                     |                            | user_id character varying(255)                                                      +
                     |                            | revoked boolean                                                                     +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | parent character varying(255)                                                       +
                     |                            | session_id uuid
 auth                | saml_providers             | id uuid NOT NULL                                                                    +
                     |                            | sso_provider_id uuid NOT NULL                                                       +
                     |                            | entity_id text NOT NULL                                                             +
                     |                            | metadata_xml text NOT NULL                                                          +
                     |                            | metadata_url text                                                                   +
                     |                            | attribute_mapping jsonb                                                             +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | name_id_format text
 auth                | saml_relay_states          | id uuid NOT NULL                                                                    +
                     |                            | sso_provider_id uuid NOT NULL                                                       +
                     |                            | request_id text NOT NULL                                                            +
                     |                            | for_email text                                                                      +
                     |                            | redirect_to text                                                                    +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | flow_state_id uuid
 auth                | schema_migrations          | version character varying(255) NOT NULL
 auth                | sessions                   | id uuid NOT NULL                                                                    +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | factor_id uuid                                                                      +
                     |                            | aal USER-DEFINED                                                                    +
                     |                            | not_after timestamp with time zone                                                  +
                     |                            | refreshed_at timestamp without time zone                                            +
                     |                            | user_agent text                                                                     +
                     |                            | ip inet                                                                             +
                     |                            | tag text
 auth                | sso_domains                | id uuid NOT NULL                                                                    +
                     |                            | sso_provider_id uuid NOT NULL                                                       +
                     |                            | domain text NOT NULL                                                                +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone
 auth                | sso_providers              | id uuid NOT NULL                                                                    +
                     |                            | resource_id text                                                                    +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | disabled boolean
 auth                | users                      | instance_id uuid                                                                    +
                     |                            | id uuid NOT NULL                                                                    +
                     |                            | aud character varying(255)                                                          +
                     |                            | role character varying(255)                                                         +
                     |                            | email character varying(255)                                                        +
                     |                            | encrypted_password character varying(255)                                           +
                     |                            | email_confirmed_at timestamp with time zone                                         +
                     |                            | invited_at timestamp with time zone                                                 +
                     |                            | confirmation_token character varying(255)                                           +
                     |                            | confirmation_sent_at timestamp with time zone                                       +
                     |                            | recovery_token character varying(255)                                               +
                     |                            | recovery_sent_at timestamp with time zone                                           +
                     |                            | email_change_token_new character varying(255)                                       +
                     |                            | email_change character varying(255)                                                 +
                     |                            | email_change_sent_at timestamp with time zone                                       +
                     |                            | last_sign_in_at timestamp with time zone                                            +
                     |                            | raw_app_meta_data jsonb                                                             +
                     |                            | raw_user_meta_data jsonb                                                            +
                     |                            | is_super_admin boolean                                                              +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone                                                 +
                     |                            | phone text DEFAULT NULL::character varying                                          +
                     |                            | phone_confirmed_at timestamp with time zone                                         +
                     |                            | phone_change text DEFAULT ''::character varying                                     +
                     |                            | phone_change_token character varying(255) DEFAULT ''::character varying             +
                     |                            | phone_change_sent_at timestamp with time zone                                       +
                     |                            | confirmed_at timestamp with time zone                                               +
                     |                            | email_change_token_current character varying(255) DEFAULT ''::character varying     +
                     |                            | email_change_confirm_status smallint DEFAULT 0                                      +
                     |                            | banned_until timestamp with time zone                                               +
                     |                            | reauthentication_token character varying(255) DEFAULT ''::character varying         +
                     |                            | reauthentication_sent_at timestamp with time zone                                   +
                     |                            | is_sso_user boolean NOT NULL DEFAULT false                                          +
                     |                            | deleted_at timestamp with time zone                                                 +
                     |                            | is_anonymous boolean NOT NULL DEFAULT false
 extensions          | pg_stat_statements         | userid oid                                                                          +
                     |                            | dbid oid                                                                            +
                     |                            | toplevel boolean                                                                    +
                     |                            | queryid bigint                                                                      +
                     |                            | query text                                                                          +
                     |                            | plans bigint                                                                        +
                     |                            | total_plan_time double precision                                                    +
                     |                            | min_plan_time double precision                                                      +
                     |                            | max_plan_time double precision                                                      +
                     |                            | mean_plan_time double precision                                                     +
                     |                            | stddev_plan_time double precision                                                   +
                     |                            | calls bigint                                                                        +
                     |                            | total_exec_time double precision                                                    +
                     |                            | min_exec_time double precision                                                      +
                     |                            | max_exec_time double precision                                                      +
                     |                            | mean_exec_time double precision                                                     +
                     |                            | stddev_exec_time double precision                                                   +
                     |                            | rows bigint                                                                         +
                     |                            | shared_blks_hit bigint                                                              +
                     |                            | shared_blks_read bigint                                                             +
                     |                            | shared_blks_dirtied bigint                                                          +
                     |                            | shared_blks_written bigint                                                          +
                     |                            | local_blks_hit bigint                                                               +
                     |                            | local_blks_read bigint                                                              +
                     |                            | local_blks_dirtied bigint                                                           +
                     |                            | local_blks_written bigint                                                           +
                     |                            | temp_blks_read bigint                                                               +
                     |                            | temp_blks_written bigint                                                            +
                     |                            | shared_blk_read_time double precision                                               +
                     |                            | shared_blk_write_time double precision                                              +
                     |                            | local_blk_read_time double precision                                                +
                     |                            | local_blk_write_time double precision                                               +
                     |                            | temp_blk_read_time double precision                                                 +
                     |                            | temp_blk_write_time double precision                                                +
                     |                            | wal_records bigint                                                                  +
                     |                            | wal_fpi bigint                                                                      +
                     |                            | wal_bytes numeric                                                                   +
                     |                            | jit_functions bigint                                                                +
                     |                            | jit_generation_time double precision                                                +
                     |                            | jit_inlining_count bigint                                                           +
                     |                            | jit_inlining_time double precision                                                  +
                     |                            | jit_optimization_count bigint                                                       +
                     |                            | jit_optimization_time double precision                                              +
                     |                            | jit_emission_count bigint                                                           +
                     |                            | jit_emission_time double precision                                                  +
                     |                            | jit_deform_count bigint                                                             +
                     |                            | jit_deform_time double precision                                                    +
                     |                            | stats_since timestamp with time zone                                                +
                     |                            | minmax_stats_since timestamp with time zone
 extensions          | pg_stat_statements_info    | dealloc bigint                                                                      +
                     |                            | stats_reset timestamp with time zone
 public              | admin_keys                 | code text NOT NULL                                                                  +
                     |                            | issued_by uuid                                                                      +
                     |                            | issued_at timestamp with time zone DEFAULT now()                                    +
                     |                            | redeemed_by uuid                                                                    +
                     |                            | redeemed_at timestamp with time zone
 public              | availability_slots         | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | teacher_id uuid NOT NULL                                                            +
                     |                            | start_time timestamp with time zone NOT NULL                                        +
                     |                            | end_time timestamp with time zone NOT NULL                                          +
                     |                            | price integer NOT NULL                                                              +
                     |                            | duration_minutes integer NOT NULL DEFAULT 60                                        +
                     |                            | is_booked boolean NOT NULL DEFAULT false                                            +
                     |                            | title text                                                                          +
                     |                            | description text                                                                    +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | bookings                   | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | student_id uuid NOT NULL                                                            +
                     |                            | teacher_id uuid NOT NULL                                                            +
                     |                            | slot_id uuid NOT NULL                                                               +
                     |                            | status text NOT NULL DEFAULT 'confirmed'::text                                      +
                     |                            | payment_status text NOT NULL DEFAULT 'pending'::text                                +
                     |                            | stripe_payment_intent_id text                                                       +
                     |                            | notes text                                                                          +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | certificates               | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | issued_at timestamp with time zone NOT NULL DEFAULT now()
 public              | coupons                    | code text NOT NULL                                                                  +
                     |                            | plan_id uuid                                                                        +
                     |                            | grants jsonb NOT NULL DEFAULT '{}'::jsonb                                           +
                     |                            | max_redemptions integer NOT NULL DEFAULT 1                                          +
                     |                            | redeemed_count integer NOT NULL DEFAULT 0                                           +
                     |                            | expires_at timestamp with time zone                                                 +
                     |                            | is_enabled boolean NOT NULL DEFAULT true                                            +
                     |                            | issued_by uuid                                                                      +
                     |                            | issued_at timestamp with time zone NOT NULL DEFAULT now()
 public              | course_enrollments         | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | student_id uuid NOT NULL                                                            +
                     |                            | enrolled_at timestamp with time zone NOT NULL DEFAULT now()                         +
                     |                            | status text NOT NULL DEFAULT 'active'::text
 public              | course_modules             | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | position integer NOT NULL DEFAULT 0                                                 +
                     |                            | type text NOT NULL                                                                  +
                     |                            | title text                                                                          +
                     |                            | body text                                                                           +
                     |                            | media_url text                                                                      +
                     |                            | created_by uuid                                                                     +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone
 public              | course_quizzes             | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | title text NOT NULL                                                                 +
                     |                            | pass_score integer NOT NULL DEFAULT 80                                              +
                     |                            | created_by uuid                                                                     +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 public              | courses                    | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | teacher_id uuid                                                                     +
                     |                            | title text NOT NULL                                                                 +
                     |                            | description text                                                                    +
                     |                            | price integer                                                                       +
                     |                            | is_published boolean NOT NULL DEFAULT false                                         +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | branch text                                                                         +
                     |                            | cover_url text                                                                      +
                     |                            | price_cents integer DEFAULT 0                                                       +
                     |                            | is_free_intro boolean DEFAULT false                                                 +
                     |                            | slug text                                                                           +
                     |                            | is_free boolean NOT NULL DEFAULT false                                              +
                     |                            | is_intro boolean NOT NULL DEFAULT false                                             +
                     |                            | created_by uuid
 public              | lesson_media               | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | lesson_id uuid NOT NULL                                                             +
                     |                            | type text NOT NULL                                                                  +
                     |                            | storage_path text NOT NULL                                                          +
                     |                            | is_public boolean DEFAULT true                                                      +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 public              | lessons                    | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | module_id uuid NOT NULL                                                             +
                     |                            | title text NOT NULL                                                                 +
                     |                            | index integer NOT NULL DEFAULT 0                                                    +
                     |                            | content jsonb DEFAULT '{}'::jsonb                                                   +
                     |                            | free_preview boolean DEFAULT false                                                  +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | messages                   | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | sender_id uuid NOT NULL                                                             +
                     |                            | recipient_id uuid                                                                   +
                     |                            | course_id uuid                                                                      +
                     |                            | content text NOT NULL                                                               +
                     |                            | is_read boolean NOT NULL DEFAULT false                                              +
                     |                            | parent_message_id uuid                                                              +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | modules                    | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | course_id uuid NOT NULL                                                             +
                     |                            | title text NOT NULL                                                                 +
                     |                            | index integer NOT NULL DEFAULT 0                                                    +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | notifications              | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | type text NOT NULL                                                                  +
                     |                            | title text NOT NULL                                                                 +
                     |                            | message text NOT NULL                                                               +
                     |                            | is_read boolean NOT NULL DEFAULT false                                              +
                     |                            | metadata jsonb                                                                      +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 public              | profiles                   | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | email text                                                                          +
                     |                            | full_name text                                                                      +
                     |                            | avatar_url text                                                                     +
                     |                            | bio text                                                                            +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | role USER-DEFINED DEFAULT 'user'::user_role
 public              | public_teacher_info        | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | full_name text                                                                      +
                     |                            | bio text                                                                            +
                     |                            | avatar_url text                                                                     +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | quiz_attempts              | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | quiz_id uuid NOT NULL                                                               +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | answers jsonb NOT NULL                                                              +
                     |                            | score integer NOT NULL                                                              +
                     |                            | passed boolean NOT NULL                                                             +
                     |                            | submitted_at timestamp with time zone NOT NULL DEFAULT now()
 public              | quiz_questions             | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | quiz_id uuid NOT NULL                                                               +
                     |                            | position integer NOT NULL DEFAULT 0                                                 +
                     |                            | kind text NOT NULL                                                                  +
                     |                            | prompt text NOT NULL                                                                +
                     |                            | options jsonb                                                                       +
                     |                            | correct jsonb NOT NULL                                                              +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 public              | services                   | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | owner uuid                                                                          +
                     |                            | title text NOT NULL                                                                 +
                     |                            | description text                                                                    +
                     |                            | certified_area text                                                                 +
                     |                            | price_cents integer DEFAULT 0                                                       +
                     |                            | created_at timestamp with time zone DEFAULT now()
 public              | subscription_plans         | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | name text NOT NULL                                                                  +
                     |                            | price_cents integer NOT NULL                                                        +
                     |                            | interval text NOT NULL                                                              +
                     |                            | trial_days integer NOT NULL DEFAULT 0                                               +
                     |                            | is_active boolean NOT NULL DEFAULT true                                             +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 public              | subscriptions              | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | plan_id uuid                                                                        +
                     |                            | status text NOT NULL DEFAULT 'active'::text                                         +
                     |                            | amount_cents integer NOT NULL DEFAULT 0                                             +
                     |                            | current_period_end timestamp with time zone                                         +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 public              | tarot_readings             | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | student_id uuid NOT NULL                                                            +
                     |                            | teacher_id uuid                                                                     +
                     |                            | question text NOT NULL                                                              +
                     |                            | delivery_type text NOT NULL                                                         +
                     |                            | status text NOT NULL DEFAULT 'pending'::text                                        +
                     |                            | price integer NOT NULL                                                              +
                     |                            | payment_status text NOT NULL DEFAULT 'pending'::text                                +
                     |                            | stripe_payment_intent_id text                                                       +
                     |                            | response_text text                                                                  +
                     |                            | response_audio_url text                                                             +
                     |                            | response_video_url text                                                             +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | teacher_directory          | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | display_name text                                                                   +
                     |                            | headline text                                                                       +
                     |                            | specialties ARRAY DEFAULT '{}'::text[]                                              +
                     |                            | price_cents integer DEFAULT 0                                                       +
                     |                            | avatar_url text                                                                     +
                     |                            | is_accepting boolean DEFAULT true                                                   +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | teacher_permissions        | user_id uuid NOT NULL                                                               +
                     |                            | granted_by uuid                                                                     +
                     |                            | granted_at timestamp with time zone DEFAULT now()
 public              | teacher_permissions_compat | profile_id uuid                                                                     +
                     |                            | user_id uuid                                                                        +
                     |                            | can_edit_courses boolean                                                            +
                     |                            | can_publish boolean                                                                 +
                     |                            | granted_by uuid                                                                     +
                     |                            | granted_at timestamp with time zone
 public              | teacher_requests           | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | note text                                                                           +
                     |                            | status text NOT NULL DEFAULT 'pending'::text                                        +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 public              | user_certifications        | user_id uuid NOT NULL                                                               +
                     |                            | area text NOT NULL                                                                  +
                     |                            | granted_at timestamp with time zone NOT NULL DEFAULT now()
 public              | user_roles                 | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | user_id uuid NOT NULL                                                               +
                     |                            | role USER-DEFINED NOT NULL DEFAULT 'student'::app_role                              +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 realtime            | messages                   | topic text NOT NULL                                                                 +
                     |                            | extension text NOT NULL                                                             +
                     |                            | payload jsonb                                                                       +
                     |                            | event text                                                                          +
                     |                            | private boolean DEFAULT false                                                       +
                     |                            | updated_at timestamp without time zone NOT NULL DEFAULT now()                       +
                     |                            | inserted_at timestamp without time zone NOT NULL DEFAULT now()                      +
                     |                            | id uuid NOT NULL DEFAULT gen_random_uuid()
 realtime            | schema_migrations          | version bigint NOT NULL                                                             +
                     |                            | inserted_at timestamp without time zone
 realtime            | subscription               | id bigint NOT NULL                                                                  +
                     |                            | subscription_id uuid NOT NULL                                                       +
                     |                            | entity regclass NOT NULL                                                            +
                     |                            | filters ARRAY NOT NULL DEFAULT '{}'::realtime.user_defined_filter[]                 +
                     |                            | claims jsonb NOT NULL                                                               +
                     |                            | claims_role regrole NOT NULL                                                        +
                     |                            | created_at timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now())
 storage             | buckets                    | id text NOT NULL                                                                    +
                     |                            | name text NOT NULL                                                                  +
                     |                            | owner uuid                                                                          +
                     |                            | created_at timestamp with time zone DEFAULT now()                                   +
                     |                            | updated_at timestamp with time zone DEFAULT now()                                   +
                     |                            | public boolean DEFAULT false                                                        +
                     |                            | avif_autodetection boolean DEFAULT false                                            +
                     |                            | file_size_limit bigint                                                              +
                     |                            | allowed_mime_types ARRAY                                                            +
                     |                            | owner_id text                                                                       +
                     |                            | type USER-DEFINED NOT NULL DEFAULT 'STANDARD'::storage.buckettype
 storage             | buckets_analytics          | id text NOT NULL                                                                    +
                     |                            | type USER-DEFINED NOT NULL DEFAULT 'ANALYTICS'::storage.buckettype                  +
                     |                            | format text NOT NULL DEFAULT 'ICEBERG'::text                                        +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT now()
 storage             | migrations                 | id integer NOT NULL                                                                 +
                     |                            | name character varying(100) NOT NULL                                                +
                     |                            | hash character varying(40) NOT NULL                                                 +
                     |                            | executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
 storage             | objects                    | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | bucket_id text                                                                      +
                     |                            | name text                                                                           +
                     |                            | owner uuid                                                                          +
                     |                            | created_at timestamp with time zone DEFAULT now()                                   +
                     |                            | updated_at timestamp with time zone DEFAULT now()                                   +
                     |                            | last_accessed_at timestamp with time zone DEFAULT now()                             +
                     |                            | metadata jsonb                                                                      +
                     |                            | path_tokens ARRAY                                                                   +
                     |                            | version text                                                                        +
                     |                            | owner_id text                                                                       +
                     |                            | user_metadata jsonb                                                                 +
                     |                            | level integer
 storage             | prefixes                   | bucket_id text NOT NULL                                                             +
                     |                            | name text NOT NULL                                                                  +
                     |                            | level integer NOT NULL                                                              +
                     |                            | created_at timestamp with time zone DEFAULT now()                                   +
                     |                            | updated_at timestamp with time zone DEFAULT now()
 storage             | s3_multipart_uploads       | id text NOT NULL                                                                    +
                     |                            | in_progress_size bigint NOT NULL DEFAULT 0                                          +
                     |                            | upload_signature text NOT NULL                                                      +
                     |                            | bucket_id text NOT NULL                                                             +
                     |                            | key text NOT NULL                                                                   +
                     |                            | version text NOT NULL                                                               +
                     |                            | owner_id text                                                                       +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()                          +
                     |                            | user_metadata jsonb
 storage             | s3_multipart_uploads_parts | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | upload_id text NOT NULL                                                             +
                     |                            | size bigint NOT NULL DEFAULT 0                                                      +
                     |                            | part_number integer NOT NULL                                                        +
                     |                            | bucket_id text NOT NULL                                                             +
                     |                            | key text NOT NULL                                                                   +
                     |                            | etag text NOT NULL                                                                  +
                     |                            | owner_id text                                                                       +
                     |                            | version text NOT NULL                                                               +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT now()
 supabase_migrations | schema_migrations          | version text NOT NULL                                                               +
                     |                            | statements ARRAY                                                                    +
                     |                            | name text                                                                           +
                     |                            | created_by text                                                                     +
                     |                            | idempotency_key text
 supabase_migrations | seed_files                 | path text NOT NULL                                                                  +
                     |                            | hash text NOT NULL
 vault               | decrypted_secrets          | id uuid                                                                             +
                     |                            | name text                                                                           +
                     |                            | description text                                                                    +
                     |                            | secret text                                                                         +
                     |                            | decrypted_secret text                                                               +
                     |                            | key_id uuid                                                                         +
                     |                            | nonce bytea                                                                         +
                     |                            | created_at timestamp with time zone                                                 +
                     |                            | updated_at timestamp with time zone
 vault               | secrets                    | id uuid NOT NULL DEFAULT gen_random_uuid()                                          +
                     |                            | name text                                                                           +
                     |                            | description text NOT NULL DEFAULT ''::text                                          +
                     |                            | secret text NOT NULL                                                                +
                     |                            | key_id uuid                                                                         +
                     |                            | nonce bytea DEFAULT vault._crypto_aead_det_noncegen()                               +
                     |                            | created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP              +
                     |                            | updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
(93 rows)

 ?column? 
----------
 
(1 row)

     ?column?     
------------------
 ## Primärnycklar
(1 row)

       schema        |           table            |                       pk_def                       
---------------------+----------------------------+----------------------------------------------------
 app                 | app_config                 | PRIMARY KEY (id)
 app                 | bookings                   | PRIMARY KEY (id)
 app                 | certificates               | PRIMARY KEY (id)
 app                 | certifications             | PRIMARY KEY (id)
 app                 | courses                    | PRIMARY KEY (id)
 app                 | drip_plans                 | PRIMARY KEY (id)
 app                 | drip_rules                 | PRIMARY KEY (id)
 app                 | editor_styles              | PRIMARY KEY (id)
 app                 | enrollments                | PRIMARY KEY (id)
 app                 | events                     | PRIMARY KEY (id)
 app                 | guest_claim_tokens         | PRIMARY KEY (token)
 app                 | lesson_media               | PRIMARY KEY (id)
 app                 | lessons                    | PRIMARY KEY (id)
 app                 | magic_links                | PRIMARY KEY (id)
 app                 | meditations                | PRIMARY KEY (id)
 app                 | memberships                | PRIMARY KEY (user_id)
 app                 | messages                   | PRIMARY KEY (id)
 app                 | modules                    | PRIMARY KEY (id)
 app                 | notification_jobs          | PRIMARY KEY (id)
 app                 | notification_templates     | PRIMARY KEY (id)
 app                 | orders                     | PRIMARY KEY (id)
 app                 | pro_progress               | PRIMARY KEY (user_id, requirement_id)
 app                 | pro_requirements           | PRIMARY KEY (id)
 app                 | profiles                   | PRIMARY KEY (user_id)
 app                 | purchases                  | PRIMARY KEY (id)
 app                 | services                   | PRIMARY KEY (id)
 app                 | tarot_requests             | PRIMARY KEY (id)
 app                 | teacher_approvals          | PRIMARY KEY (user_id)
 app                 | teacher_directory          | PRIMARY KEY (user_id)
 app                 | teacher_permissions        | PRIMARY KEY (profile_id)
 app                 | teacher_requests           | PRIMARY KEY (id)
 app                 | teacher_slots              | PRIMARY KEY (id)
 auth                | audit_log_entries          | PRIMARY KEY (id)
 auth                | flow_state                 | PRIMARY KEY (id)
 auth                | identities                 | PRIMARY KEY (id)
 auth                | instances                  | PRIMARY KEY (id)
 auth                | mfa_amr_claims             | PRIMARY KEY (id)
 auth                | mfa_challenges             | PRIMARY KEY (id)
 auth                | mfa_factors                | PRIMARY KEY (id)
 auth                | oauth_clients              | PRIMARY KEY (id)
 auth                | one_time_tokens            | PRIMARY KEY (id)
 auth                | refresh_tokens             | PRIMARY KEY (id)
 auth                | saml_providers             | PRIMARY KEY (id)
 auth                | saml_relay_states          | PRIMARY KEY (id)
 auth                | schema_migrations          | PRIMARY KEY (version)
 auth                | sessions                   | PRIMARY KEY (id)
 auth                | sso_domains                | PRIMARY KEY (id)
 auth                | sso_providers              | PRIMARY KEY (id)
 auth                | users                      | PRIMARY KEY (id)
 pg_catalog          | pg_aggregate               | PRIMARY KEY (aggfnoid)
 pg_catalog          | pg_am                      | PRIMARY KEY (oid)
 pg_catalog          | pg_amop                    | PRIMARY KEY (oid)
 pg_catalog          | pg_amproc                  | PRIMARY KEY (oid)
 pg_catalog          | pg_attrdef                 | PRIMARY KEY (oid)
 pg_catalog          | pg_attribute               | PRIMARY KEY (attrelid, attnum)
 pg_catalog          | pg_auth_members            | PRIMARY KEY (oid)
 pg_catalog          | pg_authid                  | PRIMARY KEY (oid)
 pg_catalog          | pg_cast                    | PRIMARY KEY (oid)
 pg_catalog          | pg_class                   | PRIMARY KEY (oid)
 pg_catalog          | pg_collation               | PRIMARY KEY (oid)
 pg_catalog          | pg_constraint              | PRIMARY KEY (oid)
 pg_catalog          | pg_conversion              | PRIMARY KEY (oid)
 pg_catalog          | pg_database                | PRIMARY KEY (oid)
 pg_catalog          | pg_db_role_setting         | PRIMARY KEY (setdatabase, setrole)
 pg_catalog          | pg_default_acl             | PRIMARY KEY (oid)
 pg_catalog          | pg_description             | PRIMARY KEY (objoid, classoid, objsubid)
 pg_catalog          | pg_enum                    | PRIMARY KEY (oid)
 pg_catalog          | pg_event_trigger           | PRIMARY KEY (oid)
 pg_catalog          | pg_extension               | PRIMARY KEY (oid)
 pg_catalog          | pg_foreign_data_wrapper    | PRIMARY KEY (oid)
 pg_catalog          | pg_foreign_server          | PRIMARY KEY (oid)
 pg_catalog          | pg_foreign_table           | PRIMARY KEY (ftrelid)
 pg_catalog          | pg_index                   | PRIMARY KEY (indexrelid)
 pg_catalog          | pg_inherits                | PRIMARY KEY (inhrelid, inhseqno)
 pg_catalog          | pg_init_privs              | PRIMARY KEY (objoid, classoid, objsubid)
 pg_catalog          | pg_language                | PRIMARY KEY (oid)
 pg_catalog          | pg_largeobject             | PRIMARY KEY (loid, pageno)
 pg_catalog          | pg_largeobject_metadata    | PRIMARY KEY (oid)
 pg_catalog          | pg_namespace               | PRIMARY KEY (oid)
 pg_catalog          | pg_opclass                 | PRIMARY KEY (oid)
 pg_catalog          | pg_operator                | PRIMARY KEY (oid)
 pg_catalog          | pg_opfamily                | PRIMARY KEY (oid)
 pg_catalog          | pg_parameter_acl           | PRIMARY KEY (oid)
 pg_catalog          | pg_partitioned_table       | PRIMARY KEY (partrelid)
 pg_catalog          | pg_policy                  | PRIMARY KEY (oid)
 pg_catalog          | pg_proc                    | PRIMARY KEY (oid)
 pg_catalog          | pg_publication             | PRIMARY KEY (oid)
 pg_catalog          | pg_publication_namespace   | PRIMARY KEY (oid)
 pg_catalog          | pg_publication_rel         | PRIMARY KEY (oid)
 pg_catalog          | pg_range                   | PRIMARY KEY (rngtypid)
 pg_catalog          | pg_replication_origin      | PRIMARY KEY (roident)
 pg_catalog          | pg_rewrite                 | PRIMARY KEY (oid)
 pg_catalog          | pg_seclabel                | PRIMARY KEY (objoid, classoid, objsubid, provider)
 pg_catalog          | pg_sequence                | PRIMARY KEY (seqrelid)
 pg_catalog          | pg_shdescription           | PRIMARY KEY (objoid, classoid)
 pg_catalog          | pg_shseclabel              | PRIMARY KEY (objoid, classoid, provider)
 pg_catalog          | pg_statistic               | PRIMARY KEY (starelid, staattnum, stainherit)
 pg_catalog          | pg_statistic_ext           | PRIMARY KEY (oid)
 pg_catalog          | pg_statistic_ext_data      | PRIMARY KEY (stxoid, stxdinherit)
 pg_catalog          | pg_subscription            | PRIMARY KEY (oid)
 pg_catalog          | pg_subscription_rel        | PRIMARY KEY (srrelid, srsubid)
 pg_catalog          | pg_tablespace              | PRIMARY KEY (oid)
 pg_catalog          | pg_transform               | PRIMARY KEY (oid)
 pg_catalog          | pg_trigger                 | PRIMARY KEY (oid)
 pg_catalog          | pg_ts_config               | PRIMARY KEY (oid)
 pg_catalog          | pg_ts_config_map           | PRIMARY KEY (mapcfg, maptokentype, mapseqno)
 pg_catalog          | pg_ts_dict                 | PRIMARY KEY (oid)
 pg_catalog          | pg_ts_parser               | PRIMARY KEY (oid)
 pg_catalog          | pg_ts_template             | PRIMARY KEY (oid)
 pg_catalog          | pg_type                    | PRIMARY KEY (oid)
 pg_catalog          | pg_user_mapping            | PRIMARY KEY (oid)
 public              | admin_keys                 | PRIMARY KEY (code)
 public              | availability_slots         | PRIMARY KEY (id)
 public              | bookings                   | PRIMARY KEY (id)
 public              | certificates               | PRIMARY KEY (id)
 public              | coupons                    | PRIMARY KEY (code)
 public              | course_enrollments         | PRIMARY KEY (id)
 public              | course_modules             | PRIMARY KEY (id)
 public              | course_quizzes             | PRIMARY KEY (id)
 public              | courses                    | PRIMARY KEY (id)
 public              | lesson_media               | PRIMARY KEY (id)
 public              | lessons                    | PRIMARY KEY (id)
 public              | messages                   | PRIMARY KEY (id)
 public              | modules                    | PRIMARY KEY (id)
 public              | notifications              | PRIMARY KEY (id)
 public              | profiles                   | PRIMARY KEY (id)
 public              | public_teacher_info        | PRIMARY KEY (id)
 public              | quiz_attempts              | PRIMARY KEY (id)
 public              | quiz_questions             | PRIMARY KEY (id)
 public              | services                   | PRIMARY KEY (id)
 public              | subscription_plans         | PRIMARY KEY (id)
 public              | subscriptions              | PRIMARY KEY (id)
 public              | tarot_readings             | PRIMARY KEY (id)
 public              | teacher_directory          | PRIMARY KEY (id)
 public              | teacher_permissions        | PRIMARY KEY (user_id)
 public              | teacher_requests           | PRIMARY KEY (id)
 public              | user_certifications        | PRIMARY KEY (user_id, area)
 public              | user_roles                 | PRIMARY KEY (id)
 realtime            | messages                   | PRIMARY KEY (id, inserted_at)
 realtime            | schema_migrations          | PRIMARY KEY (version)
 realtime            | subscription               | PRIMARY KEY (id)
 storage             | buckets                    | PRIMARY KEY (id)
 storage             | buckets_analytics          | PRIMARY KEY (id)
 storage             | migrations                 | PRIMARY KEY (id)
 storage             | objects                    | PRIMARY KEY (id)
 storage             | prefixes                   | PRIMARY KEY (bucket_id, level, name)
 storage             | s3_multipart_uploads       | PRIMARY KEY (id)
 storage             | s3_multipart_uploads_parts | PRIMARY KEY (id)
 supabase_migrations | schema_migrations          | PRIMARY KEY (version)
 supabase_migrations | seed_files                 | PRIMARY KEY (path)
 vault               | secrets                    | PRIMARY KEY (id)
(151 rows)

 ?column? 
----------
 
(1 row)

       ?column?       
----------------------
 ## Utländska nycklar
(1 row)

 schema  |           table            |                  fk_name                  |                                            fk_def                                             
---------+----------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------
 app     | bookings                   | bookings_slot_id_fkey                     | FOREIGN KEY (slot_id) REFERENCES app.teacher_slots(id) ON DELETE CASCADE
 app     | bookings                   | bookings_order_id_fkey                    | FOREIGN KEY (order_id) REFERENCES app.orders(id) ON DELETE SET NULL
 app     | bookings                   | bookings_user_id_fkey                     | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | certificates               | certificates_user_id_fkey                 | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | certifications             | certifications_user_id_fkey               | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | certifications             | certifications_course_id_fkey             | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | courses                    | courses_created_by_fkey                   | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE SET NULL
 app     | drip_plans                 | drip_plans_course_id_fkey                 | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | drip_plans                 | drip_plans_created_by_fkey                | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | drip_rules                 | drip_rules_module_id_fkey                 | FOREIGN KEY (module_id) REFERENCES app.modules(id) ON DELETE CASCADE
 app     | drip_rules                 | drip_rules_created_by_fkey                | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | drip_rules                 | drip_rules_notify_template_id_fkey        | FOREIGN KEY (notify_template_id) REFERENCES app.notification_templates(id) ON DELETE SET NULL
 app     | drip_rules                 | drip_rules_page_id_fkey                   | FOREIGN KEY (page_id) REFERENCES app.lessons(id) ON DELETE SET NULL
 app     | drip_rules                 | drip_rules_plan_id_fkey                   | FOREIGN KEY (plan_id) REFERENCES app.drip_plans(id) ON DELETE CASCADE
 app     | editor_styles              | editor_styles_created_by_fkey             | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | editor_styles              | editor_styles_course_id_fkey              | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | enrollments                | enrollments_user_id_fkey                  | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | enrollments                | enrollments_course_id_fkey                | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | events                     | events_created_by_fkey                    | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE SET NULL
 app     | guest_claim_tokens         | guest_claim_tokens_course_id_fkey         | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | guest_claim_tokens         | guest_claim_tokens_purchase_id_fkey       | FOREIGN KEY (purchase_id) REFERENCES app.purchases(id) ON DELETE CASCADE
 app     | lesson_media               | lesson_media_lesson_id_fkey               | FOREIGN KEY (lesson_id) REFERENCES app.lessons(id) ON DELETE CASCADE
 app     | lessons                    | lessons_module_id_fkey                    | FOREIGN KEY (module_id) REFERENCES app.modules(id) ON DELETE CASCADE
 app     | magic_links                | magic_links_course_id_fkey                | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | magic_links                | magic_links_created_by_fkey               | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | magic_links                | magic_links_style_id_fkey                 | FOREIGN KEY (style_id) REFERENCES app.editor_styles(id) ON DELETE SET NULL
 app     | meditations                | meditations_teacher_id_fkey               | FOREIGN KEY (teacher_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | memberships                | memberships_user_id_fkey                  | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | messages                   | messages_sender_id_fkey                   | FOREIGN KEY (sender_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | modules                    | modules_course_id_fkey                    | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | notification_jobs          | notification_jobs_created_by_fkey         | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | notification_jobs          | notification_jobs_user_id_fkey            | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | notification_jobs          | notification_jobs_course_id_fkey          | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | notification_jobs          | notification_jobs_module_id_fkey          | FOREIGN KEY (module_id) REFERENCES app.modules(id) ON DELETE CASCADE
 app     | notification_jobs          | notification_jobs_page_id_fkey            | FOREIGN KEY (page_id) REFERENCES app.lessons(id) ON DELETE SET NULL
 app     | notification_jobs          | notification_jobs_template_id_fkey        | FOREIGN KEY (template_id) REFERENCES app.notification_templates(id) ON DELETE SET NULL
 app     | notification_templates     | notification_templates_created_by_fkey    | FOREIGN KEY (created_by) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | notification_templates     | notification_templates_course_id_fkey     | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | orders                     | orders_course_id_fkey                     | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE SET NULL
 app     | orders                     | orders_user_id_fkey                       | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | orders                     | fk_orders_service_id                      | FOREIGN KEY (service_id) REFERENCES app.services(id) ON DELETE SET NULL
 app     | pro_progress               | pro_progress_requirement_id_fkey          | FOREIGN KEY (requirement_id) REFERENCES app.pro_requirements(id) ON DELETE CASCADE
 app     | pro_progress               | pro_progress_user_id_fkey                 | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | profiles                   | profiles_user_id_fkey                     | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 app     | purchases                  | purchases_user_id_fkey                    | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE SET NULL
 app     | purchases                  | purchases_course_id_fkey                  | FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE
 app     | purchases                  | purchases_order_id_fkey                   | FOREIGN KEY (order_id) REFERENCES app.orders(id) ON DELETE SET NULL
 app     | services                   | services_provider_id_fkey                 | FOREIGN KEY (provider_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | tarot_requests             | tarot_requests_order_id_fkey              | FOREIGN KEY (order_id) REFERENCES app.orders(id) ON DELETE SET NULL
 app     | tarot_requests             | tarot_requests_requester_id_fkey          | FOREIGN KEY (requester_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | tarot_requests             | tarot_requests_reader_id_fkey             | FOREIGN KEY (reader_id) REFERENCES app.profiles(user_id) ON DELETE SET NULL
 app     | teacher_approvals          | teacher_approvals_user_id_fkey            | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | teacher_directory          | teacher_directory_user_id_fkey            | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | teacher_permissions        | teacher_permissions_profile_id_fkey       | FOREIGN KEY (profile_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | teacher_requests           | teacher_requests_user_id_fkey             | FOREIGN KEY (user_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 app     | teacher_requests           | teacher_requests_reviewed_by_fkey         | FOREIGN KEY (reviewed_by) REFERENCES app.profiles(user_id)
 app     | teacher_slots              | teacher_slots_teacher_id_fkey             | FOREIGN KEY (teacher_id) REFERENCES app.profiles(user_id) ON DELETE CASCADE
 auth    | identities                 | identities_user_id_fkey                   | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 auth    | mfa_amr_claims             | mfa_amr_claims_session_id_fkey            | FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE
 auth    | mfa_challenges             | mfa_challenges_auth_factor_id_fkey        | FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE
 auth    | mfa_factors                | mfa_factors_user_id_fkey                  | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 auth    | one_time_tokens            | one_time_tokens_user_id_fkey              | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 auth    | refresh_tokens             | refresh_tokens_session_id_fkey            | FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE
 auth    | saml_providers             | saml_providers_sso_provider_id_fkey       | FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE
 auth    | saml_relay_states          | saml_relay_states_flow_state_id_fkey      | FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE
 auth    | saml_relay_states          | saml_relay_states_sso_provider_id_fkey    | FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE
 auth    | sessions                   | sessions_user_id_fkey                     | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 auth    | sso_domains                | sso_domains_sso_provider_id_fkey          | FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE
 public  | admin_keys                 | admin_keys_redeemed_by_fkey               | FOREIGN KEY (redeemed_by) REFERENCES auth.users(id)
 public  | admin_keys                 | admin_keys_issued_by_fkey                 | FOREIGN KEY (issued_by) REFERENCES auth.users(id)
 public  | availability_slots         | availability_slots_teacher_id_fkey        | FOREIGN KEY (teacher_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | bookings                   | bookings_student_id_fkey                  | FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | bookings                   | bookings_teacher_id_fkey                  | FOREIGN KEY (teacher_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | bookings                   | bookings_slot_id_fkey                     | FOREIGN KEY (slot_id) REFERENCES availability_slots(id) ON DELETE CASCADE
 public  | certificates               | certificates_course_id_fkey               | FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
 public  | certificates               | certificates_user_id_fkey                 | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | coupons                    | coupons_plan_id_fkey                      | FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE SET NULL
 public  | coupons                    | coupons_issued_by_fkey                    | FOREIGN KEY (issued_by) REFERENCES auth.users(id)
 public  | course_modules             | course_modules_course_id_fkey             | FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
 public  | course_modules             | course_modules_created_by_fkey            | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL
 public  | course_quizzes             | course_quizzes_course_id_fkey             | FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
 public  | course_quizzes             | course_quizzes_created_by_fkey            | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL
 public  | courses                    | courses_created_by_fkey                   | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL
 public  | courses                    | courses_teacher_id_fkey                   | FOREIGN KEY (teacher_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | messages                   | messages_recipient_id_fkey                | FOREIGN KEY (recipient_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | messages                   | messages_course_id_fkey                   | FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
 public  | messages                   | messages_parent_message_id_fkey           | FOREIGN KEY (parent_message_id) REFERENCES messages(id) ON DELETE CASCADE
 public  | messages                   | messages_sender_id_fkey                   | FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | notifications              | notifications_user_id_fkey                | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | profiles                   | profiles_user_id_fkey                     | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | quiz_attempts              | quiz_attempts_quiz_id_fkey                | FOREIGN KEY (quiz_id) REFERENCES course_quizzes(id) ON DELETE CASCADE
 public  | quiz_attempts              | quiz_attempts_user_id_fkey                | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | quiz_questions             | quiz_questions_quiz_id_fkey               | FOREIGN KEY (quiz_id) REFERENCES course_quizzes(id) ON DELETE CASCADE
 public  | services                   | services_owner_fkey                       | FOREIGN KEY (owner) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | subscriptions              | subscriptions_plan_id_fkey                | FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE SET NULL
 public  | subscriptions              | subscriptions_user_id_fkey                | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | tarot_readings             | tarot_readings_student_id_fkey            | FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | tarot_readings             | tarot_readings_teacher_id_fkey            | FOREIGN KEY (teacher_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | teacher_permissions        | teacher_permissions_granted_by_fkey       | FOREIGN KEY (granted_by) REFERENCES auth.users(id)
 public  | teacher_permissions        | teacher_permissions_user_id_fkey          | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | user_certifications        | user_certifications_user_id_fkey          | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 public  | user_roles                 | user_roles_user_id_fkey                   | FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
 storage | objects                    | objects_bucketId_fkey                     | FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
 storage | prefixes                   | prefixes_bucketId_fkey                    | FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
 storage | s3_multipart_uploads       | s3_multipart_uploads_bucket_id_fkey       | FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
 storage | s3_multipart_uploads_parts | s3_multipart_uploads_parts_upload_id_fkey | FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE
 storage | s3_multipart_uploads_parts | s3_multipart_uploads_parts_bucket_id_fkey | FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
(107 rows)

 ?column? 
----------
 
(1 row)

 ?column? 
----------
 ## Index
(1 row)

       schema        |           table            |                        index                         |                                                                                               indexdef                                                                                               
---------------------+----------------------------+------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 app                 | app_config                 | app_config_pkey                                      | CREATE UNIQUE INDEX app_config_pkey ON app.app_config USING btree (id)
 app                 | bookings                   | bookings_pkey                                        | CREATE UNIQUE INDEX bookings_pkey ON app.bookings USING btree (id)
 app                 | bookings                   | bookings_slot_id_key                                 | CREATE UNIQUE INDEX bookings_slot_id_key ON app.bookings USING btree (slot_id)
 app                 | certificates               | certificates_pkey                                    | CREATE UNIQUE INDEX certificates_pkey ON app.certificates USING btree (id)
 app                 | certificates               | certificates_user_title_key                          | CREATE UNIQUE INDEX certificates_user_title_key ON app.certificates USING btree (user_id, title)
 app                 | certificates               | idx_certificates_user_title                          | CREATE UNIQUE INDEX idx_certificates_user_title ON app.certificates USING btree (user_id, title)
 app                 | certifications             | certifications_pkey                                  | CREATE UNIQUE INDEX certifications_pkey ON app.certifications USING btree (id)
 app                 | certifications             | certifications_user_id_course_id_key                 | CREATE UNIQUE INDEX certifications_user_id_course_id_key ON app.certifications USING btree (user_id, course_id)
 app                 | courses                    | courses_pkey                                         | CREATE UNIQUE INDEX courses_pkey ON app.courses USING btree (id)
 app                 | courses                    | courses_slug_key                                     | CREATE UNIQUE INDEX courses_slug_key ON app.courses USING btree (slug)
 app                 | courses                    | idx_courses_branch                                   | CREATE INDEX idx_courses_branch ON app.courses USING btree (branch)
 app                 | courses                    | idx_courses_created_by                               | CREATE INDEX idx_courses_created_by ON app.courses USING btree (created_by)
 app                 | courses                    | idx_courses_is_free_intro                            | CREATE INDEX idx_courses_is_free_intro ON app.courses USING btree (is_free_intro)
 app                 | drip_plans                 | drip_plans_pkey                                      | CREATE UNIQUE INDEX drip_plans_pkey ON app.drip_plans USING btree (id)
 app                 | drip_plans                 | idx_drip_plans_course                                | CREATE INDEX idx_drip_plans_course ON app.drip_plans USING btree (course_id)
 app                 | drip_rules                 | drip_rules_pkey                                      | CREATE UNIQUE INDEX drip_rules_pkey ON app.drip_rules USING btree (id)
 app                 | drip_rules                 | idx_drip_rules_plan                                  | CREATE INDEX idx_drip_rules_plan ON app.drip_rules USING btree (plan_id)
 app                 | drip_rules                 | uq_drip_rules                                        | CREATE UNIQUE INDEX uq_drip_rules ON app.drip_rules USING btree (plan_id, module_id, COALESCE(page_id, '00000000-0000-0000-0000-000000000000'::uuid))
 app                 | editor_styles              | editor_styles_pkey                                   | CREATE UNIQUE INDEX editor_styles_pkey ON app.editor_styles USING btree (id)
 app                 | editor_styles              | idx_editor_styles_course                             | CREATE INDEX idx_editor_styles_course ON app.editor_styles USING btree (course_id)
 app                 | enrollments                | enrollments_pkey                                     | CREATE UNIQUE INDEX enrollments_pkey ON app.enrollments USING btree (id)
 app                 | enrollments                | enrollments_user_id_course_id_key                    | CREATE UNIQUE INDEX enrollments_user_id_course_id_key ON app.enrollments USING btree (user_id, course_id)
 app                 | enrollments                | idx_enroll_course                                    | CREATE INDEX idx_enroll_course ON app.enrollments USING btree (course_id)
 app                 | enrollments                | idx_enroll_user                                      | CREATE INDEX idx_enroll_user ON app.enrollments USING btree (user_id)
 app                 | events                     | events_pkey                                          | CREATE UNIQUE INDEX events_pkey ON app.events USING btree (id)
 app                 | guest_claim_tokens         | guest_claim_tokens_pkey                              | CREATE UNIQUE INDEX guest_claim_tokens_pkey ON app.guest_claim_tokens USING btree (token)
 app                 | guest_claim_tokens         | idx_guest_claim_email                                | CREATE INDEX idx_guest_claim_email ON app.guest_claim_tokens USING btree (buyer_email)
 app                 | guest_claim_tokens         | idx_guest_claim_purchase                             | CREATE INDEX idx_guest_claim_purchase ON app.guest_claim_tokens USING btree (purchase_id)
 app                 | lesson_media               | idx_media_lesson                                     | CREATE INDEX idx_media_lesson ON app.lesson_media USING btree (lesson_id)
 app                 | lesson_media               | lesson_media_lesson_id_position_key                  | CREATE UNIQUE INDEX lesson_media_lesson_id_position_key ON app.lesson_media USING btree (lesson_id, "position")
 app                 | lesson_media               | lesson_media_pkey                                    | CREATE UNIQUE INDEX lesson_media_pkey ON app.lesson_media USING btree (id)
 app                 | lessons                    | idx_lessons_module                                   | CREATE INDEX idx_lessons_module ON app.lessons USING btree (module_id)
 app                 | lessons                    | lessons_module_id_position_key                       | CREATE UNIQUE INDEX lessons_module_id_position_key ON app.lessons USING btree (module_id, "position")
 app                 | lessons                    | lessons_pkey                                         | CREATE UNIQUE INDEX lessons_pkey ON app.lessons USING btree (id)
 app                 | magic_links                | idx_magic_links_course                               | CREATE INDEX idx_magic_links_course ON app.magic_links USING btree (course_id)
 app                 | magic_links                | magic_links_pkey                                     | CREATE UNIQUE INDEX magic_links_pkey ON app.magic_links USING btree (id)
 app                 | meditations                | idx_meditations_teacher                              | CREATE INDEX idx_meditations_teacher ON app.meditations USING btree (teacher_id)
 app                 | meditations                | meditations_pkey                                     | CREATE UNIQUE INDEX meditations_pkey ON app.meditations USING btree (id)
 app                 | memberships                | memberships_pkey                                     | CREATE UNIQUE INDEX memberships_pkey ON app.memberships USING btree (user_id)
 app                 | messages                   | idx_messages_channel                                 | CREATE INDEX idx_messages_channel ON app.messages USING btree (channel)
 app                 | messages                   | idx_messages_sender                                  | CREATE INDEX idx_messages_sender ON app.messages USING btree (sender_id)
 app                 | messages                   | messages_pkey                                        | CREATE UNIQUE INDEX messages_pkey ON app.messages USING btree (id)
 app                 | modules                    | idx_modules_course                                   | CREATE INDEX idx_modules_course ON app.modules USING btree (course_id)
 app                 | modules                    | modules_course_id_position_key                       | CREATE UNIQUE INDEX modules_course_id_position_key ON app.modules USING btree (course_id, "position")
 app                 | modules                    | modules_pkey                                         | CREATE UNIQUE INDEX modules_pkey ON app.modules USING btree (id)
 app                 | notification_jobs          | idx_notif_jobs_due                                   | CREATE INDEX idx_notif_jobs_due ON app.notification_jobs USING btree (status, scheduled_at)
 app                 | notification_jobs          | notification_jobs_pkey                               | CREATE UNIQUE INDEX notification_jobs_pkey ON app.notification_jobs USING btree (id)
 app                 | notification_jobs          | uq_notification_jobs_natural                         | CREATE UNIQUE INDEX uq_notification_jobs_natural ON app.notification_jobs USING btree (user_id, course_id, module_id, COALESCE(page_id, '00000000-0000-0000-0000-000000000000'::uuid), scheduled_at)
 app                 | notification_templates     | notification_templates_pkey                          | CREATE UNIQUE INDEX notification_templates_pkey ON app.notification_templates USING btree (id)
 app                 | orders                     | idx_orders_service                                   | CREATE INDEX idx_orders_service ON app.orders USING btree (service_id)
 app                 | orders                     | idx_orders_status                                    | CREATE INDEX idx_orders_status ON app.orders USING btree (status)
 app                 | orders                     | idx_orders_user                                      | CREATE INDEX idx_orders_user ON app.orders USING btree (user_id)
 app                 | orders                     | orders_pkey                                          | CREATE UNIQUE INDEX orders_pkey ON app.orders USING btree (id)
 app                 | pro_progress               | pro_progress_pkey                                    | CREATE UNIQUE INDEX pro_progress_pkey ON app.pro_progress USING btree (user_id, requirement_id)
 app                 | pro_requirements           | pro_requirements_code_key                            | CREATE UNIQUE INDEX pro_requirements_code_key ON app.pro_requirements USING btree (code)
 app                 | pro_requirements           | pro_requirements_pkey                                | CREATE UNIQUE INDEX pro_requirements_pkey ON app.pro_requirements USING btree (id)
 app                 | profiles                   | idx_profiles_role                                    | CREATE INDEX idx_profiles_role ON app.profiles USING btree (role)
 app                 | profiles                   | profiles_email_key                                   | CREATE UNIQUE INDEX profiles_email_key ON app.profiles USING btree (email)
 app                 | profiles                   | profiles_pkey                                        | CREATE UNIQUE INDEX profiles_pkey ON app.profiles USING btree (user_id)
 app                 | purchases                  | idx_purchases_course                                 | CREATE INDEX idx_purchases_course ON app.purchases USING btree (course_id)
 app                 | purchases                  | idx_purchases_email                                  | CREATE INDEX idx_purchases_email ON app.purchases USING btree (buyer_email)
 app                 | purchases                  | idx_purchases_order                                  | CREATE UNIQUE INDEX idx_purchases_order ON app.purchases USING btree (order_id) WHERE (order_id IS NOT NULL)
 app                 | purchases                  | idx_purchases_user                                   | CREATE INDEX idx_purchases_user ON app.purchases USING btree (user_id)
 app                 | purchases                  | purchases_pkey                                       | CREATE UNIQUE INDEX purchases_pkey ON app.purchases USING btree (id)
 app                 | purchases                  | purchases_stripe_checkout_id_key                     | CREATE UNIQUE INDEX purchases_stripe_checkout_id_key ON app.purchases USING btree (stripe_checkout_id)
 app                 | purchases                  | purchases_stripe_payment_intent_key                  | CREATE UNIQUE INDEX purchases_stripe_payment_intent_key ON app.purchases USING btree (stripe_payment_intent)
 app                 | services                   | idx_services_provider                                | CREATE INDEX idx_services_provider ON app.services USING btree (provider_id)
 app                 | services                   | services_pkey                                        | CREATE UNIQUE INDEX services_pkey ON app.services USING btree (id)
 app                 | tarot_requests             | tarot_requests_pkey                                  | CREATE UNIQUE INDEX tarot_requests_pkey ON app.tarot_requests USING btree (id)
 app                 | teacher_approvals          | teacher_approvals_pkey                               | CREATE UNIQUE INDEX teacher_approvals_pkey ON app.teacher_approvals USING btree (user_id)
 app                 | teacher_directory          | teacher_directory_pkey                               | CREATE UNIQUE INDEX teacher_directory_pkey ON app.teacher_directory USING btree (user_id)
 app                 | teacher_permissions        | teacher_permissions_pkey                             | CREATE UNIQUE INDEX teacher_permissions_pkey ON app.teacher_permissions USING btree (profile_id)
 app                 | teacher_requests           | teacher_requests_pkey                                | CREATE UNIQUE INDEX teacher_requests_pkey ON app.teacher_requests USING btree (id)
 app                 | teacher_requests           | teacher_requests_user_id_key                         | CREATE UNIQUE INDEX teacher_requests_user_id_key ON app.teacher_requests USING btree (user_id)
 app                 | teacher_slots              | idx_slots_teacher                                    | CREATE INDEX idx_slots_teacher ON app.teacher_slots USING btree (teacher_id)
 app                 | teacher_slots              | teacher_slots_pkey                                   | CREATE UNIQUE INDEX teacher_slots_pkey ON app.teacher_slots USING btree (id)
 auth                | audit_log_entries          | audit_log_entries_pkey                               | CREATE UNIQUE INDEX audit_log_entries_pkey ON auth.audit_log_entries USING btree (id)
 auth                | audit_log_entries          | audit_logs_instance_id_idx                           | CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id)
 auth                | flow_state                 | flow_state_created_at_idx                            | CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC)
 auth                | flow_state                 | flow_state_pkey                                      | CREATE UNIQUE INDEX flow_state_pkey ON auth.flow_state USING btree (id)
 auth                | flow_state                 | idx_auth_code                                        | CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code)
 auth                | flow_state                 | idx_user_id_auth_method                              | CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method)
 auth                | identities                 | identities_email_idx                                 | CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops)
 auth                | identities                 | identities_pkey                                      | CREATE UNIQUE INDEX identities_pkey ON auth.identities USING btree (id)
 auth                | identities                 | identities_provider_id_provider_unique               | CREATE UNIQUE INDEX identities_provider_id_provider_unique ON auth.identities USING btree (provider_id, provider)
 auth                | identities                 | identities_user_id_idx                               | CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id)
 auth                | instances                  | instances_pkey                                       | CREATE UNIQUE INDEX instances_pkey ON auth.instances USING btree (id)
 auth                | mfa_amr_claims             | amr_id_pk                                            | CREATE UNIQUE INDEX amr_id_pk ON auth.mfa_amr_claims USING btree (id)
 auth                | mfa_amr_claims             | mfa_amr_claims_session_id_authentication_method_pkey | CREATE UNIQUE INDEX mfa_amr_claims_session_id_authentication_method_pkey ON auth.mfa_amr_claims USING btree (session_id, authentication_method)
 auth                | mfa_challenges             | mfa_challenge_created_at_idx                         | CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC)
 auth                | mfa_challenges             | mfa_challenges_pkey                                  | CREATE UNIQUE INDEX mfa_challenges_pkey ON auth.mfa_challenges USING btree (id)
 auth                | mfa_factors                | factor_id_created_at_idx                             | CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at)
 auth                | mfa_factors                | mfa_factors_last_challenged_at_key                   | CREATE UNIQUE INDEX mfa_factors_last_challenged_at_key ON auth.mfa_factors USING btree (last_challenged_at)
 auth                | mfa_factors                | mfa_factors_pkey                                     | CREATE UNIQUE INDEX mfa_factors_pkey ON auth.mfa_factors USING btree (id)
 auth                | mfa_factors                | mfa_factors_user_friendly_name_unique                | CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text)
 auth                | mfa_factors                | mfa_factors_user_id_idx                              | CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id)
 auth                | mfa_factors                | unique_phone_factor_per_user                         | CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone)
 auth                | oauth_clients              | oauth_clients_client_id_idx                          | CREATE INDEX oauth_clients_client_id_idx ON auth.oauth_clients USING btree (client_id)
 auth                | oauth_clients              | oauth_clients_client_id_key                          | CREATE UNIQUE INDEX oauth_clients_client_id_key ON auth.oauth_clients USING btree (client_id)
 auth                | oauth_clients              | oauth_clients_deleted_at_idx                         | CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at)
 auth                | oauth_clients              | oauth_clients_pkey                                   | CREATE UNIQUE INDEX oauth_clients_pkey ON auth.oauth_clients USING btree (id)
 auth                | one_time_tokens            | one_time_tokens_pkey                                 | CREATE UNIQUE INDEX one_time_tokens_pkey ON auth.one_time_tokens USING btree (id)
 auth                | one_time_tokens            | one_time_tokens_relates_to_hash_idx                  | CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to)
 auth                | one_time_tokens            | one_time_tokens_token_hash_hash_idx                  | CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash)
 auth                | one_time_tokens            | one_time_tokens_user_id_token_type_key               | CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type)
 auth                | refresh_tokens             | refresh_tokens_instance_id_idx                       | CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id)
 auth                | refresh_tokens             | refresh_tokens_instance_id_user_id_idx               | CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id)
 auth                | refresh_tokens             | refresh_tokens_parent_idx                            | CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent)
 auth                | refresh_tokens             | refresh_tokens_pkey                                  | CREATE UNIQUE INDEX refresh_tokens_pkey ON auth.refresh_tokens USING btree (id)
 auth                | refresh_tokens             | refresh_tokens_session_id_revoked_idx                | CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked)
 auth                | refresh_tokens             | refresh_tokens_token_unique                          | CREATE UNIQUE INDEX refresh_tokens_token_unique ON auth.refresh_tokens USING btree (token)
 auth                | refresh_tokens             | refresh_tokens_updated_at_idx                        | CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC)
 auth                | saml_providers             | saml_providers_entity_id_key                         | CREATE UNIQUE INDEX saml_providers_entity_id_key ON auth.saml_providers USING btree (entity_id)
 auth                | saml_providers             | saml_providers_pkey                                  | CREATE UNIQUE INDEX saml_providers_pkey ON auth.saml_providers USING btree (id)
 auth                | saml_providers             | saml_providers_sso_provider_id_idx                   | CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id)
 auth                | saml_relay_states          | saml_relay_states_created_at_idx                     | CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC)
 auth                | saml_relay_states          | saml_relay_states_for_email_idx                      | CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email)
 auth                | saml_relay_states          | saml_relay_states_pkey                               | CREATE UNIQUE INDEX saml_relay_states_pkey ON auth.saml_relay_states USING btree (id)
 auth                | saml_relay_states          | saml_relay_states_sso_provider_id_idx                | CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id)
 auth                | schema_migrations          | schema_migrations_pkey                               | CREATE UNIQUE INDEX schema_migrations_pkey ON auth.schema_migrations USING btree (version)
 auth                | sessions                   | sessions_not_after_idx                               | CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC)
 auth                | sessions                   | sessions_pkey                                        | CREATE UNIQUE INDEX sessions_pkey ON auth.sessions USING btree (id)
 auth                | sessions                   | sessions_user_id_idx                                 | CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id)
 auth                | sessions                   | user_id_created_at_idx                               | CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at)
 auth                | sso_domains                | sso_domains_domain_idx                               | CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain))
 auth                | sso_domains                | sso_domains_pkey                                     | CREATE UNIQUE INDEX sso_domains_pkey ON auth.sso_domains USING btree (id)
 auth                | sso_domains                | sso_domains_sso_provider_id_idx                      | CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id)
 auth                | sso_providers              | sso_providers_pkey                                   | CREATE UNIQUE INDEX sso_providers_pkey ON auth.sso_providers USING btree (id)
 auth                | sso_providers              | sso_providers_resource_id_idx                        | CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id))
 auth                | sso_providers              | sso_providers_resource_id_pattern_idx                | CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops)
 auth                | users                      | confirmation_token_idx                               | CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text)
 auth                | users                      | email_change_token_current_idx                       | CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text)
 auth                | users                      | email_change_token_new_idx                           | CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text)
 auth                | users                      | reauthentication_token_idx                           | CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text)
 auth                | users                      | recovery_token_idx                                   | CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text)
 auth                | users                      | users_email_partial_key                              | CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false)
 auth                | users                      | users_instance_id_email_idx                          | CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text))
 auth                | users                      | users_instance_id_idx                                | CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id)
 auth                | users                      | users_is_anonymous_idx                               | CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous)
 auth                | users                      | users_phone_key                                      | CREATE UNIQUE INDEX users_phone_key ON auth.users USING btree (phone)
 auth                | users                      | users_pkey                                           | CREATE UNIQUE INDEX users_pkey ON auth.users USING btree (id)
 public              | admin_keys                 | admin_keys_pkey                                      | CREATE UNIQUE INDEX admin_keys_pkey ON public.admin_keys USING btree (code)
 public              | availability_slots         | availability_slots_pkey                              | CREATE UNIQUE INDEX availability_slots_pkey ON public.availability_slots USING btree (id)
 public              | availability_slots         | idx_availability_slots_teacher_id                    | CREATE INDEX idx_availability_slots_teacher_id ON public.availability_slots USING btree (teacher_id)
 public              | availability_slots         | idx_availability_slots_time                          | CREATE INDEX idx_availability_slots_time ON public.availability_slots USING btree (start_time, end_time)
 public              | bookings                   | bookings_pkey                                        | CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (id)
 public              | bookings                   | idx_bookings_student_id                              | CREATE INDEX idx_bookings_student_id ON public.bookings USING btree (student_id)
 public              | bookings                   | idx_bookings_teacher_id                              | CREATE INDEX idx_bookings_teacher_id ON public.bookings USING btree (teacher_id)
 public              | certificates               | certificates_pkey                                    | CREATE UNIQUE INDEX certificates_pkey ON public.certificates USING btree (id)
 public              | certificates               | certificates_user_id_course_id_key                   | CREATE UNIQUE INDEX certificates_user_id_course_id_key ON public.certificates USING btree (user_id, course_id)
 public              | certificates               | idx_certificates_course                              | CREATE INDEX idx_certificates_course ON public.certificates USING btree (course_id)
 public              | certificates               | idx_certificates_user                                | CREATE INDEX idx_certificates_user ON public.certificates USING btree (user_id)
 public              | coupons                    | coupons_pkey                                         | CREATE UNIQUE INDEX coupons_pkey ON public.coupons USING btree (code)
 public              | coupons                    | idx_coupons_enabled                                  | CREATE INDEX idx_coupons_enabled ON public.coupons USING btree (is_enabled)
 public              | coupons                    | idx_coupons_expires                                  | CREATE INDEX idx_coupons_expires ON public.coupons USING btree (expires_at)
 public              | course_enrollments         | course_enrollments_course_id_student_id_key          | CREATE UNIQUE INDEX course_enrollments_course_id_student_id_key ON public.course_enrollments USING btree (course_id, student_id)
 public              | course_enrollments         | course_enrollments_pkey                              | CREATE UNIQUE INDEX course_enrollments_pkey ON public.course_enrollments USING btree (id)
 public              | course_enrollments         | idx_course_enrollments_course_id                     | CREATE INDEX idx_course_enrollments_course_id ON public.course_enrollments USING btree (course_id)
 public              | course_enrollments         | idx_course_enrollments_student_id                    | CREATE INDEX idx_course_enrollments_student_id ON public.course_enrollments USING btree (student_id)
 public              | course_modules             | course_modules_pkey                                  | CREATE UNIQUE INDEX course_modules_pkey ON public.course_modules USING btree (id)
 public              | course_modules             | idx_course_modules_course                            | CREATE INDEX idx_course_modules_course ON public.course_modules USING btree (course_id)
 public              | course_quizzes             | course_quizzes_pkey                                  | CREATE UNIQUE INDEX course_quizzes_pkey ON public.course_quizzes USING btree (id)
 public              | course_quizzes             | idx_course_quizzes_course                            | CREATE INDEX idx_course_quizzes_course ON public.course_quizzes USING btree (course_id)
 public              | courses                    | courses_pkey                                         | CREATE UNIQUE INDEX courses_pkey ON public.courses USING btree (id)
 public              | courses                    | courses_slug_key                                     | CREATE UNIQUE INDEX courses_slug_key ON public.courses USING btree (slug)
 public              | courses                    | idx_courses_published                                | CREATE INDEX idx_courses_published ON public.courses USING btree (is_published)
 public              | courses                    | idx_courses_teacher_id                               | CREATE INDEX idx_courses_teacher_id ON public.courses USING btree (teacher_id)
 public              | lesson_media               | lesson_media_pkey                                    | CREATE UNIQUE INDEX lesson_media_pkey ON public.lesson_media USING btree (id)
 public              | lessons                    | lessons_pkey                                         | CREATE UNIQUE INDEX lessons_pkey ON public.lessons USING btree (id)
 public              | messages                   | idx_messages_course_id                               | CREATE INDEX idx_messages_course_id ON public.messages USING btree (course_id)
 public              | messages                   | idx_messages_sender_recipient                        | CREATE INDEX idx_messages_sender_recipient ON public.messages USING btree (sender_id, recipient_id)
 public              | messages                   | messages_pkey                                        | CREATE UNIQUE INDEX messages_pkey ON public.messages USING btree (id)
 public              | modules                    | modules_pkey                                         | CREATE UNIQUE INDEX modules_pkey ON public.modules USING btree (id)
 public              | notifications              | idx_notifications_unread                             | CREATE INDEX idx_notifications_unread ON public.notifications USING btree (user_id, is_read) WHERE (is_read = false)
 public              | notifications              | idx_notifications_user_id                            | CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id)
 public              | notifications              | notifications_pkey                                   | CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id)
 public              | profiles                   | profiles_pkey                                        | CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id)
 public              | profiles                   | profiles_user_id_key                                 | CREATE UNIQUE INDEX profiles_user_id_key ON public.profiles USING btree (user_id)
 public              | public_teacher_info        | idx_public_teacher_info_user_id                      | CREATE INDEX idx_public_teacher_info_user_id ON public.public_teacher_info USING btree (user_id)
 public              | public_teacher_info        | public_teacher_info_pkey                             | CREATE UNIQUE INDEX public_teacher_info_pkey ON public.public_teacher_info USING btree (id)
 public              | public_teacher_info        | public_teacher_info_user_id_key                      | CREATE UNIQUE INDEX public_teacher_info_user_id_key ON public.public_teacher_info USING btree (user_id)
 public              | quiz_attempts              | idx_attempts_user                                    | CREATE INDEX idx_attempts_user ON public.quiz_attempts USING btree (user_id, quiz_id)
 public              | quiz_attempts              | idx_quiz_attempts_quiz                               | CREATE INDEX idx_quiz_attempts_quiz ON public.quiz_attempts USING btree (quiz_id)
 public              | quiz_attempts              | idx_quiz_attempts_user                               | CREATE INDEX idx_quiz_attempts_user ON public.quiz_attempts USING btree (user_id)
 public              | quiz_attempts              | quiz_attempts_pkey                                   | CREATE UNIQUE INDEX quiz_attempts_pkey ON public.quiz_attempts USING btree (id)
 public              | quiz_questions             | idx_quiz_questions_quiz                              | CREATE INDEX idx_quiz_questions_quiz ON public.quiz_questions USING btree (quiz_id)
 public              | quiz_questions             | quiz_questions_pkey                                  | CREATE UNIQUE INDEX quiz_questions_pkey ON public.quiz_questions USING btree (id)
 public              | services                   | services_pkey                                        | CREATE UNIQUE INDEX services_pkey ON public.services USING btree (id)
 public              | subscription_plans         | subscription_plans_pkey                              | CREATE UNIQUE INDEX subscription_plans_pkey ON public.subscription_plans USING btree (id)
 public              | subscriptions              | idx_subs_status                                      | CREATE INDEX idx_subs_status ON public.subscriptions USING btree (status)
 public              | subscriptions              | idx_subs_user                                        | CREATE INDEX idx_subs_user ON public.subscriptions USING btree (user_id)
 public              | subscriptions              | subscriptions_pkey                                   | CREATE UNIQUE INDEX subscriptions_pkey ON public.subscriptions USING btree (id)
 public              | tarot_readings             | idx_tarot_readings_status                            | CREATE INDEX idx_tarot_readings_status ON public.tarot_readings USING btree (status)
 public              | tarot_readings             | idx_tarot_readings_student_id                        | CREATE INDEX idx_tarot_readings_student_id ON public.tarot_readings USING btree (student_id)
 public              | tarot_readings             | idx_tarot_readings_teacher_id                        | CREATE INDEX idx_tarot_readings_teacher_id ON public.tarot_readings USING btree (teacher_id)
 public              | tarot_readings             | tarot_readings_pkey                                  | CREATE UNIQUE INDEX tarot_readings_pkey ON public.tarot_readings USING btree (id)
 public              | teacher_directory          | teacher_directory_pkey                               | CREATE UNIQUE INDEX teacher_directory_pkey ON public.teacher_directory USING btree (id)
 public              | teacher_directory          | teacher_directory_user_id_key                        | CREATE UNIQUE INDEX teacher_directory_user_id_key ON public.teacher_directory USING btree (user_id)
 public              | teacher_permissions        | teacher_permissions_pkey                             | CREATE UNIQUE INDEX teacher_permissions_pkey ON public.teacher_permissions USING btree (user_id)
 public              | teacher_requests           | teacher_requests_pkey                                | CREATE UNIQUE INDEX teacher_requests_pkey ON public.teacher_requests USING btree (id)
 public              | user_certifications        | user_certifications_pkey                             | CREATE UNIQUE INDEX user_certifications_pkey ON public.user_certifications USING btree (user_id, area)
 public              | user_roles                 | user_roles_pkey                                      | CREATE UNIQUE INDEX user_roles_pkey ON public.user_roles USING btree (id)
 public              | user_roles                 | user_roles_user_id_role_key                          | CREATE UNIQUE INDEX user_roles_user_id_role_key ON public.user_roles USING btree (user_id, role)
 realtime            | messages                   | messages_inserted_at_topic_index                     | CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE))
 realtime            | messages                   | messages_pkey                                        | CREATE UNIQUE INDEX messages_pkey ON ONLY realtime.messages USING btree (id, inserted_at)
 realtime            | schema_migrations          | schema_migrations_pkey                               | CREATE UNIQUE INDEX schema_migrations_pkey ON realtime.schema_migrations USING btree (version)
 realtime            | subscription               | ix_realtime_subscription_entity                      | CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity)
 realtime            | subscription               | pk_subscription                                      | CREATE UNIQUE INDEX pk_subscription ON realtime.subscription USING btree (id)
 realtime            | subscription               | subscription_subscription_id_entity_filters_key      | CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters)
 storage             | buckets                    | bname                                                | CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name)
 storage             | buckets                    | buckets_pkey                                         | CREATE UNIQUE INDEX buckets_pkey ON storage.buckets USING btree (id)
 storage             | buckets_analytics          | buckets_analytics_pkey                               | CREATE UNIQUE INDEX buckets_analytics_pkey ON storage.buckets_analytics USING btree (id)
 storage             | migrations                 | migrations_name_key                                  | CREATE UNIQUE INDEX migrations_name_key ON storage.migrations USING btree (name)
 storage             | migrations                 | migrations_pkey                                      | CREATE UNIQUE INDEX migrations_pkey ON storage.migrations USING btree (id)
 storage             | objects                    | bucketid_objname                                     | CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name)
 storage             | objects                    | idx_name_bucket_level_unique                         | CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level)
 storage             | objects                    | idx_objects_bucket_id_name                           | CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C")
 storage             | objects                    | idx_objects_lower_name                               | CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level)
 storage             | objects                    | name_prefix_search                                   | CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops)
 storage             | objects                    | objects_bucket_id_level_idx                          | CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C")
 storage             | objects                    | objects_pkey                                         | CREATE UNIQUE INDEX objects_pkey ON storage.objects USING btree (id)
 storage             | prefixes                   | idx_prefixes_lower_name                              | CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops)
 storage             | prefixes                   | prefixes_pkey                                        | CREATE UNIQUE INDEX prefixes_pkey ON storage.prefixes USING btree (bucket_id, level, name)
 storage             | s3_multipart_uploads       | idx_multipart_uploads_list                           | CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at)
 storage             | s3_multipart_uploads       | s3_multipart_uploads_pkey                            | CREATE UNIQUE INDEX s3_multipart_uploads_pkey ON storage.s3_multipart_uploads USING btree (id)
 storage             | s3_multipart_uploads_parts | s3_multipart_uploads_parts_pkey                      | CREATE UNIQUE INDEX s3_multipart_uploads_parts_pkey ON storage.s3_multipart_uploads_parts USING btree (id)
 supabase_migrations | schema_migrations          | schema_migrations_idempotency_key_key                | CREATE UNIQUE INDEX schema_migrations_idempotency_key_key ON supabase_migrations.schema_migrations USING btree (idempotency_key)
 supabase_migrations | schema_migrations          | schema_migrations_pkey                               | CREATE UNIQUE INDEX schema_migrations_pkey ON supabase_migrations.schema_migrations USING btree (version)
 supabase_migrations | seed_files                 | seed_files_pkey                                      | CREATE UNIQUE INDEX seed_files_pkey ON supabase_migrations.seed_files USING btree (path)
 vault               | secrets                    | secrets_name_idx                                     | CREATE UNIQUE INDEX secrets_name_idx ON vault.secrets USING btree (name) WHERE (name IS NOT NULL)
 vault               | secrets                    | secrets_pkey                                         | CREATE UNIQUE INDEX secrets_pkey ON vault.secrets USING btree (id)
(231 rows)

 ?column? 
----------
 
(1 row)

  ?column?   
-------------
 ## Triggers
(1 row)

  schema  |         table          |             trigger_name              | timing_event  |                      action_statement                      
----------+------------------------+---------------------------------------+---------------+------------------------------------------------------------
 app      | bookings               | trg_bookings_touch                    | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | certificates           | trg_certificates_touch                | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | certifications         | trg_certifications_touch              | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | courses                | trg_courses_set_owner                 | BEFORE INSERT | EXECUTE FUNCTION app._courses_set_owner()
 app      | courses                | trg_courses_touch                     | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | drip_plans             | trg_drip_plans_touch                  | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | drip_rules             | trg_drip_rules_touch                  | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | editor_styles          | trg_editor_styles_touch               | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | enrollments            | trg_enroll_materialize                | AFTER INSERT  | EXECUTE FUNCTION app.enrollments_materialize_trg_fn()
 app      | events                 | trg_events_touch                      | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | lessons                | trg_lessons_touch                     | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | magic_links            | trg_magic_links_touch                 | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | meditations            | trg_meditations_touch                 | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | memberships            | trg_memberships_touch                 | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | messages               | trg_messages_touch                    | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | modules                | trg_modules_touch                     | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | notification_jobs      | trg_notification_jobs_touch           | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | notification_templates | trg_notification_templates_touch      | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | orders                 | trg_orders_touch                      | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | pro_progress           | trg_pro_progress_touch                | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | pro_requirements       | trg_pro_requirements_touch            | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | profiles               | trg_profiles_touch                    | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | services               | trg_services_touch                    | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | tarot_requests         | trg_tarot_requests_touch              | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | tarot_requests         | trg_tarot_touch                       | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 app      | teacher_approvals      | trg_teacher_approvals_touch           | BEFORE UPDATE | EXECUTE FUNCTION app.touch_updated_at()
 auth     | users                  | on_auth_user_created                  | AFTER INSERT  | EXECUTE FUNCTION handle_new_user()
 public   | availability_slots     | update_availability_slots_updated_at  | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | bookings               | update_bookings_updated_at            | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | course_enrollments     | update_course_enrollments_updated_at  | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | course_modules         | trg_course_modules_created_by         | BEFORE INSERT | EXECUTE FUNCTION _set_created_by()
 public   | course_modules         | trg_course_modules_created_by         | BEFORE UPDATE | EXECUTE FUNCTION _set_created_by()
 public   | course_modules         | trg_course_modules_set_created_by     | BEFORE UPDATE | EXECUTE FUNCTION _set_created_by()
 public   | course_modules         | trg_course_modules_set_created_by     | BEFORE INSERT | EXECUTE FUNCTION _set_created_by()
 public   | courses                | trg_courses_created_by                | BEFORE INSERT | EXECUTE FUNCTION set_created_by()
 public   | courses                | update_courses_updated_at             | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | lessons                | update_lessons_updated_at             | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | messages               | update_messages_updated_at            | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | modules                | update_modules_updated_at             | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | profiles               | update_profiles_updated_at            | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | public_teacher_info    | update_public_teacher_info_updated_at | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | services               | trg_services_owner                    | BEFORE INSERT | EXECUTE FUNCTION set_owner()
 public   | tarot_readings         | update_tarot_readings_updated_at      | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | teacher_directory      | update_teacher_directory_updated_at   | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | teacher_requests       | update_teacher_requests_updated_at    | BEFORE UPDATE | EXECUTE FUNCTION update_updated_at_column()
 public   | user_roles             | on_teacher_role_created               | AFTER INSERT  | EXECUTE FUNCTION handle_new_teacher()
 realtime | subscription           | tr_check_filters                      | BEFORE UPDATE | EXECUTE FUNCTION realtime.subscription_check_filters()
 realtime | subscription           | tr_check_filters                      | BEFORE INSERT | EXECUTE FUNCTION realtime.subscription_check_filters()
 storage  | buckets                | enforce_bucket_name_length_trigger    | BEFORE UPDATE | EXECUTE FUNCTION storage.enforce_bucket_name_length()
 storage  | buckets                | enforce_bucket_name_length_trigger    | BEFORE INSERT | EXECUTE FUNCTION storage.enforce_bucket_name_length()
 storage  | objects                | objects_delete_delete_prefix          | AFTER DELETE  | EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger()
 storage  | objects                | objects_insert_create_prefix          | BEFORE INSERT | EXECUTE FUNCTION storage.objects_insert_prefix_trigger()
 storage  | objects                | objects_update_create_prefix          | BEFORE UPDATE | EXECUTE FUNCTION storage.objects_update_prefix_trigger()
 storage  | objects                | update_objects_updated_at             | BEFORE UPDATE | EXECUTE FUNCTION storage.update_updated_at_column()
 storage  | prefixes               | prefixes_create_hierarchy             | BEFORE INSERT | EXECUTE FUNCTION storage.prefixes_insert_trigger()
 storage  | prefixes               | prefixes_delete_hierarchy             | AFTER DELETE  | EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger()
(56 rows)

 ?column? 
----------
 
(1 row)

           ?column?            
-------------------------------
 ## Tabeller med RLS aktiverat
(1 row)

       schema        |           table            | rls_enabled 
---------------------+----------------------------+-------------
 app                 | app_config                 | t
 app                 | bookings                   | t
 app                 | certificates               | t
 app                 | certifications             | t
 app                 | courses                    | t
 app                 | drip_plans                 | t
 app                 | drip_rules                 | t
 app                 | editor_styles              | t
 app                 | enrollments                | t
 app                 | events                     | t
 app                 | guest_claim_tokens         | t
 app                 | lesson_media               | t
 app                 | lessons                    | t
 app                 | magic_links                | t
 app                 | meditations                | t
 app                 | memberships                | t
 app                 | messages                   | t
 app                 | modules                    | t
 app                 | notification_jobs          | t
 app                 | notification_templates     | t
 app                 | orders                     | t
 app                 | pro_progress               | t
 app                 | pro_requirements           | t
 app                 | profiles                   | t
 app                 | purchases                  | t
 app                 | services                   | t
 app                 | tarot_requests             | t
 app                 | teacher_approvals          | t
 app                 | teacher_directory          | t
 app                 | teacher_permissions        | t
 app                 | teacher_requests           | t
 app                 | teacher_slots              | t
 auth                | audit_log_entries          | t
 auth                | flow_state                 | t
 auth                | identities                 | t
 auth                | instances                  | t
 auth                | mfa_amr_claims             | t
 auth                | mfa_challenges             | t
 auth                | mfa_factors                | t
 auth                | oauth_clients              | f
 auth                | one_time_tokens            | t
 auth                | refresh_tokens             | t
 auth                | saml_providers             | t
 auth                | saml_relay_states          | t
 auth                | schema_migrations          | t
 auth                | sessions                   | t
 auth                | sso_domains                | t
 auth                | sso_providers              | t
 auth                | users                      | t
 public              | admin_keys                 | t
 public              | availability_slots         | t
 public              | bookings                   | t
 public              | certificates               | t
 public              | coupons                    | t
 public              | course_enrollments         | t
 public              | course_modules             | t
 public              | course_quizzes             | t
 public              | courses                    | t
 public              | lesson_media               | t
 public              | lessons                    | t
 public              | messages                   | t
 public              | modules                    | t
 public              | notifications              | t
 public              | profiles                   | t
 public              | public_teacher_info        | t
 public              | quiz_attempts              | t
 public              | quiz_questions             | t
 public              | services                   | t
 public              | subscription_plans         | t
 public              | subscriptions              | t
 public              | tarot_readings             | t
 public              | teacher_directory          | t
 public              | teacher_permissions        | t
 public              | teacher_requests           | t
 public              | user_certifications        | t
 public              | user_roles                 | t
 realtime            | schema_migrations          | f
 realtime            | subscription               | f
 storage             | buckets                    | t
 storage             | buckets_analytics          | t
 storage             | migrations                 | t
 storage             | objects                    | t
 storage             | prefixes                   | t
 storage             | s3_multipart_uploads       | t
 storage             | s3_multipart_uploads_parts | t
 supabase_migrations | schema_migrations          | f
 supabase_migrations | seed_files                 | f
 vault               | secrets                    | f
(88 rows)

