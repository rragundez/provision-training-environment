# Start with the ubuntu image
FROM williamyeh/ansible:ubuntu16.04-onbuild

#  # Set variables for ansible
#  WORKDIR /tmp/ansible
ENV INVENTORY hosts
#  ENV ANSIBLE_LIBRARY /tmp/ansible/library
#  ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH

#  # add playbooks to the image. This might be a git repo instead
#  ADD playbook.yml /etc/ansible/playbook.yml
#  ADD hosts /etc/ansible/hosts
#  ADD roles /etc/ansible/roles
#  ADD vars /etc/ansible/vars
#  WORKDIR /etc/ansible

 # Run ansible using the playbook.yml playbook
 RUN ansible-playbook-wrapper