#!/bin/sh

set +u
profile=${1?missing profile name}
creds_file=${AWS_SHARED_CREDENTIALS_FILE-~/.aws/credentials}
set -u

do_add() {
  read -r id &&
    read -r secret &&
    cat <<EOS >>"$creds_file"

[$profile]
aws_access_key_id = $id
aws_secret_access_key = $secret
EOS
}

do_add
