# Multi Region Application Architecture

Forked from [aws-solutions/multi-region-application-architecture](https://github.com/aws-solutions/multi-region-application-architecture)

Youtube demo : https://www.youtube.com/watch?v=sBvIphOw_FQ

### Step 1

```bash
make setup

# wait several minutes ...
```

[setup.sh](./scripts/setup.sh)

### Step 2

```bash
make browse
```

[browse.sh](./scripts/browse.sh)

1. Connect with login / password received by email
2. Open browser tabs to S3 `mr-app--xxxx-us-east-1` and `mr-app--xxxx-ap-northeast-1`
3. Open browser tabs to DynamoDB `mr-app--xxxx-app-config` at N. Virginia and `mr-app--xxxx-app-config` at Asia Pacific
4. Upload an image + add comments to image
5. Check contents update in S3 `mr-app--xxxx-us-east-1` and `mr-app--xxxx-ap-northeast-1`
6. Check contents update in DynamoDB `mr-app--xxxx-key-value-store` in `us-east-1` and `ap-northeast-1`
7. Connect to DynamoDB `mr-app--xxxx-app-config` at N. Virginia `us-east-1`
8. Edit item `state : active` to `state : failover`
9. Refresh DynamoDB `mr-app--xxxx-app-config` at Asia Pacific `ap-northeast-1`. `state` is updated to `failed`
10. Reload the demo website : the current region is now `ap-northeast-1`
11. Upload another image + add comments to this image
12. Refresh DynamoDB `mr-app--xxxx-key-value-store` in `us-east-1` and `ap-northeast-1`. Items are added