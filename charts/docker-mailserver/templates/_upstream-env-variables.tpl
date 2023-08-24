{{/*
There are a _lot_ of upstream env variables used to customize docker-mailserver.
We list them here (and include this template in deployment.yaml) to keep deployment.yaml neater
*/}}
{{- define "dockermailserver.upstream-env-variables" -}}
- name: OVERRIDE_HOSTNAME
  value: {{ .Values.options.override_hostname | quote }}
- name: DMS_DEBUG
  value: {{ .Values.options.dms_debug | quote }}              
- name: ENABLE_CLAMAV
  value: {{ .Values.options.enable_clamav | quote }}
- name: ONE_DIR
  value: {{ .Values.options.one_dir | quote }}
- name: ENABLE_POP3
  value: {{ .Values.options.enable_pop3 | quote }}
- name: ENABLE_FAIL2BAN
  value: {{ default false .Values.options.enable_fail2ban | quote }}
- name: SMTP_ONLY
  value: {{ .Values.options.smtp_only | quote }}
{{- if .Values.options.enable_rspamd }}
- name: ENABLE_RSPAMD
  value: {{ .Values.options.enable_rspamd | quote }}
- name: ENABLE_OPENDKIM
  value: "0"
{{- end }}
{{- if .Values.ssl.enabled }}
- name: SSL_TYPE
  value: manual
- name: SSL_CERT_PATH
  value: {{ default "/tmp/ssl/tls.crt" .Values.options.ssl_cert_path | quote }}   
- name: SSL_KEY_PATH
  value: {{ default "/tmp/ssl/tls.key" .Values.options.ssl_key_path | quote }}                            
{{- end }}
- name: TLS_LEVEL
  value: {{ .Values.options.tls_level | quote }}
- name: SPOOF_PROTECTION
  value: {{ .Values.options.spoof_protection | quote }}
- name: ENABLE_SRS
  value: {{ .Values.options.enable_srs | quote }}
- name: PERMIT_DOCKER
  value: {{ .Values.options.permit_docker | quote }}
- name: VIRUSMAILS_DELETE_DELAY
  value: {{ .Values.options.virusmails_delete_delay | quote }}
- name: ENABLE_POSTFIX_VIRTUAL_TRANSPORT
  value: {{ .Values.options.enable_postfix_virtual_transport | quote }}
- name: POSTFIX_DAGENT
  value: {{ .Values.options.postfix_dagent | quote }}
- name: POSTFIX_MAILBOX_SIZE_LIMIT
  value: {{ .Values.options.postfix_mailbox_size_limit | quote }}
- name: POSTFIX_MESSAGE_SIZE_LIMIT
  value: {{ .Values.options.postfix_message_size_limit | quote }}
- name: ENABLE_MANAGESIEVE
  value: {{ .Values.options.enable_managesieve | quote }}
- name: POSTMASTER_ADDRESS
  value: {{ .Values.options.postmaster_address | quote }}
- name: POSTSCREEN_ACTION
  value: {{ .Values.options.postscreen_action | quote }}
- name: REPORT_RECIPIENT
  value: {{ .Values.options.report_recipient | quote }}
- name: REPORT_SENDER
  value: {{ .Values.options.report_sender | quote }}
- name: REPORT_INTERVAL
  value: {{ .Values.options.report_interval | quote }}
- name: ENABLE_SPAMASSASSIN
  value: {{ .Values.options.enable_spamassassin | quote }}
- name: SPAMASSASSIN_SPAM_TO_INBOX
  value: {{ .Values.options.sa_spam_to_inbox | quote }}
- name: MOVE_SPAM_TO_JUNK
  value: {{ .Values.options.sa_move_spam_to_junk | quote }}
- name: SA_TAG
  value: {{ .Values.options.sa_tag | quote }}
- name: SA_TAG2
  value: {{ .Values.options.sa_tag2 | quote }}
- name: SA_KILL
  value: {{ .Values.options.sa_kill | quote }}
- name: SA_SPAM_SUBJECT
  value: {{ .Values.options.sa_spam_subject | quote }}
- name: ENABLE_FETCHMAIL
  value: {{ .Values.options.enable_fetchmail | quote }}
- name: FETCHMAIL_POLL
  value: {{ .Values.options.fetchmail_poll | quote }}
- name: ENABLE_LDAP
  value: {{ .Values.options.enable_ldap | quote }}
- name: LDAP_START_TLS
  value: {{ .Values.options.ldap_start_tls | quote }}
- name: LDAP_SERVER_HOST
  value: {{ .Values.options.ldap_server_host | quote }}
- name: LDAP_SEARCH_BASE
  value: {{ .Values.options.ldap_search_base | quote }}
