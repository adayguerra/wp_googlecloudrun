#!/bin/bash
#!/usr/bin/env bash

# Start the sql proxy
cloud_sql_proxy -instances=$CLOUDSQL_INSTANCE=tcp:3306 &

set -e
rm -rf /var/www/html/wp-content/*
gcsfuse -o nonempty  --only-dir wordpress/wp-content test-wp-storage  /var/www/html/wp-content
# Execute the rest of your ENTRYPOINT and CMD as expected.


exec "$@"

