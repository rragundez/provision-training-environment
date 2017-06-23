if [ ! -d "/anaconda" ]; then
    wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
    bash Anaconda3-4.2.0-Linux-x86_64.sh -b -p /anaconda
    echo "export PATH=/anaconda/bin:$PATH" >> /etc/bash.bashrc
    echo "export PYSPARK_PYTHON=/anaconda/bin/python" >> /etc/bash.bashrc
fi

/anaconda/bin/conda config --add channels conda-forge

ln_conda=$(grep -n "dependencies:" environment.yml | grep -Eo '^[^:]+')
ln_pip=$(grep -n "pip:" environment.yml | grep -Eo '^[^:]+')
ln_prefix=$(grep -n "prefix:" environment.yml | grep -Eo '^[^:]+')
# conda packages
if [ -z "$ln_pip" ]; then
  if [ -z "$ln_prefix" ]; then
    c=$(awk "NR > ${ln_conda}" environment.yml | cut -c3-)
  else
    c=$(awk "NR > ${ln_conda} && NR < ${ln_prefix}" environment.yml | cut -c3-)
  fi
else
  c=$(awk "NR > ${ln_conda} && NR < ${ln_pip}" environment.yml | cut -c3-)
fi
/anaconda/bin/conda install -y $c

# pip packages
if [ -z "$ln_prefix" ]; then
  p=$(awk "NR > ${ln_pip}" environment.yml | cut -c5-)
else
  p=$(awk "NR > ${ln_pip} && NR < ${ln_prefix}" environment.yml | cut -c5-)
fi
/anaconda/bin/pip install $p
