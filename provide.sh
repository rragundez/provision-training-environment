#!/bin/bash
set -e

usage="$(basename "$0") [-h] [-i PROJECT] [-v VM] [-p PYTHON] [-d NOTEBOOKS]

Make a user provide SSH key and jupyter notebooks (in roles/bootstrap/files/notebooks) to each user listed in var/common.yml

where:
    -h  show this help text
    -i  google cloud project id
    -v  name of instance/virtual machine
    -p  non-anaconda python path [default '/usr/bin/python3']
    -n  notebooks directory to include in the VM"

# constants
PYTHON=/usr/bin/python3
NOTEBOOK_DIR=false

options=':hi:v:p:n:'
while getopts $options option; do
  case "$option" in
    h) echo "$usage"; exit;;
    i) PROJECT=$OPTARG;;
    v) VM=$OPTARG;;
    p) PYTHON=$OPTARG;;
    n) NOTEBOOK_DIR=$OPTARG;;
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

sudo pip install virtualenv
virtualenv provision_env -p $PYTHON
source provision_env/bin/activate
pip install delegator.py pyyaml ansible
python deploy.py $VM
ansible-playbook -i hosts --private-key gcloud_ansible playbook.yml
