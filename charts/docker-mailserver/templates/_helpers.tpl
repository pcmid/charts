{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{define "dockermailserver.name"}}{{default "dockermailserver" .Values.nameOverride | trunc 63 | trimSuffix "-" }}{{end}}

{{/*
Create a default fully qualified app name.

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dockermailserver.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "dockermailserver.labels" -}}
helm.sh/chart: {{ include "dockermailserver.chart" . }}
{{ include "dockermailserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "dockermailserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dockermailserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dockermailserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Provide a pre-defined claim or a claim based on the Release
*/}}
{{- define "dockermailserver.pvcName" -}}
{{- if .Values.persistent.existingClaim }}
{{- .Values.persistent.existingClaim }}
{{- else -}}
{{- template "dockermailserver.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "dockermailserver.serviceAccountName" -}}
    {{ default (include "dockermailserver.fullname" .) .Values.serviceAccount.name }}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "dockermailserver.roundcube.serviceAccountName" -}}
    {{ default (printf "%s-roundcube" (include "dockermailserver.fullname" .)) .Values.roundcube.serviceAccount.name }}
{{- end -}}
