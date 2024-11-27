# PITR example
# https://cloudnative-pg.io/documentation/1.24/recovery/

---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  # the name of restored cluster, should not be same as original cluster name
  name: warehouse-db-restore
spec:
  instances: 2
  storage:
    size: 5Gi
  # postgresql version should be the same for both clusters
  imageName: ghcr.io/cloudnative-pg/postgresql:16.6-5
  # configuration should be the same for both clusters
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: dr
            operator: In
            values:
            - "true"
  # bootstrap section
  bootstrap:
    recovery:
      # externalCluster name
      source: warehouse-db
      recoveryTarget:
        # PITR timestamp
        targetTime: "2023-12-04 02:00:00"
  # external cluster section
  externalClusters:
    # the original cluster name
  - name: warehouse-db
    barmanObjectStore:
      # minio S3 definition
      destinationPath: s3://pgbackup/
      endpointURL: http://minio-cluster:9000
      # minio-s3 secret
      s3Credentials:
        accessKeyId:
          key: ACCESS_KEY_ID
          name: minio-s3
        secretAccessKey:
          key: ACCESS_SECRET_KEY
          name: minio-s3
      # reduce the recovery time with parallel jobs
      wal:
        maxParallel: 8
