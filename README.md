# Provision training environment

This is the repository to provision a training environment in Google cloud.

We are currently in the process of making it grow to become more robust and serve more targets. The environment is delivered with anaconda and extra packages defined in the `/roles/bootstrap/templates/environment.yml`.

## Prerequisites

 - You need to have the gcloud CLI installed. https://cloud.google.com/sdk/

## Usage

Once you have create your cluster, you need three things:

 - The Google cloud `project_id`, not to be confused with `project_name`
 - The `vm_instance_name` (f.e. `cluster-1-m`)
 - The list of users (put them into `vars/common.yml`, under `users`);

Important but optional add-ons:
 - The path to a `environment.yml` file that you want to add to anaconda (`env_file`)
 - Your local non-anaconda python path (`python_path`). Defaults to `/usr/bin/python3`
 - The notebooks directory you want to upload to the vm and make available to each user (`local_notebooks_dir`)

Then from the root directory of this repository execute

```
bash provide.sh -i <project_id> -v <vm_instance_name>
```

or with the optional add-ons

```
bash provide.sh -i <project_id> -v <vm_instance_name> -p <python_path> -e <env_file> -n <local_notebooks_dir>
```

You should be good to go now! check you can ssh to it by:

```
ssh -i gcloud_ansible -o IdentitiesOnly=yes deploy@<master_external_ip>
```

The `master_external_ip` can be found in the `hosts` file.

Distribute the key in the `gcloud_ansible` file to your users, and they should also be able to log in.

Finally make them deploy their notebooks and tunnel a port (each user should use a different port).

```
ssh -i gcloud_ansible -o IdentitiesOnly=yes -L <port>:localhost:<port> <my_user>@<master_external_ip>
jupyter notebook --port <port>
```

NOTE: This is not for a secure environment, where everybody has their own key. However, as all users
have sudo privileges anyway, that doesn't really matter.


## Testing

If you have docker, be sure to have `localhost` as master in your `hosts`. Then

```
docker build -t gcloud_ansible .
```
