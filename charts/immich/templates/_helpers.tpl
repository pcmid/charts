{{/*
Expand the name of the chart.
*/}}
{{- define "immich.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "immich.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "immich.tag" -}}
{{- default (printf "v%s" .Chart.AppVersion) .Values.image.tag }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "immich.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "immich.labels" -}}
helm.sh/chart: {{ include "immich.chart" . }}
{{ include "immich.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "immich.selectorLabels" -}}
app.kubernetes.io/name: {{ include "immich.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "immich.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "immich.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* libraryPath */}}
{{- define "immich.dataMountPath" -}}
{{- default "/data" .Values.persistence.mountPath }}
{{- end }}

{{/* database */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "immich.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "immich.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "immich.postgresql.fullname" . -}}
{{- else -}}
{{ required "A valid externalPostgresql.host is required" .Values.externalPostgresql.host }}
{{- end -}}
{{- end -}}

{{/*
Set postgres secret
*/}}
{{- define "immich.postgresql.secret" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "immich.postgresql.fullname" . -}}
{{- else -}}
{{- template "immich.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres port
*/}}
{{- define "immich.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{- if .Values.postgresql.service -}}
{{- .Values.postgresql.service.port | default 5432 }}
{{- else -}}
5432
{{- end -}}
{{- else -}}
{{- required "A valid externalPostgresql.port is required" .Values.externalPostgresql.port -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql username
*/}}
{{- define "immich.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{ required "A valid postgresql.auth.username is required" .Values.postgresql.auth.username }}
{{- else -}}
{{ required "A valid externalPostgresql.username is required" .Values.externalPostgresql.username }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql password
*/}}
{{- define "immich.postgresql.password" -}}
{{- if .Values.postgresql.enabled -}}
{{ required "A valid postgresql.auth.password is required" .Values.postgresql.auth.password }}
{{- else if not (and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretPasswordKey) -}}
{{ required "A valid externalPostgresql.password is required" .Values.externalPostgresql.password }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql database
*/}}
{{- define "immich.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{-  if .Values.postgresql.postgresqlDatabase -}}
{{-    fail "You need to switch to the new postgresql.auth values." -}}
{{-  end -}}
{{- .Values.postgresql.auth.database | default "synapse" }}
{{- else -}}
{{ required "A valid externalPostgresql.database is required" .Values.externalPostgresql.database }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql sslmode
*/}}
{{- define "immich.postgresql.sslmode" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.sslmode | default "prefer" }}
{{- else -}}
{{- .Values.externalPostgresql.sslmode | default "prefer" }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "immich.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set redis host
*/}}
{{- define "immich.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-%s" (include "immich.redis.fullname" .) "master" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ required "A valid externalRedis.host is required" .Values.externalRedis.host }}
{{- end -}}
{{- end -}}

{{/*
Set redis secret
*/}}
{{- define "immich.redis.secret" -}}
{{- if .Values.redis.enabled -}}
{{- template "immich.redis.fullname" . -}}
{{- else -}}
{{- template "immich.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set redis port
*/}}
{{- define "immich.redis.port" -}}
{{- if .Values.redis.enabled -}}
{{- .Values.redis.master.service.port | default 6379 }}
{{- else -}}
{{ required "A valid externalRedis.port is required" .Values.externalRedis.port }}
{{- end -}}
{{- end -}}

{{/*
Set redis username
*/}}
{{- define "immich.redis.username" -}}
{{- if .Values.externalRedis.username -}}
{{ .Values.externalRedis.username }}
{{- end -}}
{{- end -}}

{{/*
Set redis password
*/}}
{{- define "immich.redis.password" -}}
{{- if (and .Values.redis.enabled .Values.redis.auth.password) -}}
{{ .Values.redis.auth.password }}
{{- else if .Values.externalRedis.password -}}
{{ .Values.externalRedis.password }}
{{- end -}}
{{- end -}}

{{/*
Set redis database id
*/}}
{{- define "immich.redis.db" -}}
{{- if .Values.redis.db -}}
{{ .Values.redis.db }}
{{- else if .Values.externalRedis.db -}}
{{ .Values.externalRedis.db }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "immich.typesense.fullname" -}}
{{- printf "%s-%s" .Release.Name "typesense" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set typesense host
*/}}
{{- define "immich.typesense.host" -}}
{{- if .Values.redis.enabled -}}
{{- include "immich.typesense.fullname" . | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.externalTypesense.enabled -}}
{{ required "A valid externalTypesense.host is required" .Values.externalTypesense.host }}
{{- else }}
{{- end -}}
{{- end -}}

{{/*
Set typesense port
*/}}
{{- define "immich.typesense.port" -}}
{{- if .Values.typesense.enabled -}}
{{- default 8108 .Values.typesense.service.port }}
{{- else if .Values.externalTypesense.enabled -}}
{{ required "A valid externalTypesense.port is required" .Values.externalTypesense.port }}
{{- else }}
{{- end -}}
{{- end -}}

{{/*
Set typesense protocol
*/}}
{{- define "immich.typesense.protocol" -}}
{{- if .Values.typesense.enabled -}}
{{ default "http" .Values.externalTypesense.protocol }}
{{- else -}}
http
{{- end -}}
{{- end -}}

{{/*
Set typesense password
*/}}
{{- define "immich.typesense.apkKey" -}}
{{- if .Values.typesense.enabled -}}
{{ .Values.typesense.apiKey }}
{{- else if .Values.externalTypesense.enabled -}}
{{ required "A valid externalTypesense.apiKey is required" .Values.externalTypesense.apiKey }}
{{- else }}
{{- end -}}
{{- end -}}
