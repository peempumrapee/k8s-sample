{{- define "nginx.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nginx.service.name" -}}
{{- printf "%s-service" (include "nginx.fullname" .) -}}
{{- end -}}

{{- define "nginx.deployment.name" -}}
{{- printf "%s-deployment" (include "nginx.fullname" .) -}}
{{- end -}}
