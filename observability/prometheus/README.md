# Prometheus

We generate the ConfigMap from `prometheus.yml` and attach it to the StatefulSet dynamically using
kustomize.
This allows us to leverage IDE integration for YAML syntax highlighting and config validation for
`prometheus.yml`.

We are currently not using a headless service because we don't yet have a reason to care about
which replica of the StatefulSet we're communicating with.
This will be implemented (potentially alongside the standard service) as its use case arises.
