#!/bin/bash

source config.env
# TODO: assert that the config values are set

function fill_template() {
	envsubst < $1 | sudo tee $2 > /dev/null
}

# TODO: add SSL creation part....

# SSL security
sudo mkdir -p /etc/kubernetes/ssl
sudo chmod 600 /etc/kubernetes/ssl/*-key.pem
sudo chown root:root /etc/kubernetes/ssl/*-key.pem

# flannel
fill_template ./configs/flannel_options.env /etc/flannel/options.env
sudo cp ./configs/40-ExecStartPre-symlink.conf /etc/systemd/system/flanneld.service.d/40-ExecStartPre-symlink.conf

# docker
sudo cp ./configs/40-flannel.conf /etc/systemd/system/docker.service.d/40-flannel.conf
sudo cp ./configs/docker_opts_cni.env /etc/kubernetes/cni/docker_opts_cni.env
sudo cp ./configs/10-flannel.conf /etc/kubernetes/cni/net.d/10-flannel.conf

# kubelet.service
fill_template ./configs/kubelet.service.in /etc/systemd/system/kubelet.service

fill_template ./configs/kubelet.service.in /etc/systemd/system/kubelet.service
fill_template ./configs/kube-apiserver.yaml.in /etc/kubernetes/manifests/kube-apiserver.yaml
fill_template ./configs/kube-proxy.yaml.in /etc/kubernetes/manifests/kube-proxy.yaml
fill_template ./configs/kube-controller-manager.yaml.in /etc/kubernetes/manifests/kube-controller-manager.yaml
fill_template ./configs/kube-scheduler.yaml.in /etc/kubernetes/manifests/kube-scheduler.yaml

sudo systemctl daemon-reload

etcdctl set /coreos.com/network/config '{ "Network": "${SERVICE_IP_RANGE}" }'
sudo systemctl start flanneld
sudo systemctl start kubelet

curl http://127.0.0.1:8080/version

sudo systemctl enable flanneld
sudo systemctl enable kubelet

# get kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo mv kubectl /opt/bin
