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

import ballerina/lang.value;
import ballerina/log;
import ballerina/time;
import ballerina/mqtt;
import ballerina/uuid;

configurable string TOPIC = "temperature/+";

isolated service on new mqtt:Listener(mqtt:DEFAULT_URL, uuid:createType1AsString(), TOPIC, {manualAcks: false}) {

    private final map<TemperatureDetails & readonly> startingTemperatures = {};

    isolated remote function onMessage(mqtt:Message message, mqtt:Caller caller) returns error? {
        TemperatureDetails & readonly temperature = check value:fromJsonStringWithType(check string:fromBytes(message.payload));
        lock {
            if !self.startingTemperatures.hasKey(temperature.deviceId) {
                self.startingTemperatures[temperature.deviceId] = temperature;
                log:printInfo(string `Received starting temperature reading from device: ${temperature.deviceId} at ${time:utcToString(temperature.timestamp)} with temperature ${temperature.temperature}`);
            } else {
                log:printInfo(string `Received temperature reading from device: ${temperature.deviceId} at ${time:utcToString(temperature.timestamp)} with temperature ${temperature.temperature}`);
                self.analyzeTemperatureAndNotify(temperature);
            }
        }
        check caller->complete();
    }

    isolated function analyzeTemperatureAndNotify(TemperatureDetails temperatureDetails) {
        lock {
            if temperatureDetails.temperature - self.startingTemperatures.get(temperatureDetails.deviceId).temperature > 30.0 {
                log:printInfo(string `Temperature is above threshold. Sending email notification`);
            }
        }
    }
}

type TemperatureDetails record {|
    string deviceId;
    float temperature;
    time:Utc timestamp;
|};

