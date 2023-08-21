// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
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
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/lang.runtime;
import ballerina/lang.value;
import ballerina/mqtt;
import ballerina/time;
import ballerina/log;
import ballerina/uuid;

const string TOPIC = "mqtt/perf-topic";
const string MQTT_CLUSTER = "tcp://mosquitto:1883";

Payload SENDING_MESSAGE = {
    id: 12501,
    name: "User",
    content: "This is the message content of the load test.",
    extra: "This contains the extra content of load test message record."
};

Payload FINAL_MESSAGE = {
    id: 12501,
    name: "User",
    content: "This is the ending message content of the load test.",
    extra: "This contains the final extra content of load test message record."
};

int errorCount = 0;
int sentCount = 0;
int receivedCount = 0;
time:Utc startedTime = time:utcNow();
time:Utc endedTime = time:utcNow();
boolean finished = false;

service /mqtt on new http:Listener(9100) {

    // public function init() {
    //     log:printInfo("Load test service initializing.");
    //     error? result = startListener();
    //     if result is error {
    //         log:printInfo("Error occurred while starting the listener. " + result.message());
    //         panic result;
    //     }
    //     log:printInfo("Listener started.");
    //     errorCount = 0;
    //     sentCount = 0;
    //     receivedCount = 0;
    //     startedTime = time:utcNow();
    //     endedTime = time:utcNow();
    //     finished = false;
    //     _ = start publishMessages();
    //     log:printInfo("Started publishing messages.");
    // }

    resource function get publish() returns boolean {
        log:printInfo("Received request to start publishing messages.");
        error? result = startListener();
        log:printInfo("Started listener.");
        if result is error {
            return false;
        }
        errorCount = 0;
        sentCount = 0;
        receivedCount = 0;
        startedTime = time:utcNow();
        endedTime = time:utcNow();
        finished = false;
        _ = start publishMessages();
        log:printInfo("Started publishing messages.");
        return true;
    }

    resource function get getResults() returns boolean|map<string> {
        if finished {
            return {
                errorCount: errorCount.toString(),
                time: time:utcDiffSeconds(endedTime, startedTime).toString(),
                sentCount: sentCount.toString(),
                receivedCount: receivedCount.toString()
            };
        }
        return false;
    }
}

function publishMessages() returns error? {
    startedTime = time:utcNow();
    // Publishing messages for 1 hour
    int endingTimeInSecs = startedTime[0] + 3600;
    mqtt:Client 'client = check new(MQTT_CLUSTER, uuid:createType1AsString());
    while time:utcNow()[0] <= endingTimeInSecs {
        mqtt:DeliveryToken|error result = 'client->publish(TOPIC, {
            payload: SENDING_MESSAGE.toJsonString().toBytes()
        });
        if result is error {
            lock {
                errorCount += 1;
            }
        } else {
            sentCount +=1;
        }
        runtime:sleep(0.1);
    }
    mqtt:DeliveryToken|error result = 'client->publish(TOPIC, {
        payload: FINAL_MESSAGE.toJsonString().toBytes()
    });
    if result is error {
        lock {
            errorCount += 1;
        }
    } else {
        sentCount +=1;
    }
}

function startListener() returns error? {
    mqtt:Listener mqttSubscriber = check new (MQTT_CLUSTER, uuid:createType1AsString(), TOPIC);
    check mqttSubscriber.attach(mqttService);
    check mqttSubscriber.start();
    runtime:registerListener(mqttSubscriber);
}

mqtt:Service mqttService =
service object {
    remote function onMessage(mqtt:Message message, mqtt:Caller caller) returns error? {
        string|error messageContent = 'string:fromBytes(message.payload);
        if messageContent is error {
            lock {
                errorCount += 1;
            }
        } else {
            Payload|error payload = value:fromJsonStringWithType(messageContent);
            if payload is error {
                lock {
                    errorCount += 1;
                }
            } else {
                if payload == SENDING_MESSAGE {
                    receivedCount += 1;
                } else if payload == FINAL_MESSAGE {
                    finished = true;
                    endedTime = time:utcNow();
                } else {
                    lock {
                        errorCount += 1;
                    }
                }
            }
        }
    }
};

public type Payload record {|
    int id;
    string name;
    string content;
    string extra;
|};
