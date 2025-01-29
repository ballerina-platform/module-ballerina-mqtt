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

final string[] receivedMessages = [];

final Service basicService = service object {
    remote function onMessage(Message message) returns error? {
        log:printInfo(check string:fromBytes(message.payload));
        receivedMessages.push(check string:fromBytes(message.payload));
    }

    remote function onError(Error err) returns error? {
        log:printError("Error occured ", err);
    }

    remote function onComplete(DeliveryToken token) returns error? {
        log:printInfo("Message delivered " + token.messageId.toString());
    }
};

@test:Config {enable: true}
function basicPublishSubscribeTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest");
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for basic pub sub test";
    _ = check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);
    addListenerAndClientToArray('listener, 'client);

    lock {
        test:assertTrue(receivedMessages.indexOf(message) != ());
    }
}

@test:Config {enable: true}
function basicPublishSubscribeWithAuthTest() returns error? {
    Listener 'listener = check new (AUTH_ONLY_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: authConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_ONLY_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authConnConfig});
    string message = "Test message for basic pub sub with auth test";
    _ = check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function basicPublishSubscribeWithTLSTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENCRYPTED_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: tlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENCRYPTED_ENDPOINT, uuid:createType1AsString(), {connectionConfig: tlsConnConfig});
    string message = "Test message for basic pub sub with tls test";
    _ = check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function basicPublishSubscribeWithMTLSTest() returns error? {
    Listener 'listener = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: mtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for basic pub sub with mtls test";
    _ = check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function basicPublishSubscribeWithAuthAndMTLSTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message for basic pub sub with auth and mtls test";
    _ = check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function subscribeToMultipleTopicsTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), ["mqtt/topic1", "mqtt/topic2"], {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message1 = "Test message for topic 1";
    string message2 = "Test message for topic 1";
    _ = check 'client->publish("mqtt/topic1", {payload: message1.toBytes()});
    _ = check 'client->publish("mqtt/topic2", {payload: message1.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message1) != ());
    test:assertTrue(receivedMessages.indexOf(message2) != ());
}

@test:Config {enable: true}
function subscribeToSubscriptionTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {topic: "mqtt/subscriptiontopic", qos: 2}, {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message for subscription";
    _ = check 'client->publish("mqtt/subscriptiontopic", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function subscribeToMultipleSubscriptionsTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), [{topic: "mqtt/subscriptiontopic1", qos: 2}, {topic: "mqtt/subscriptiontopic2", qos: 0}], {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message1 = "Test message for subscription1";
    string message2 = "Test message for subscription2";
    _ = check 'client->publish("mqtt/subscriptiontopic1", {payload: message1.toBytes()});
    _ = check 'client->publish("mqtt/subscriptiontopic2", {payload: message2.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message1) != ());
    test:assertTrue(receivedMessages.indexOf(message2) != ());
}

