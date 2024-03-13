#!/bin/bash

#sudo kubectl create secret generic -n certs ca-key-pair --from-file=ca.crt=/etc/ssl/fredric/rootca.crt --from-file=ca.key=/etc/ssl/fredric/rootca.key
sudo kubectl create secret tls -n certs ca-key-pair --cert=/etc/ssl/fredric/v2/rootca.crt --key=/etc/ssl/fredric/v2/rootca.key
