#!/usr/bin/env bash

docker run --rm \
  --network host \
  -v $(pwd)/migrations:/flyway/migrations \
  --env-file .env.local \
  flyway/flyway:11.3-alpine baseline
