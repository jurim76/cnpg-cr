{{- define "database.name" -}}
{{- $name := include "helper.getValue" (dict "key" "name" "scope" .scope "x" .x) }}
{{- printf "%s" (required "database .name is required" $name) | trunc 63 -}}
{{- end }}

{{- define "core.labels" -}}
{{- toYaml .Values.commonLabels }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if not .excludeChart }}
helm.sh/chart: {{ include "chart.chart" . }}
{{- end }}
{{- end }}

{{- define "selector.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- /* Takes in dict ("key" "suffix" "scope" $ "x" $x "y" $y) */}}
{{- define "helper.getValue" }}
    {{- $root := .scope.Values }}
    {{- $dbScope := ternary (index $root.databases .x) (dict) (hasKey . "x") }}
    {{- $iScope := dict }}
    {{- if hasKey . "y" }}
        {{- $iScope = index $dbScope.instances .y }}
    {{- end }}
    {{- if hasKey $iScope .key }}
        {{- get $iScope .key }}
    {{- else if hasKey $dbScope .key }}
        {{- get $dbScope .key }}
    {{- else }}
        {{- get $root.default .key }}
    {{- end }}
{{- end }}

{{- /* Create chart name and version as used by the chart label */}}
{{- define "chart.chart" -}}
{{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
