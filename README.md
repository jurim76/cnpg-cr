# cnpg-crd

![Version: 0.19.4](https://img.shields.io/badge/Version-0.19.4-informational?style=flat-square) ![AppVersion: 16.6-5](https://img.shields.io/badge/AppVersion-16.6--5-informational?style=flat-square)

CloudNative-PG operator Custom Resource Definition

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Juri Malinovski | <coil93@gmail.com> |  |

Chart for deploying CloudNative-PG operator Custom Resource (CR).
CloudNativePG is an open source operator designed to manage PostgreSQL workloads.
[Documentation](https://cloudnative-pg.io/documentation/current/)

### Notes
The following parameters are fixed and exclusively controlled by the operator:
https://cloudnative-pg.io/documentation/current/postgresql_conf/#fixed-parameters
```
archive_command = '/controller/manager wal-archive %p'
archive_mode = 'on'
full_page_writes = 'on'
hot_standby = 'true'
listen_addresses = '*'
port = '5432'
restart_after_crash = 'false'
ssl = 'on'
ssl_ca_file = '/controller/certificates/client-ca.crt'
ssl_cert_file = '/controller/certificates/server.crt'
ssl_key_file = '/controller/certificates/server.key'
unix_socket_directories = '/controller/run'
wal_level = 'logical'
wal_log_hints = 'on'
```

- The operator requires PostgreSQL to output its log in CSV format, and the instance manager automatically parses it and outputs it in JSON format. For this reason, all log settings in PostgreSQL are fixed and cannot be changed.

- The `shared_preload_libraries` option in PostgreSQL exists to specify one or more shared libraries to be pre-loaded at server start, in the form of a comma-separated list.
You can provide additional shared_preload_libraries via `.spec.postgresql.shared_preload_libraries` as a list of strings: the operator will merge them with the ones that it automatically manages.
- CloudNativePG automatically manages the content in shared_preload_libraries for some well-known and supported extensions. The current list includes:

`auto_explain
pg_stat_statements
pgaudit
pg_failover_slots
`

- Changing configuration. You can apply configuration changes by editing the postgresql section of the Cluster resource.
After the change, the cluster instances will immediately reload the configuration to apply the changes. If the change involves a parameter requiring a restart, the operator will perform a rolling upgrade.

More info https://cloudnative-pg.io/documentation/current/postgresql_conf/

Operator configuration
- `cnpg-controller-manager-config` configMap

- If you want ConfigMaps and Secrets to be automatically reloaded by instances, you can add a label with key `cnpg.io/reload` to it, otherwise you will have to reload the instances using the kubectl cnpg reload subcommand.

- Verify backup job with on-demand backup
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: test-backup
spec:
  method: barmanObjectStore
  cluster:
    name: test-db
```

### Troubleshooting
- https://cloudnative-pg.io/documentation/current/troubleshooting/

### terraform, vault, external-secret
- Vault secret path should be in format `kubernetes-secrets/postgres-pod/<namespace>/<db-name>`
- External-secret store should be configured as `ClusterSecretStore`, pointed to `kubernetes-secrets/postgres-pod` vault path

### Backup
- To enable volumesnapshot for backup, set `backup.snapshot: true` in values
- PITR recovery example README-restore.md

### Major postgres version upgrade
See [Upgrade](README-upgrade.md)

### Restore the database
See [Restore](README-restore.md)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| backup.enabled | bool | `false` |  |
| backup.retention | string | `"8d"` |  |
| backup.schedule | string | `"0 0 0 * * *"` |  |
| backup.snapshot | bool | `false` |  |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{}` |  |
| config | string | `""` |  |
| databases | list | `[]` |  |
| default.databases | object | `{}` |  |
| default.instances | int | `2` |  |
| default.limits | object | `{}` |  |
| default.nodeSelector | object | `{}` |  |
| default.requests.cpu | string | `"100m"` |  |
| default.requests.memory | string | `"200Mi"` |  |
| default.roles | object | `{}` |  |
| default.storage | string | `"10Gi"` |  |
| exporter.configMapName | string | `"postgres-exporter-cm"` |  |
| exporter.labels.release | string | `"prometheus-dbs"` |  |
| image.pullSecret | string | `""` |  |
| image.registry | string | `"ghcr.io"` |  |
| image.repository | string | `"cloudnative-pg/postgresql"` |  |
| image.tag | string | `""` |  |
| nameSuffix | string | `"db"` |  |
| podEnv[0].name | string | `"KUBE_NAMESPACE"` |  |
| podEnv[0].valueFrom.fieldRef.fieldPath | string | `"metadata.namespace"` |  |
| podEnv[1].name | string | `"ENV_NAME"` |  |
| podEnv[1].valueFrom.configMapKeyRef.key | string | `"env"` |  |
| podEnv[1].valueFrom.configMapKeyRef.name | string | `"environment-name"` |  |
| podEnv[1].valueFrom.configMapKeyRef.optional | bool | `true` |  |
| pooler.enabled | bool | `true` |  |
| pooler.image | string | `"ghcr.io/cloudnative-pg/pgbouncer:1.23.0"` |  |
| pooler.instances | int | `2` |  |
| pooler.mode | string | `"transaction"` |  |
| pooler.parameters.default_pool_size | string | `"10"` |  |
| pooler.parameters.max_client_conn | string | `"1000"` |  |
| pooler.paused | bool | `false` |  |
| postgresConfig | string | `"postgres-base-conf"` |  |
| postgresql.custom_parameters | object | `{}` |  |
| postgresql.parameters.include_dir | string | `"/projected/config"` |  |
| postgresql.shared_preload_libraries[0] | string | `"auto_explain"` |  |
| postgresql.shared_preload_libraries[1] | string | `"decoderbufs"` |  |
| postgresql.shared_preload_libraries[2] | string | `"passwordcheck"` |  |
| postgresql.shared_preload_libraries[3] | string | `"pg_cron"` |  |
| postgresql.shared_preload_libraries[4] | string | `"pg_failover_slots"` |  |
| postgresql.shared_preload_libraries[5] | string | `"pg_repack"` |  |
| postgresql.shared_preload_libraries[6] | string | `"pg_stat_statements"` |  |
| postgresql.shared_preload_libraries[7] | string | `"pgaudit"` |  |
| primaryUpdateStrategy | string | `"unsupervised"` |  |
| priorityClassName | string | `""` |  |
| s3.bucket | string | `"s3://pgbackup"` |  |
| s3.endpoint | string | `"http://seaweedfs-s3.seaweedfs:8333"` |  |
| s3.secret | string | `"seaweedfs-s3"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"postgres-pod"` |  |
| serviceDomain | string | `"svc.cluster.local"` |  |
