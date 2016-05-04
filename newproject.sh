#!/bin/bash

PYTHON_VER=3
DJANGO_VER=
GIT_REMOTE=
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

function print_help {
  PROGRAM_NAME=`basename "$0"`
  echo "Usage: $PROGRAM_NAME PROJECT"
  echo
  echo "  -2   use python 2"
  echo "  -3   use python 3 (default)"
  echo "  -d   install specified Django version (use '==1.8' to install v1.8)"
  echo "       you can use >,<,>=,<=,== to specify version"
  echo "  -g   clone specified git repo instead of initializing a new one"
  echo "       if requirements.txt is present in the toplevel directory"
  echo "       the repository, pip install -r requirements.txt is run"
  echo "  -h   show this help"
  echo
  echo "  PROJECT specifies the project name. New directory with that name"
  echo "  will be created and the project will be initialized in this directory."
  echo
}

#################
# parse options #
#################

while getopts "23d:g:h" opt
do
  case "$opt" in
    2)
      PYTHON_VER=2
      ;;
    3)
      PYTHON_VER=3
      ;;
    d)
      DJANGO_VER="$OPTARG"
      ;;
    g)
      GIT_REMOTE="$OPTARG"
      ;;
    h)
      print_help;
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

shift $(( $OPTIND - 1 ))

# parse project name

PROJECT="$1"
shift

if [[ -z "$PROJECT" ]]
then
  echo "No project name specified"  >&2
  exit 1
fi

if [[ ! "$PROJECT" =~ ^[a-zA-Z0-9_-]+$ ]]
then
  echo "Project name can contain only letters, numbers, dash and underscore." >&2
  exit 1
fi

################################
# create the project structure #
################################

message "creating project $PROJECT"

set -e

PYTHON_BIN=`which python$PYTHON_VER`
if [[ "$PYTHON_VER" == "3" ]]
then
  VENV_CREATE="$PYTHON_BIN -m venv"
else
  VENV_CREATE="virtualenv"
fi

# create project dir
mkdir "$PROJECT"
cd "$PROJECT"

# init python virtual environment
$VENV_CREATE "$VENV_DIR"

if [[ -n "$GIT_REMOTE" ]]
then
  # clone git repo
  message "cloning repository"
  git clone "$GIT_REMOTE" "$SOURCE_DIR"
else
  # activate venv and install django
  message "installing django"
  . "$VENV_DIR/bin/activate"
  pip install "django$DJANGO_VER"

  message "creating new django project"
  mkdir "$SOURCE_DIR"
  django-admin startproject "${PROJECT//-/_}" "$SOURCE_DIR"
  cd "$SOURCE_DIR"
  cat > .gitignore <<HEREDOC
*.pyc
__pycache__/
**/LC_MESSAGES/*.mo
HEREDOC
  git init
  git add .
  git commit -m "initialized empty django project"
fi

message -g "new project $PROJECT initialized succesfully"
