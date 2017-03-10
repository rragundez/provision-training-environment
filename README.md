# Provision training environment

This is the repository to provision the training environment for the Data Science with Spark
training.

We are currently in the process of making it grow to become more robust and serve more targets
(possibly with Anaconda installed).

## Usage

Once you have create your cluster, you need three things:

- The master name (f.e. `cluster-1-m`);
- The list of users (put them into `var/common.yml`, under `users`);
- The notebooks you want to upload stored in `roles/bootstrap/files/notebooks`.

Then execute

```
python deploy.py `cluster-1-m`
ansible-playbook -i hosts --private-key gcloud_ansible playbook.yml
```

You should be good to go now!

```
ssh -i gcloud_ansible -L <port>:localhost:<port> <my_user>@<master_external_ip>
jupyter notebook --port <port>
```

Distribute the key to your users, and they should also be able to log in.



NOTE: This is not for a secure environment, where everybody has their own key. However, as all users
have sudo privileges anyway, that doesn't really matter.


## Testing

If you have docker, be sure to have `localhost` as master in your `var/common.yml`. Then

```
docker build -t gcloud_ansible .
```