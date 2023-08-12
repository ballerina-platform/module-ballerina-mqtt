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

# Represents the client that is used to publish messages to the server.
public client isolated class Client {

    # Creates a new `mqtt:Client`.
    #
    # + serverUri - URI of the server to connect to
    # + clientId - Unique ID of the client
    # + config - Optional configuration values to use for the client
    # + return - `mqtt:Error` if an error occurs while creating the client
    public isolated function init(string serverUri, string clientId, *ClientConfiguration config) returns Error? {
        check self.externInit(serverUri, clientId, config);
    }

    # Publishes a message to a topic.
    #
    # + topic - Topic to publish the message to
    # + message - Message to publish
    # + return - `mqtt:Error` if an error occurs while publishing
    isolated remote function publish(string topic, Message message) returns DeliveryToken|Error {
        return self.externPublish(topic, message);
    }

    # Publishes a message to a topic.
    #
    # + subscriptions - parameter description
    # + return - `mqtt:Error` if an error occurs while publishing
    isolated remote function subscribe(string|string[]|Subscription|Subscription[] subscriptions) returns Error? {
        check self.externSubscribe(processSubscriptions(subscriptions));
    }

    # Receives messages from the server.
    # 
    # + T - Type of the stream to return
    # + return - `mqtt:Error` if an error occurs while reconnecting
    isolated remote function receiveResponse(typedesc<stream<Message, error?>> T = <>) returns T|Error =
    @java:Method {
        name: "externReceive",
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;

    # Closes the connection to the server.
    # + return - `mqtt:Error` if an error occurs while closing
    isolated remote function close() returns Error? {
        check self.externClose();
    }

    # Checks if the client is connected to the server.
    # + return - `true` if the client is connected, `mqtt:Error` if an error occurs in the process
    isolated remote function isConnected() returns boolean|Error {
        return self.externIsConnected();
    }
    
    # Disconnects the client from the server.
    # + return - `mqtt:Error` if an error occurs while disconnecting
    isolated remote function disconnect() returns Error? {
        check self.externDisconnect();
    }

    # Reconnects the client to the server.
    # + return - `mqtt:Error` if an error occurs while reconnecting
    isolated remote function reconnect() returns Error? {
        check self.externReconnect();
    }

    private isolated function externInit(string serverUri, string clientId, *ClientConfiguration config) returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;

    private isolated function externPublish(string topic, Message message) returns DeliveryToken|Error =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;

   private isolated function externSubscribe(Subscription[] subscriptions) returns Error? =
   @java:Method {
       'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
   } external;

    private isolated function externClose() returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;

    private isolated function externIsConnected() returns boolean|Error =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;

    private isolated function externDisconnect() returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;

    private isolated function externReconnect() returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.client.ClientActions"
    } external;
}
