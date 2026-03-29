{{/*
Validate required values and fail with clear error messages.
Include this template from instance.yaml to enforce at render time.
*/}}
{{- define "paperclip.validate" -}}

{{/*
Auth secret is required for authenticated and single-tenant modes.
*/}}
{{- if and (ne .Values.deployment.mode "open") (not .Values.auth.secretRef.name) }}
  {{- fail "auth.secretRef.name is required when deployment.mode is 'authenticated' or 'single-tenant'. Provide a Secret name containing BETTER_AUTH_SECRET." }}
{{- end }}

{{/*
Public exposure requires a publicURL.
*/}}
{{- if and (eq .Values.deployment.exposure "public") (not .Values.deployment.publicURL) }}
  {{- fail "deployment.publicURL is required when deployment.exposure is 'public'." }}
{{- end }}

{{/*
External database requires a connection string source.
*/}}
{{- if eq .Values.database.mode "external" }}
  {{- if and (not .Values.database.externalURL) (not .Values.database.externalURLSecretRef.name) }}
    {{- fail "database.externalURL or database.externalURLSecretRef.name is required when database.mode is 'external'." }}
  {{- end }}
{{- end }}

{{/*
External redis requires a connection string source.
*/}}
{{- if and .Values.redis.enabled (eq .Values.redis.mode "external") }}
  {{- if and (not .Values.redis.externalURL) (not .Values.redis.externalURLSecretRef.name) }}
    {{- fail "redis.externalURL or redis.externalURLSecretRef.name is required when redis.mode is 'external'." }}
  {{- end }}
{{- end }}

{{/*
Object storage requires provider and bucket.
*/}}
{{- if .Values.objectStorage.enabled }}
  {{- if not .Values.objectStorage.provider }}
    {{- fail "objectStorage.provider is required when objectStorage is enabled. Must be one of: s3, minio, r2." }}
  {{- end }}
  {{- if not .Values.objectStorage.bucket }}
    {{- fail "objectStorage.bucket is required when objectStorage is enabled." }}
  {{- end }}
{{- end }}

{{/*
Backup requires a schedule.
*/}}
{{- if and .Values.backup.enabled (not .Values.backup.schedule) }}
  {{- fail "backup.schedule is required when backup is enabled. Provide a cron expression (e.g. '0 2 * * *')." }}
{{- end }}

{{/*
Admin user requires a password secret when email is set.
*/}}
{{- if and .Values.auth.adminUser.email (not .Values.auth.adminUser.passwordSecretRef.name) }}
  {{- fail "auth.adminUser.passwordSecretRef.name is required when auth.adminUser.email is set." }}
{{- end }}

{{/*
Connections require a credentials secret.
*/}}
{{- if and .Values.connections.enabled (not .Values.connections.credentialsSecretRef.name) }}
  {{- fail "connections.credentialsSecretRef.name is required when connections is enabled." }}
{{- end }}

{{/*
Email auth requires a Resend API key secret when from address is set.
*/}}
{{- if and .Values.auth.email.from (not .Values.auth.email.resendAPIKeySecretRef.name) }}
  {{- fail "auth.email.resendAPIKeySecretRef.name is required when auth.email.from is set." }}
{{- end }}

{{/*
Validate enum values.
*/}}
{{- $validModes := list "open" "authenticated" "single-tenant" }}
{{- if not (has .Values.deployment.mode $validModes) }}
  {{- fail (printf "deployment.mode must be one of: %s (got '%s')" (join ", " $validModes) .Values.deployment.mode) }}
{{- end }}

{{- $validExposures := list "private" "public" }}
{{- if not (has .Values.deployment.exposure $validExposures) }}
  {{- fail (printf "deployment.exposure must be one of: %s (got '%s')" (join ", " $validExposures) .Values.deployment.exposure) }}
{{- end }}

{{- $validDbModes := list "embedded" "external" "managed" }}
{{- if not (has .Values.database.mode $validDbModes) }}
  {{- fail (printf "database.mode must be one of: %s (got '%s')" (join ", " $validDbModes) .Values.database.mode) }}
{{- end }}

{{- if .Values.redis.enabled }}
{{- $validRedisModes := list "managed" "external" }}
{{- if not (has .Values.redis.mode $validRedisModes) }}
  {{- fail (printf "redis.mode must be one of: %s (got '%s')" (join ", " $validRedisModes) .Values.redis.mode) }}
{{- end }}
{{- end }}

{{- if .Values.objectStorage.enabled }}
{{- $validProviders := list "s3" "minio" "r2" }}
{{- if not (has .Values.objectStorage.provider $validProviders) }}
  {{- fail (printf "objectStorage.provider must be one of: %s (got '%s')" (join ", " $validProviders) .Values.objectStorage.provider) }}
{{- end }}
{{- end }}

{{- $validLogLevels := list "debug" "info" "warn" "error" }}
{{- if not (has .Values.observability.logging.level $validLogLevels) }}
  {{- fail (printf "observability.logging.level must be one of: %s (got '%s')" (join ", " $validLogLevels) .Values.observability.logging.level) }}
{{- end }}

{{- $validProbeTypes := list "auto" "http" "tcp" }}
{{- if not (has .Values.probes.type $validProbeTypes) }}
  {{- fail (printf "probes.type must be one of: %s (got '%s')" (join ", " $validProbeTypes) .Values.probes.type) }}
{{- end }}

{{- $validServiceTypes := list "ClusterIP" "LoadBalancer" "NodePort" }}
{{- if not (has .Values.networking.service.type $validServiceTypes) }}
  {{- fail (printf "networking.service.type must be one of: %s (got '%s')" (join ", " $validServiceTypes) .Values.networking.service.type) }}
{{- end }}

{{- end -}}
