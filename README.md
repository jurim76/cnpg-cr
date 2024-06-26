Chart for deploying CloudNative-PG operator CR (Custom Resource).
CloudNativePG is an open source operator designed to manage PostgreSQL workloads.
https://cloudnative-pg.io/documentation/1.22/


### Notes
The following parameters are fixed and exclusively controlled by the operator:
https://cloudnative-pg.io/documentation/1.22/postgresql_conf/#fixed-parameters
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
- https://cloudnative-pg.io/documentation/1.22/troubleshooting/

### terraform, vault, external-secret
- Vault secret path should be in format `kubernetes-secrets/postgres-pod/<namespace>/<db-name>`
- External-secret store should be configured as `ClusterSecretStore`, pointed to `kubernetes-secrets/postgres-pod` vault path

### Backup
- To enable volumesnapshot for backup, set `backup.snapshot: true` in values
- PITR recovery example README-restore.md

### Major postgres version upgrade
See README-upgrade.md