- name: LDAP_BIND_DN
  value: {{ .Values.options.ldap_bind_dn | quote }}
- name: LDAP_BIND_PW
  value: {{ .Values.options.ldap_bind_pw | quote }}
- name: LDAP_QUERY_FILTER_USER
  value: {{ .Values.options.ldap_query_filter_user | quote }}
- name: LDAP_QUERY_FILTER_GROUP
  value: {{ .Values.options.ldap_query_filter_group | quote }}
- name: LDAP_QUERY_FILTER_ALIAS
  value: {{ .Values.options.ldap_query_filter_alias | quote }}
- name: LDAP_QUERY_FILTER_DOMAIN
  value: {{ .Values.options.ldap_query_filter_domain | quote }}
- name: LOG_LEVEL
  value: {{ .Values.options.log_level | quote }}
- name: DOVECOT_TLS
  value: {{ .Values.options.dovecot_tls | quote }}
- name: DOVECOT_LDAP_VERSION
  value: {{ .Values.options.dovecot_ldap_version | quote }}
- name: DOVECOT_DEFAULT_PASS_SCHEME
  value: {{ .Values.options.dovecot_default_pass_scheme | quote }}
- name: DOVECOT_AUTH_BIND
  value: {{ .Values.options.dovecot_auth_bind | quote }}
- name: DOVECOT_USER_FILTER
  value: {{ .Values.options.dovecot_user_filter | quote }}
- name: DOVECOT_USER_ATTRS
  value: {{ .Values.options.dovecot_user_attrs | quote }}
- name: DOVECOT_PASS_FILTER
  value: {{ .Values.options.dovecot_pass_filter | quote }}
- name: DOVECOT_PASS_ATTRS
  value: {{ .Values.options.dovecot_pass_attrs | quote }}
- name: DOVECOT_MAILBOX_FORMAT
  value: {{ .Values.options.dovecot_mailbox_format | quote }}
- name: ENABLE_POSTGREY
  value: {{ .Values.options.enable_postgrey | quote }}
- name: POSTGREY_DELAY
  value: {{ .Values.options.postgrey_delay | quote }}
- name: POSTGREY_MAX_AGE
  value: {{ .Values.options.postgrey_max_age | quote }}
- name: POSTGREY_AUTO_WHITELIST_CLIENTS
  value: {{ .Values.options.postgrey_auto_whitelist_clients | quote }}
- name: POSTGREY_TEXT
  value: {{ .Values.options.postgrey_text | quote }}
- name: ENABLE_SASLAUTHD
  value: {{ .Values.options.enable_saslauthd | quote }}
- name: SASLAUTHD_MECHANISMS
  value: {{ .Values.options.saslauthd_mechanisms | quote }}
- name: SASLAUTHD_MECH_OPTIONS
  value: {{ .Values.options.saslauthd_mech_options | quote }}
- name: SASLAUTHD_LDAP_SERVER
  value: {{ .Values.options.saslauthd_ldap_server | quote }}
- name: SASLAUTHD_LDAP_SSL
  value: {{ .Values.options.saslauthd_ldap_ssl | quote }}
- name: SASLAUTHD_LDAP_BIND_DN
  value: {{ .Values.options.saslauthd_ldap_bind_dn | quote }}
- name: SASLAUTHD_LDAP_PASSWORD
  value: {{ .Values.options.saslauthd_ldap_password | quote }}
- name: SASLAUTHD_LDAP_SEARCH_BASE
  value: {{ .Values.options.saslauthd_ldap_search_base | quote }}
- name: SASLAUTHD_LDAP_FILTER
  value: {{ .Values.options.saslauthd_ldap_filter | quote }}
- name: SASL_PASSWD
  value: {{ .Values.options.sasl_passwd | quote }}
- name: SRS_EXCLUDE_DOMAINS
  value: {{ .Values.options.srs_exclude_domains | quote }}
- name: SRS_SECRET
  value: {{ .Values.options.srs_secret | quote }}
- name: SRS_DOMAINNAME
  value: {{ .Values.options.srs_domainname | quote }}
- name: DEFAULT_RELAY_HOST
  value: {{ .Values.options.default_relay_host | quote }}
- name: RELAY_HOST
  value: {{ .Values.options.relay_host | quote }}
- name: RELAY_PORT
  value: {{ .Values.options.relay_port | quote }}
- name: RELAY_USER
  value: {{ .Values.options.relay_user | quote }}
- name: RELAY_PASSWORD
  value: {{ .Values.options.relay_password | quote }}
- name: PFLOGSUMM_TRIGGER
  value: {{ .Values.options.pflogsumm_trigger | quote }}
- name: PFLOGSUMM_RECIPIENT
  value: {{ .Values.options.pflogsumm_recipient | quote }}
{{- end -}}
