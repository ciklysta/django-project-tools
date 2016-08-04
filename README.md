# Tools for managing django projects #

## Overview ##

One often uses Django within Python's virtual environment and uses Git for 
version control. The following tools facilitate creation of a new project,
as long as deployment process.

### Used directory structure ###

```
projectname
|
+- pyvenv
|
+- source
```

- ``pyvenv`` contains Python virtual environment
- ``source`` contains source code - structured as when run ``django-admin startproject`` - this directory is also under Git version control

## Commands ##

### newproject.sh ###

Script for creating an empty project or cloning existing project from a git repo while also initializing python virtual environment.
It is also used for the first time deployment on a server.

See ``newproject.sh -h`` for usage.

### updateproject.sh ###

Script for updating existing project. Used mainly for deployment. It fetches changes from Git and then runs all usual tasks:
- compiles gettext's files
- collects static files
- runs migrations

usage: ``updateproject.sh [directory]`` where ``directory`` is a dir created using ``newproject.sh`` command
and it contains pyvenv and source directories
