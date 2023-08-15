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

# Represents the client that is used to complete received messages.
public client isolated class Caller {

    # Completes the received message.
    # ```ballerina
    # check caller->complete();
    #```
    # 
    # + return - `mqtt:Error` if the message cannot be completed or else `()`
    isolated remote function complete() returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.caller.CallerActions"
    } external;

    # Send the response for the request message.
    # ```ballerina
    # check caller->respond({payload: "Hello Response".toBytes()});
    # ```
    #
    # + response - The response message to be sent
    # + return - `mqtt:Error` if the message cannot be sent or `()`
    isolated remote function respond(Message response) returns Error? =
    @java:Method {
        'class: "io.ballerina.stdlib.mqtt.caller.CallerActions"
    } external;
}
