// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/mqtt;
import ballerina/uuid;
import ballerina/lang.runtime;
import ballerina/io;
import ballerina/time;
import temperature_publisher.device;

configurable string TOPIC = "temperature/device-01";

public function main() returns error? {
    mqtt:Client temperaturePublisher = check new (mqtt:DEFAULT_URL, uuid:createType1AsString());
    device:TemperatureDetails startingTemperature = check device:getTemperatureDetails();
    // Sending the starting temperature of the device to the topic to store
    mqtt:DeliveryToken token = check temperaturePublisher->publish(TOPIC, {
        payload: startingTemperature.toJsonString().toBytes(),
        qos: 2,
        retained: true
    });
    io:println(string `Published starting temperature of the device: ${startingTemperature.toJsonString()} at ${time:utcToString(startingTemperature.timestamp)}`);

    // Publishes temperature details while the device is charging
    while device:isCharging() {
        device:TemperatureDetails deviceTemperature = check device:getTemperatureDetails();
        token = check temperaturePublisher->publish(TOPIC, {
            payload: deviceTemperature.toJsonString().toBytes(),
            qos: 2
        });
        io:println(string `Published temperature of the device: ${startingTemperature.toJsonString()} at ${time:utcToString(startingTemperature.timestamp)}`);
        runtime:sleep(1);
    }
}