@test:Config {enable: true}
function publishSubscribeWithMTLSTrustKeyStoresTest() returns error? {
    Listener 'listener = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/trustkeystorestopic", {connectionConfig: mtlsWithTrustKeyStoreConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsWithTrustKeyStoreConnConfig});
    string message = "Test message for mtls with trust and key stores";
    _ = check 'client->publish("mqtt/trustkeystorestopic", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

listener Listener manualAcksListener = new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/manualackstopic", {connectionConfig: mtlsConnConfig, manualAcks: true});

service on manualAcksListener {
    remote function onMessage(Message message, Caller caller) returns error? {
        log:printInfo(check string:fromBytes(message.payload));
        receivedMessages.push(check string:fromBytes(message.payload));
        check caller->complete();
    }
    remote function onError(Error err) returns error? {
        log:printError("Error occured ", err);
    }
    remote function onComplete(DeliveryToken token) returns error? {
        log:printInfo("Message delivered " + token.messageId.toString());
    }
};

@test:Config {enable: true}
function subscribeWithManualAcks() returns error? {
    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for manual acks";
    _ = check 'client->publish("mqtt/manualackstopic", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray(manualAcksListener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function closeWithoutDisconnectTest() returns error? {
    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for closing without disconnect";
    _ = check 'client->publish("mqtt/unrelated", {payload: message.toBytes()});
    Error? err = 'client->close();
    if err is Error {
        test:assertEquals(err.message(), "Client is connected");
        test:assertEquals(err.detail().reasonCode, 32100);
    } else {
        test:assertFail("Expected an error when closing without disconnecting");
    }
}

@test:Config {enable: true}
function clientIsConnectedTest() returns error? {
    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for checking if client is connected";
    _ = check 'client->publish("mqtt/unrelated", {payload: message.toBytes()});
    boolean isConnected = check 'client->isConnected();
    test:assertTrue(isConnected);
    check 'client->disconnect();
    isConnected = check 'client->isConnected();
    test:assertFalse(isConnected);
}

@test:Config {enable: true}
function clientReconnectTest() returns error? {
    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for reconnecting with the server";
    _ = check 'client->publish("mqtt/unrelated", {payload: message.toBytes()});
    boolean isConnected = check 'client->isConnected();
    test:assertTrue(isConnected);
    check 'client->disconnect();
    isConnected = check 'client->isConnected();
    test:assertFalse(isConnected);
    check 'client->reconnect();
    runtime:sleep(10);
    isConnected = check 'client->isConnected();
    test:assertTrue(isConnected);
    addListenerAndClientToArray((), 'client);
}

@test:Config {enable: true}
function invalidUrlClientTest() returns error? {
    Client|Error result = new (INVALID_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    if result is Error {
        test:assertEquals(result.message(), string `no NetworkModule installed for scheme "http" of URI "http://localhost:8888"`);
    } else {
        test:assertFail("Expected an error");
    }
}

@test:Config {enable: true}
function invalidUrlListenerTest() returns error? {
    Listener|Error result = new (INVALID_ENDPOINT, uuid:createType1AsString(), "mqtt/unrelated", {connectionConfig: mtlsConnConfig});
    if result is Error {
        test:assertEquals(result.message(), string `no NetworkModule installed for scheme "http" of URI "http://localhost:8888"`);
    } else {
        test:assertFail("Expected an error");
    }
}

@test:Config {enable: true}
function invalidCertPathClientTest() returns error? {
    Client|Error result = new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {
        connectionConfig: {
            secureSocket: {
                cert: SERVER_CERT_PATH,
                key: {
                    path: INCORRECT_KEYSTORE_PATH,
                    password: KEYSTORE_PASSWORD
                }
            }
        }
    });
    if result is Error {
        test:assertEquals(result.message(), string `tests/resources/certsandkeys/invalid-keystore.p12 (No such file or directory)`);
    } else {
        test:assertFail("Expected an error");
    }
}

@test:Config {enable: true}
function invalidCertPathListenerTest() returns error? {
    Listener|Error result = new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/unrelated", {
        connectionConfig: {
            secureSocket: {
                cert: SERVER_CERT_PATH,
                key: {
                    path: INCORRECT_KEYSTORE_PATH,
                    password: KEYSTORE_PASSWORD
                }
            }
        }
    });
    if result is Error {
        test:assertEquals(result.message(), string `tests/resources/certsandkeys/invalid-keystore.p12 (No such file or directory)`);
    } else {
        test:assertFail("Expected an error");
    }
}

@test:Config {enable: true}
function listenerGracefulStopTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/gracefulstoptopic", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message 1 for graceful stop";
    _ = check 'client->publish("mqtt/gracefulstoptopic", {payload: message.toBytes()});
    runtime:sleep(1);
    test:assertTrue(receivedMessages.indexOf(message) != ());
    check 'listener.gracefulStop();
    message = "Test message 2 for graceful stop";
    _ = check 'client->publish("mqtt/gracefulstoptopic", {payload: message.toBytes()});
    test:assertTrue(receivedMessages.indexOf(message) == ());
    addListenerAndClientToArray('client = 'client);
}

@test:Config {enable: true}
function listenerImmediateStopTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/immediatestoptopic", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message 1 for immediate stop";
    _ = check 'client->publish("mqtt/immediatestoptopic", {payload: message.toBytes()});
    runtime:sleep(1);
    test:assertTrue(receivedMessages.indexOf(message) != ());
    check 'listener.immediateStop();
    message = "Test message 2 for immediate stop";
    _ = check 'client->publish("mqtt/immediatestoptopic", {payload: message.toBytes()});
    test:assertTrue(receivedMessages.indexOf(message) == ());
    addListenerAndClientToArray('client = 'client);
}

@test:Config {enable: true}
function listenerDetachTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/detachtopic", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    addListenerAndClientToArray('client = 'client);
    string message = "Test message 1 for detach";
    _ = check 'client->publish("mqtt/detachtopic", {payload: message.toBytes()});
    runtime:sleep(1);
    test:assertTrue(receivedMessages.indexOf(message) != ());
    check 'listener.detach(basicService);
    message = "Test message 2 for detach";
    _ = check 'client->publish("mqtt/detachtopic", {payload: message.toBytes()});
    test:assertTrue(receivedMessages.indexOf(message) == ());
}

@test:Config {enable: true}
function serviceWithoutOnMessageTest() returns error? {
    Listener 'listener = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/noonmessagetopic", {connectionConfig: mtlsConnConfig, manualAcks: true});
    string errorMessage = "";
    Service noOnMsgService = service object {
        remote function onError(Error err) returns error? {
            log:printError("Error occured ", err);
            errorMessage = err.message();
        }
    };
    check 'listener.attach(noOnMsgService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for service without onmessage method";
    _ = check 'client->publish("mqtt/noonmessagetopic", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertEquals(errorMessage, "method onMessage not found");
}

