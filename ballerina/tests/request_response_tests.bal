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

import ballerina/log;
import ballerina/lang.runtime;
import ballerina/test;
import ballerina/uuid;

final string[] completedTokens = [];

final Service reqResService = service object {
    remote function onMessage(Message message, Caller caller) returns error? {
        log:printInfo(check string:fromBytes(message.payload));
        check caller->respond({
            payload: ("Response for " + check string:fromBytes(message.payload)).toBytes()
        });
    }

    remote function onError(Error err) returns error? {
        log:printError("Error occured ", err);
    }

    remote function onComplete(DeliveryToken token) returns error? {
        log:printInfo("Message delivered " + token.messageId.toString());
        completedTokens.push(token.topic);
    }
};

@test:Config {enable: true}
function basicRequestResponseTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/basicreqrestest");
    check 'listener.attach(reqResService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for basic req res test";
    check 'client->subscribe("mqtt/response/basicreqrestest");
    check 'client->publish("mqtt/request/basicreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/basicreqrestest"}});
    runtime:sleep(1);

    stream<Message, error?> respStream = check 'client->receiveResponse();
    record {|Message value;|} val = <record {|Message value;|}> check respStream.next();
    test:assertEquals("Response for Test message for basic req res test", check string:fromBytes(val.value.payload));
    test:assertTrue(completedTokens.indexOf(<string>val.value.topic) != ());

    check stopListenerAndClient('listener, 'client);
}

@test:Config {enable: true}
function basicRequestResponseMultipleListenersTest() returns error? {
    Listener 'listener1 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/reqmultiplerestest");
    check 'listener1.attach(reqResService);
    check 'listener1.'start();

    Listener 'listener2 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/reqmultiplerestest");
    check 'listener2.attach(reqResService);
    check 'listener2.'start();

    Listener 'listener3 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/reqmultiplerestest");
    check 'listener3.attach(reqResService);
    check 'listener3.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for req with multiple res test";
    check 'client->subscribe("mqtt/response/reqmultiplerestest");
    check 'client->publish("mqtt/request/reqmultiplerestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/reqmultiplerestest"}});
    runtime:sleep(1);

    stream<Message, error?> respStream = check 'client->receiveResponse();
    record {|Message value;|}? val = check respStream.next();
    test:assertEquals("Response for Test message for req with multiple res test", check string:fromBytes((<record {|Message value;|}> val).value.payload));
    val = check respStream.next();
    test:assertEquals("Response for Test message for req with multiple res test", check string:fromBytes((<record {|Message value;|}> val).value.payload));
    val = check respStream.next();
    test:assertEquals("Response for Test message for req with multiple res test", check string:fromBytes((<record {|Message value;|}> val).value.payload));

    check stopListenerAndClient('listener1);
    check stopListenerAndClient('listener2);
    check stopListenerAndClient('listener3);
}

// @test:Config {enable: true}
// function basicRequestResponseMultiplePublishersTest() returns error? {
//     Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/basicreqrestest");
//     check 'listener.attach(reqResService);
//     check 'listener.'start();

//     Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
//     string message = "Test message for basic req res test";
//     check 'client->subscribe("mqtt/response/basicreqrestest");
//     check 'client->publish("mqtt/request/basicreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/basicreqrestest"}});
//     runtime:sleep(1);

//     stream<Message, error?> respStream = check 'client->receiveResponse();
//     record {|Message value;|}? val = check respStream.next();
//     test:assertEquals("Response for Test message for basic req res test", check string:fromBytes((<record {|Message value;|}> val).value.payload));

//     check stopListenerAndClient('listener, 'client);
// }

// function readResponse(stream<Message, error?> respStream) {
//     while true {
//         record {|Message value;|}? val = check respStream.next();
//         if val == () {
//             break;
//         } else {
//             io:println(string:fromBytes(val.value.payload));
//         }
//     }
// }
