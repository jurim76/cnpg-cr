https://cloudnative-pg.io/documentation/current/bootstrap/

The initdb bootstrap also offers the possibility to import one or more databases from an existing Postgres cluster, even outside Kubernetes, and having a different major version of Postgres.

The following manifest creates a new PostgreSQL 16 cluster, called warehouse16-db, using the pg_basebackup bootstrap method to clone an external PostgreSQL cluster defined as warehouse-db

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: warehouse-db
spec:
  # standard cluster section
  imageName: ghcr.io/cloudnative-pg/postgresql:16.6-5
  primaryUpdateStrategy: unsupervised
  instances: 2
  storage:
    size: 10Gi
  affinity:
    enablePodAntiAffinity: true
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: pgdb
            operator: In
            values:
            - "true"
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
  backup:
    target: prefer-standby
    barmanObjectStore:
      destinationPath: s3://pgbackup/
      endpointURL: http://minio-cluster:9000
      s3Credentials:
        accessKeyId:
          name: minio-s3
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: minio-s3
          key: ACCESS_SECRET_KEY
      wal:
        compression: gzip
        maxParallel: 4
      data:
        compression: gzip
        jobs: 2
    retentionPolicy: "1d"
  projectedVolumeTemplate:
    sources:
    - configMap:
        name: postgres-base-conf
        items:
        - key: postgresql.conf
          path: config/postgresql01.conf
    - configMap:
        name: postgres-conf-stage
        items:
        - key: postgresql.conf
          path: config/postgresql02.conf
  monitoring:
    enablePodMonitor: false
    customQueriesConfigMap:
    - name: postgres13-exporter-cm
      key: queries.yaml
  # bootstrap section
  bootstrap:
    pg_basebackup:
      source: warehouse-db
  # external cluster section with tls authentication
  externalClusters:
  - name: warehouse-db
    connectionParameters:
      host: warehouse-db-rw
      user: streaming_replica
      sslmode: allow
    sslKey:
      name: warehouse-db-replication
      key: tls.key
    sslCert:
      name: warehouse-db-replication
      key: tls.crt
    sslRootCert:
      name: warehouse-db-ca
      key: ca.crt
