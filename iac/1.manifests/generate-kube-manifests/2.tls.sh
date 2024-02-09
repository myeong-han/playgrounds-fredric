cert=/etc/ssl/fredric/server.pem
key=/etc/ssl/fredric/server.key

kubectl create secret tls -n cicd harbor.fredric.playground.cld-tls --cert=$cert --key=$key
