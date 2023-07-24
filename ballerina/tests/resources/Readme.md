# Configure Mosquitto server

Details about the mosquitto conf file can be found [here](https://mosquitto.org/man/mosquitto-conf-5.html).

In order to setup the server with a `username:password` pair, exec into the docker image (`docker exec -it #container_name sh`) and do `mosquitto_passwd -c /mosquitto/passwd_file #username`. Provide an intended password and copy the passwd_file content and mount it when the container is run.
