#!/bin/env python
import os
import sys
import delegator

import yaml

KEY_PATH = "gcloud_ansible"
KEYS_PATH = 'keys'
YAML_PATH = "vars/common.yml"
HOSTS_PATH = 'hosts'


def create_key_pair(key_path):
    if not os.path.isfile(key_path):
        delegator.run('ssh-keygen -b 2048 -t rsa -f %s -q -N ""' % key_path)


def load_yml(path):
    with open(path, 'r') as f:
        data = yaml.safe_load(f)
    return data


def load_key(path):
    with open(path + ".pub", 'r') as f:
        key = f.read()
    return key


def write_users(yml, key, key_path):
    with open(key_path, 'w') as f:
        for user in yml.get('users', []) + [yml.get('deployer')]:
            f.write(''.join([user, ':', key]))


def add_keys_to(instance_tag, key_path):
    # TODO This method could be optional
    delegator.run(("gcloud compute instances add-metadata %s "
                   "--metadata-from-file sshKeys=%s") % (instance_tag, key_path))


def get_ip_of(instance_tag):
    # TODO This method could be optional
    c = delegator.run(('gcloud --format="value(networkInterfaces[0].accessConfigs[0].natIP)" '
                       'compute instances list %s') % instance_tag)
    external_ip = c.out.strip()
    return external_ip


def write_ip_to(hosts_path, external_ip):
    with open(hosts_path, 'w') as f:
        f.write('[master]')
        f.write('\n')
        f.write(external_ip)
        f.write('\n')


def get_variables():
    return (os.environ.get('KEY_PATH', KEY_PATH),
            os.environ.get('KEYS_PATH', KEYS_PATH),
            YAML_PATH,
            HOSTS_PATH)


def main(instance_tag):
    key_path, keys_path, yaml_path, hosts_path = get_variables()
    create_key_pair(key_path)
    yml = load_yml(yaml_path)
    key = load_key(key_path)
    write_users(yml, key, keys_path)
    add_keys_to(instance_tag, keys_path)
    external_ip = get_ip_of(instance_tag)
    write_ip_to(hosts_path, external_ip)


if __name__ == "__main__":
    instance_tag = os.environ.get('INSTANCE_TAG')

    # TODO I have to decide on the API here
    if not instance_tag:
        instance_tag = sys.argv[1]

    main(instance_tag)


#delegator.run("ansible-playbook -i hosts --private-key %s playbook.yml" % KEY_PATH)
