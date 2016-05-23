#!/bin/bash

PYTHON_VER=3
DJANGO_VER=
GIT_REMOTE=
GIT_BRANCH=
VENV_DIR="pyvenv"
SOURCE_DIR="source"

if [ -t 1 ]
then
  function message() {
    if [ "$1" == "-g" ]
    then
      shift
      color=32
    else
      color=33
    fi

    printf "\033[0;${color}m$*\033[0m\n"
  }
else
  function message() {
    [ "$1" == "-g" ] && shift

    echo "$*"
  }
fi

if [[ -z "$1" ]]
then
  echo "No project dir specified"  >&2
  exit 1
fi

set -e # exit the whole script on first failure

cd "$1"

if [[ ! ( -d "$VENV_DIR" && -d  "$SOURCE_DIR" ) ]]
then
    echo "given directory $1 doens't look like containing django project" >&2
    exit 1
fi

. "${VENV_DIR}/bin/activate" # activate the python virtual environment

cd "$SOURCE_DIR"

CURRENT_GIT_HEAD=`git rev-parse HEAD`

# load new changes from git
git pull
if [[ "$CURRENT_GIT_HEAD" == `git rev-parse HEAD` ]]
then
    message -g "no changes in git"
    exit 0
fi

# changes in git

# compile gettext messages
python manage.py compilemessages

# update static assets
python manage.py collectstatic --no-input

# migrate the db
python manage.py migrate

message -g "project updated"
