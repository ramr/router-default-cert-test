#!/bin/bash

SUBJECT="/C=US/ST=CA/O=Security/OU=OpenShift3/CN=router.test"
VALIDITY=7305  #  7305 days is 20 years and if the started docker
	       #  container is around at that time ... kudos!! Its time for
	       # a new cert!!

#
#  main():
#
rm -f router.key router.key.ORIG router.csr router.crt
echo "  - Generating private key ... "
openssl genrsa -out router.key

echo "  - Generating csr ... "
openssl req -new -key router.key -out router.csr -subj "${SUBJECT}"

echo "  - Removing passphrase ... "
cp router.key router.key.ORIG
openssl rsa -in router.key.ORIG -out router.key

echo "  - Generating certificate ... "
openssl x509 -req -days ${VALIDITY} -in router.csr -signkey router.key -out router.crt

cat router.crt router.key router.key > router.pem
oc delete rc/router-1 dc/router service/router secrets/router-certs

echo "  - Starting up the router ..."
oadm router --replicas=1  --default-cert=router.pem --latest-images=true

echo "  - Adding test routes (recreate aka delete+create)... "
oc delete -f route-using-custom-cert.json
oc create -f route-using-custom-cert.json

oc delete -f route-using-default-cert.json 
oc create -f route-using-default-cert.json 

echo ""
echo "Waiting max 1 minute for router to come up ... " 
end_time=$((60 + $(date +"%s")))

while true; do
  echo -n "."
  httpcode=$(curl $timeout_opts -s -o /dev/null -I -w "%{http_code}" http://localhost:1936/healthz)
  [ "$httpcode" == "200" ] && break
  [ $(date +"%s") -ge $end_time ] &&  break
  sleep 1
done

echo ""
echo ""
echo "Wait for the routes to become availabe and you can check the certs with: "
echo "  curl -s -k -v --resolve custom.cert.test:443:127.0.0.1 https://custom.cert.test/ 2>&1 | egrep -e 'subject|issuer|Host'"
echo "  curl -s -k -v --resolve default-router.cert.test:443:127.0.0.1 https://default-router.cert.test/ 2>&1 | egrep -e 'subject|issuer|Host'"

