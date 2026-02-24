#!/bin/bash
# Retry Library: Exponential backoff with circuit breaker

retry_with_backoff() {
    local max_attempts=5
    local timeout=1
    local attempt=1
    local exitCode=0

    while [ $attempt -le $max_attempts ]; do
        set +e
        "$@"
        exitCode=$?
        set -e

        if [ $exitCode -eq 0 ]; then
            return 0
        fi

        echo "Attempt $attempt/$max_attempts failed (exit $exitCode). Retrying in ${timeout}s..." >&2
        sleep $timeout
        timeout=$((timeout * 2))  # Exponential backoff: 1s, 2s, 4s, 8s
        attempt=$((attempt + 1))
    done

    echo "All $max_attempts attempts failed. Entering degraded mode." >&2
    return $exitCode
}
