# Temperature Sensor

[![Star on Github](https://img.shields.io/badge/-Star%20on%20Github-blue?style=social&logo=github)](https://github.com/ballerina-platform/module-ballerina-mqtt)

_Authors_: @shafreenAnfar @dilanSachi \
_Reviewers_: @shafreenAnfar \
_Created_: 2023/08/22 \
_Updated_: 2023/08/22

## Overview
In this example, an `mqtt:Client` publishes temperature details of a device from time to time. An `mqtt:Listener` 
reads these data and analyzes whether there is a significant deviation. If there is a deviation, it will 
send an email to the user (Note that the email sending part is not implemented in this sample).

## Implementation

![Temperature Sensor](topology.png)

#### Setting Up MQTT
1. [Install MQTT in your local machine](https://mosquitto.org/download/)
2. [Use MQTT with docker](https://hub.docker.com/_/eclipse-mosquitto)

* You can find the docker file used to set up the cluster for this example in [here](../../ballerina/tests/resources/compose.yaml).

## Run the Example

First, clone this repository, and then, run the following commands in the given order to run this example in your local machine. Use separate terminals for each step.

1. Start the Temperature analyzer service.
```sh
$ cd examples/temperature-sensor/temperature-analyzer
$ bal run
```
2. Start the Temperature publisher.
```sh
$ cd examples/temperature-sensor/temperature-publisher
$ bal run
```
You will be able to see the logs of published temperature details and any email logs if there was a significant deviation.
