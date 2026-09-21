# Lab 2 — Object storage with S3

The generated user and order datasets are uploaded to the `bronze/` prefix of the personal Onyxia S3 bucket. The
Kubernetes manifest in `job-upload-bronze.yaml` performs this ingestion from inside the cluster.

## Kubernetes Job preparation

The Job expects three resources created in the current namespace:

- `datasets`: a ConfigMap containing `users.csv` and `orders.csv`;
- `s3-config`: a ConfigMap containing the endpoint, region, and bucket name;
- `s3-credentials`: a Secret containing the temporary S3 credentials.

No credentials are committed to this repository.

## Questions

### Why are credentials stored in a Secret instead of a ConfigMap?

A ConfigMap is intended for non-sensitive configuration. A Secret separates credentials from ordinary configuration,
supports stricter Kubernetes access controls, and avoids exposing them directly in the Job manifest. Secret values
still need encryption at rest and appropriate RBAC because base64 encoding alone is not encryption.

### What happens when the Job is executed again after the credentials expire?

The Job fails with an authentication error such as `ExpiredToken`. A production platform should avoid copying temporary
credentials into a long-lived Secret. It should give the Job a workload identity or an IAM role through its Kubernetes
service account so that short-lived credentials are issued and refreshed automatically.

### How can this become a daily ingestion?

Replace the `Job` with a Kubernetes `CronJob` whose `jobTemplate` contains the same pod specification and whose schedule
runs once per day. The ingestion should also be idempotent and observable so retries do not corrupt the bronze layer.
