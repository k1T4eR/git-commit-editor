#!/usr/bin/env bash
# http://stackoverflow.com/questions/821396/aborting-a-shell-script-if-any-command-returns-a-non-zero-value
set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

hash=$1

# $1 - name
# $2 - email
function change_author {
    if [ -n "$1" ] && [ -n "$2" ]; then
        echo "export GIT_COMMITTER_NAME=$1
              export GIT_AUTHOR_NAME=$1
              export GIT_COMMITTER_EMAIL=$2
              export GIT_AUTHOR_EMAIL=$2"
    fi
}

# $1 - date
function change_date {
    if [ -n "$1" ]; then
        echo "export GIT_AUTHOR_DATE=$1
              export GIT_COMMITTER_DATE=$1"
    fi
}

function make_changes {
    git filter-branch --env-filter \
    "if test \$GIT_COMMIT = ${hash}
    then
        $(change_author $1 $2)
        $(change_date $3)
    fi" && rm -fr "$(git rev-parse --git-dir)/refs/original/"
}

echo "What do you want to change? [You can choose multiple actions -> 12]"
echo "1. Author"
echo "2. Date"

read action

if [ -n "$action" ]; then
    if [[ ${action} == *"1"* ]]; then
        while [[ -z "$author" ]]; do
            echo "Set commit author:"
            read author
        done

        while [[ -z "$email" ]]; do
            echo "Set author email:"
            read email
        done
    fi

    if [[ $action == *"2"* ]]; then
        while [[ -z "$date" ]]; do
            echo "Set commit date (example: Sat, 14 Dec 2013 12:40:00 +0000):"
            read date
        done
    fi
else
    echo 'Nothing to do. Goodbye ;)'
    exit 1
fi

make_changes ${author:-''} ${email:-''} ${date:-''}