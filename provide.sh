#!/bin/bash
set -e

usage="$(basename "$0") [-h] [-i PROJECT] [-v VM] [-p PYTHON] [-e ENVIRONMENT] [-n NOTEBOOKS]

Make a user provide SSH key and jupyter notebooks (in roles/bootstrap/files/notebooks) to each user listed in var/common.yml

where:
    -h  show this help text
    -i  google cloud project id
    -v  name of instance/virtual machine
    -p  non-anaconda python path [default '/usr/bin/python3']
    -e  environment.yml fullpath to install in native anaconda
    -n  notebooks directory to include in the VM"

# constants
PYTHON=/usr/bin/python3

options=':hi:v:p:e:n:'
while getopts $options option; do
  case "$option" in
    h) echo "$usage"; exit;;
    i) PROJECT=$OPTARG;;
    v) VM=$OPTARG;;
    p) PYTHON=$OPTARG;;
    e) ENVIRONMENT_FILE_PATH=$OPTARG;;
    n) NOTEBOOKS_DIR=$OPTARG;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
  esac
done

if [ ! "$PROJECT" ] || [ ! "$VM" ]; then
  echo "arguments -i and -v must be provided"
  echo "$usage" >&2; exit 1
fi

gcloud config set project $PROJECT

if [[ $ENVIRONMENT_FILE_PATH ]]; then
  echo "Copying envrionment file '${ENVIRONMENT_FILE_PATH}'"
  cp $ENVIRONMENT_FILE_PATH roles/bootstrap/templates
fi


sudo pip install virtualenv
virtualenv provision_env -p $PYTHON
source provision_env/bin/activate
pip install delegator.py pyyaml ansible
python deploy.py $VM

# if copying notebooks to the instance
# for some reason ansible takes hours to copy them
# here we use SCP directly
if [[ $NOTEBOOKS_DIR ]]; then
  echo "Getting the IP"
  IP=$(gcloud --format="value(networkInterfaces[0].accessConfigs[0].natIP)" compute instances list "$VM")
  echo "Deleting the notebooks_tmp direcotry"
  ssh -i gcloud_ansible -o IdentitiesOnly=yes deploy@"$IP" 'rm -rf /tmp/notebooks_tmp'
  echo "Creating the notebooks_tmp direcotry"
  ssh -i gcloud_ansible -o IdentitiesOnly=yes deploy@"$IP" 'mkdir -p /tmp/notebooks_tmp'
  echo "Copying notebooks directory '${NOTEBOOKS_DIR}' to the VM"
  scp -i gcloud_ansible -o IdentitiesOnly=yes -r "$NOTEBOOKS_DIR"/* deploy@"$IP":/tmp/notebooks_tmp
fi

ansible-playbook -i hosts --private-key gcloud_ansible playbook.yml
