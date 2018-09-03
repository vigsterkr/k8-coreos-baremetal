# Get Kubernetes on your single CoreOS baremetal

This is just a simple set of scripts, that will speed up deploying Kubernetes on your CoreOS system.
It is currently a single-node setup, meaning master is a worker as well.

## Config
Fill out the `config.env` based on your requirements.

## TODO:
- [ ] Assert that the config variables are actually filled out in the `config.env`
- [ ] Add SSL cert creation to the `setup.sh` script
