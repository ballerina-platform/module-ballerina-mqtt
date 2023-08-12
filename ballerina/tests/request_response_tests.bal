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
final string[] receivedErrors = [];

final Service reqResService = service object {
    remote function onMessage(Message message, Caller caller) returns error? {
        log:printInfo(check string:fromBytes(message.payload));
        Error? err = caller->respond({
            payload: ("Response for " + check string:fromBytes(message.payload)).toBytes()
        });
        if err is Error {
            receivedErrors.push(err.message());
        }
    }

    remote function onError(Error err) returns error? {
        log:printError("Error occured ", err);
        receivedErrors.push(err.message());
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
    _ = check 'client->publish("mqtt/request/basicreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/basicreqrestest"}});
    runtime:sleep(1);

    stream<Message, error?> respStream = check 'client->receiveResponse();
    record {|Message value;|} val = <record {|Message value;|}>check respStream.next();
    test:assertEquals("Response for Test message for basic req res test", check string:fromBytes(val.value.payload));
    test:assertTrue(completedTokens.indexOf(<string>val.value.topic) != ());

    check stopListenerAndClient('listener, 'client);
}

@test:Config {enable: true}
function basicRequestResponseMultipleListenersTest() returns error? {
    Listener 'listener1 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/reqmultiplerestest");
    Listener 'listener2 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/reqmultiplerestest");
    Listener 'listener3 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/reqmultiplerestest");
    check 'listener1.attach(reqResService);
    check 'listener1.'start();
    check 'listener2.attach(reqResService);
    check 'listener2.'start();
    check 'listener3.attach(reqResService);
    check 'listener3.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for req with multiple res test";
    check 'client->subscribe("mqtt/response/reqmultiplerestest");
    _ = check 'client->publish("mqtt/request/reqmultiplerestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/reqmultiplerestest"}});
    runtime:sleep(1);

    stream<Message, error?> respStream = check 'client->receiveResponse();
    record {|Message value;|} val = <record {|Message value;|}>check respStream.next();
    test:assertEquals("Response for Test message for req with multiple res test", check string:fromBytes(val.value.payload));
    val = <record {|Message value;|}>check respStream.next();
    test:assertEquals("Response for Test message for req with multiple res test", check string:fromBytes(val.value.payload));
    val = <record {|Message value;|}>check respStream.next();
    test:assertEquals("Response for Test message for req with multiple res test", check string:fromBytes(val.value.payload));

    check stopListenerAndClient('listener1);
    check stopListenerAndClient('listener2);
    check stopListenerAndClient('listener3);
}

@test:Config {enable: true}
function basicRequestResponseMultiplePublishersTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/multiplereqrestest");
    check 'listener.attach(reqResService);
    check 'listener.'start();
    string message = "Test message for multiple req res test";

    Client 'client1 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    Client 'client3 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    Client 'client2 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());

    check 'client1->subscribe("mqtt/response/multiplereqrestest/1");
    check 'client2->subscribe("mqtt/response/multiplereqrestest/2");
    check 'client3->subscribe("mqtt/response/multiplereqrestest/3");

    _ = check 'client1->publish("mqtt/request/multiplereqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/multiplereqrestest/1"}});
    _ = check 'client2->publish("mqtt/request/multiplereqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/multiplereqrestest/2"}});
    _ = check 'client3->publish("mqtt/request/multiplereqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/multiplereqrestest/3"}});

    runtime:sleep(1);

    stream<Message, error?> respStream1 = check 'client1->receiveResponse();
    record {|Message value;|} val1 = <record {|Message value;|}>check respStream1.next();
    stream<Message, error?> respStream2 = check 'client2->receiveResponse();
    record {|Message value;|} val2 = <record {|Message value;|}>check respStream2.next();
    stream<Message, error?> respStream3 = check 'client3->receiveResponse();
    record {|Message value;|} val3 = <record {|Message value;|}>check respStream3.next();

    check stopListenerAndClient('listener, 'client1);
    check stopListenerAndClient((), client2);
    check stopListenerAndClient((), 'client3);

    test:assertEquals(check string:fromBytes(val1.value.payload), "Response for Test message for multiple req res test");
    test:assertEquals(val1.value.topic, "mqtt/response/multiplereqrestest/1");
    test:assertEquals(check string:fromBytes(val2.value.payload), "Response for Test message for multiple req res test");
    test:assertEquals(val2.value.topic, "mqtt/response/multiplereqrestest/2");
    test:assertEquals(check string:fromBytes(val3.value.payload), "Response for Test message for multiple req res test");
    test:assertEquals(val3.value.topic, "mqtt/response/multiplereqrestest/3");
}

@test:Config {enable: true}
function requestResponseAsynchronousTest() returns error? {
    string[] receivedValues = [];
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/asyncreqrestest");
    check 'listener.attach(reqResService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for async req res test";
    check 'client->subscribe("mqtt/response/asyncreqrestest");
    _ = check 'client->publish("mqtt/request/asyncreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/asyncreqrestest"}});
    _ = check 'client->publish("mqtt/request/asyncreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/asyncreqrestest"}});
    _ = check 'client->publish("mqtt/request/asyncreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/asyncreqrestest"}});
    _ = check 'client->publish("mqtt/request/asyncreqrestest", {payload: message.toBytes(), properties: {responseTopic: "mqtt/response/asyncreqrestest"}});

    stream<Message, error?> respStream = check 'client->receiveResponse();
    future<error?> f = start readResponse(respStream, receivedValues);
    runtime:sleep(1);
    f.cancel();
    check stopListenerAndClient('listener, 'client);
    test:assertEquals(receivedValues, [
        "Response for Test message for async req res test",
        "Response for Test message for async req res test",
        "Response for Test message for async req res test",
        "Response for Test message for async req res test"
    ]);
}


@test:Config {enable: true}
function sendResponseToNilTopicTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/request/nilrestoptest");
    check 'listener.attach(reqResService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for nil response topic";
    _ = check 'client->publish("mqtt/request/nilrestoptest", {payload: message.toBytes()});
    runtime:sleep(1);
    check stopListenerAndClient('listener, 'client);
    test:assertTrue(receivedErrors.indexOf("Response topic is not set") != ());
}

function readResponse(stream<Message, error?> respStream, string[] receivedValues) returns error? {
    while true {
        record {|Message value;|}? val = check respStream.next();
        if val == () {
            break;
        } else {
            receivedValues.push(check string:fromBytes(val.value.payload));
        }
    }
}
