if [ ! -d "/anaconda" ]; then
    wget https://repo.continuum.io/archive/Anaconda3-4.4.0-Linux-x86_64.sh
    bash Anaconda3-4.4.0-Linux-x86_64.sh -b -p /anaconda
    echo "export PATH=/anaconda/bin:$PATH" >> /etc/bash.bashrc
fi

/anaconda/bin/conda update conda
