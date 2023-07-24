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

import ballerina/jballerina.java;

# Represents a MQTT listener endpoint.
public isolated client class Listener {

    private final Subscription[] & readonly mqttSubscriptions;

    # Creates a new `mqtt:Listener`.
    #
    # + serverUri - The URI of the remote MQTT server
    # + clientId - The unique client ID to identify the listener
    # + subscriptions - The topics to be subscribed to
    # + return - `mqtt:Error` if an error occurs while creating the listener
    public isolated function init(string serverUri, string clientId, string|string[]|Subscription|Subscription[] subscriptions, *ListenerConfiguration config) returns Error? {
        if subscriptions is Subscription {
            self.mqttSubscriptions = [subscriptions.cloneReadOnly()];
        } else if subscriptions is string {
            self.mqttSubscriptions = [{
                topic: subscriptions,
                qos: 1
            }];
        } else if subscriptions is string[] {
            Subscription[] mqttSubscriptions = [];
            foreach string topic in subscriptions {
                mqttSubscriptions.push({
                    topic: topic,
                    qos: 1
                });
            }
            self.mqttSubscriptions = mqttSubscriptions.cloneReadOnly();
        } else if subscriptions is Subscription[] {
            self.mqttSubscriptions = subscriptions.cloneReadOnly();
        } else {
            panic error("Invalid topics provided");
        }
        check self.externInit(serverUri, clientId, config);
    }

    private isolated function externInit(string serverUri, string clientId, *ListenerConfiguration config) returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.listener.ListenerActions"
    } external;

    # Starts the registered services.
    # ```ballerina
    # error? result = listener.'start();
    # ```
    #
    # + return - A `error` if an error is encountered while starting the server or else `()`
    public isolated function 'start() returns error? {
        check self.externStart(self.mqttSubscriptions);
    };

    private isolated function externStart(Subscription[] topics) returns error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.listener.ListenerActions"
    } external;

    # Stops the MQTT listener gracefully.
    # ```ballerina
    # error? result = listener.gracefulStop();
    # ```
    #
    # + return - A `error` if an error is encountered during the listener-stopping process or else `()`
    public isolated function gracefulStop() returns error?  =
    @java:Method {
        name: "externGracefulStop",
        'class: "io.ballerina.stdlib.mqtt.listener.ListenerActions"
    } external;

    # Stops the mqtt listener immediately.
    # ```ballerina
    # error? result = listener.immediateStop();
    # ```
    #
    # + return - A `error` if an error is encountered during the listener-stopping process or else `()`
    public isolated function immediateStop() returns error? =
    @java:Method {
        name: "externImmediateStop",
        'class: "io.ballerina.stdlib.mqtt.listener.ListenerActions"
    } external;

    # Attaches a service to the listener.
    # ```ballerina
    # error? result = listener.attach(mqttService);
    # ```
    #
    # + 'service - The service to be attached
    # + name - Name of the service
    # + return - A `error` if an error is encountered while attaching the service or else `()`
    public isolated function attach(Service 'service, string[]|string? name = ()) returns error? =
    @java:Method {
        name: "externAttach",
        'class: "io.ballerina.stdlib.mqtt.listener.ListenerActions"
    } external;

    # Detaches a consumer service from the listener.
    # ```ballerina
    # error? result = listener.detach(mqttService);
    # ```
    #
    # + 'service - The service to be detached
    # + return - A `error` if an error is encountered while detaching a service or else `()`
    public isolated function detach(Service 'service) returns error? =
    @java:Method {
        name: "externDetach",
        'class: "io.ballerina.stdlib.mqtt.listener.ListenerActions"
    } external;
}
