#!/usr/bin/env bash
#
# This file is part of REANA.
# Copyright (C) 2020, 2023, 2024 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

set -o errexit
set -o nounset

check_commitlint () {
    from=${2:-master}
    to=${3:-HEAD}
    npx commitlint --from="$from" --to="$to"
    found=0
    while IFS= read -r line; do
        if echo "$line" | grep -qP "\(\#[0-9]+\)$"; then
            true
        else
            echo "✖   PR number missing in $line"
            found=1
        fi
    done < <(git log "$from..$to" --format="%s")
    if [ $found -gt 0 ]; then
        exit 1
    fi
}

check_shellcheck () {
    find . -name "*.sh" -exec shellcheck {} \;
}

check_dockerfile () {
    docker run -i --rm docker.io/hadolint/hadolint:v2.12.0 < Dockerfile
}

check_docker_build () {
    docker build -t docker.io/reanahub/blog.reana.io .
}

check_all () {
    check_commitlint
    check_shellcheck
    check_dockerfile
    check_docker_build
}

if [ $# -eq 0 ]; then
    check_all
    exit 0
fi

arg="$1"
case $arg in
    --check-commitlint) check_commitlint "$@";;
    --check-shellcheck) check_shellcheck;;
    --check-dockerfile) check_dockerfile;;
    --check-docker-build) check_docker_build;;
    *) echo "[ERROR] Invalid argument '$arg'. Exiting." && exit 1;;
esac
