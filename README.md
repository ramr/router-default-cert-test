# router-default-cert-test
router default cert test

This example assumes that you have setup a deployment config and services
based on: https://github.com/ramr/nodejs-header-echo

You don't really need to deploy the examples from there as long as you have
a service and backing pods for the test. You can just edit the routes before
you run the curl commands.

Run the test script

     ./test.sh


That should start up the router and wait for it to come up.

If you are *NOT* using the examples based on:
https://github.com/ramr/nodejs-header-echo

then edit the 2 routes and point to your test service.

    oc edit route  default-router-cert
    oc edit route  custom-cert-test

And in each of the routes change the header-test-insecure to
point to your custom service aka `s/header-test-insecure/$yourservice/g`:

    spec:
      to:
        kind: Service
          name: $your_service_name_here   #  replace header-test-insecure




