#!/bin/bash
set -e

usage="$(basename "$0") [-h] [-i PROJECT] [-v VM] [-p PYTHON] [-d NOTEBOOKS]

Make a user provide SSH key and jupyter notebooks (in roles/bootstrap/files/notebooks) to each user listed in var/common.yml

where:
    -h  show this help text
    -i  google cloud project id
    -v  name of instance/virtual machine
    -p  python path
    -d  if want to copy a notebooks directory"

# constants
PYTHON=/usr/bin/python3
NOTEBOOK_DIR=false

options=':hi:v:p:d:'
while getopts $options option; do
  case "$option" in
    h) echo "$usage"; exit;;
    i) PROJECT=$OPTARG;;
    v) VM=$OPTARG;;
    p) PYTHON=$OPTARG;;
    d) NOTEBOOK_DIR=$OPTARG;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
  esac
done

if [ ! "$PROJECT" ] || [ ! "$VM" ]; then
  echo "arguments -i and -v must be provided"
  echo "$usage" >&2; exit 1
fi

gcloud config set project $PROJECT

# if copying notebooks to the instance
if $NOTEBOOK_DIR; then
  cp -a $NOTEBOOKS_DIR roles/bootstrap/files/notebooks
fi

virtualenv provision_env -p $PYTHON
source provision_env/bin/activate
git clone https://github.com/kennethreitz/delegator.py
cd delegator.py && pip install delegator.py
pip install pyyaml
pip install ansible
cd .. && rm -rf delegator.py
python deploy.py $VM
ansible-playbook -i hosts --private-key gcloud_ansible playbook.yml
