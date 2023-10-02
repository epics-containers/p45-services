{{- define "ioc-chart.configmap" -}}

apiVersion: v1
kind: ConfigMap
metadata:
  name:  {{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
    beamline: {{ .Values.beamline }}
    ioc_version: {{ .Chart.AppVersion | quote }}
    is_ioc: "True"
data:

{{ end -}}