@test:Config {enable: true}
function clientListenerConfigTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/allconnconfigtopic", {
        connectionConfig: {
            username: AUTH_USERNAME,
            password: AUTH_PASSWORD,
            automaticReconnect: false,
            cleanStart: true,
            connectionTimeout: 10,
            keepAliveInterval: 10,
            maxReconnectDelay: 10,
            secureSocket: {
                cert: SERVER_CERT_PATH,
                key: {
                    path: KEYSTORE_PATH,
                    password: KEYSTORE_PASSWORD
                }
            },
            serverUris: ["ssl://localhost:8889", "ssl://localhost:8890"]
        },
        manualAcks: false
    });
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {
        connectionConfig: {
            username: AUTH_USERNAME,
            password: AUTH_PASSWORD,
            automaticReconnect: false,
            cleanStart: true,
            connectionTimeout: 10,
            keepAliveInterval: 10,
            maxReconnectDelay: 10,
            secureSocket: {
                cert: SERVER_CERT_PATH,
                key: {
                    path: KEYSTORE_PATH,
                    password: KEYSTORE_PASSWORD
                }
            },
            serverUris: ["ssl://localhost:8889", "ssl://localhost:8890"]
        }
    });
    string message = "Test message for service with all connection configs";
    _ = check 'client->publish("mqtt/allconnconfigtopic", {payload: message.toBytes()});
    runtime:sleep(1);

    addListenerAndClientToArray('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function sharedSubscriptionsTest() returns error? {
    string receivedValue1 = "";
    string receivedValue2 = "";
    string receivedValue3 = "";
    Service sharedSubscriptionService1 = service object {
        remote function onMessage(Message message) returns error? {
            log:printInfo(check string:fromBytes(message.payload));
            receivedValue1 = check string:fromBytes(message.payload);
        }
    };
    Service sharedSubscriptionService2 = service object {
        remote function onMessage(Message message) returns error? {
            log:printInfo(check string:fromBytes(message.payload));
            receivedValue2 = check string:fromBytes(message.payload);
        }
    };
    Service sharedSubscriptionService3 = service object {
        remote function onMessage(Message message) returns error? {
            log:printInfo(check string:fromBytes(message.payload));
            receivedValue3 = check string:fromBytes(message.payload);
        }
    };

    Listener 'listener1 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "$share/sharinggid/sharedsubscriptionstest");
    Listener 'listener2 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "$share/sharinggid/sharedsubscriptionstest");
    Listener 'listener3 = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "$share/sharinggid/sharedsubscriptionstest");
    check 'listener1.attach(sharedSubscriptionService1);
    check 'listener2.attach(sharedSubscriptionService2);
    check 'listener3.attach(sharedSubscriptionService3);
    check 'listener1.'start();
    check 'listener2.'start();
    check 'listener3.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    addListenerAndClientToArray('listener1, 'client);
    addListenerAndClientToArray('listener2);
    addListenerAndClientToArray('listener3);

    _ = check 'client->publish("sharedsubscriptionstest", {payload: "First message to shared group".toBytes()});
    _ = check 'client->publish("sharedsubscriptionstest", {payload: "Second message to shared group".toBytes()});
    _ = check 'client->publish("sharedsubscriptionstest", {payload: "Third message to shared group".toBytes()});
    runtime:sleep(1);

    string[] expectedValues = ["First message to shared group", "Second message to shared group", "Third message to shared group"];
    if receivedValue1 != "" && receivedValue2 != "" && receivedValue3 != "" &&
        expectedValues.indexOf(receivedValue1) != () &&
        expectedValues.indexOf(receivedValue2) != () &&
        expectedValues.indexOf(receivedValue3) != () &&
        receivedValue1 != receivedValue2 &&
        receivedValue1 != receivedValue3 &&
        receivedValue2 != receivedValue3 {
        test:assertTrue(true);
    } else {
        test:assertFail("Expected values not received correctly");
    }
}

@test:Config {enable: true}
function clientWillMessageTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/willmessagetopic");
    check 'listener.attach(basicService);
    check 'listener.'start();

    string message = "Test message for will message";
    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), {
        willDetails: {
            willMessage: {
                payload: "This is my last will message".toBytes()
            },
            destinationTopic: "mqtt/willmessagetopic"
        }
    });
    addListenerAndClientToArray('listener, 'client);

    _ = check 'client->publish("sharedsubscriptionstest", {payload: message.toBytes()});
    runtime:sleep(1);

    test:assertTrue(receivedMessages.indexOf(message) == ());
}
