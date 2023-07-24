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

    remote function onCompleted(DeliveryToken token) returns error? {
        log:printInfo("Message delivered " + token.messageId.toString());
        log:printInfo(check string:fromBytes(token.message.payload));
    }
};

@test:Config {enable: true}
function basicPublishSubscribeTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest");
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENDPOINT, uuid:createType1AsString());
    string message = "Test message for basic pub sub test";
    check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

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
    check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function basicPublishSubscribeWithTLSTest() returns error? {
    Listener 'listener = check new (NO_AUTH_ENCRYPTED_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: tlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_ENCRYPTED_ENDPOINT, uuid:createType1AsString(), {connectionConfig: tlsConnConfig});
    string message = "Test message for basic pub sub with tls test";
    check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function basicPublishSubscribeWithMTLSTest() returns error? {
    Listener 'listener = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: mtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for basic pub sub with mtls test";
    check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function basicPublishSubscribeWithAuthAndMTLSTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/basictest", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message for basic pub sub with auth and mtls test";
    check 'client->publish("mqtt/basictest", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

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
    check 'client->publish("mqtt/topic1", {payload: message1.toBytes()});
    check 'client->publish("mqtt/topic2", {payload: message1.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

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
    check 'client->publish("mqtt/subscriptiontopic", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

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
    check 'client->publish("mqtt/subscriptiontopic1", {payload: message1.toBytes()});
    check 'client->publish("mqtt/subscriptiontopic2", {payload: message2.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

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
    check 'client->publish("mqtt/trustkeystorestopic", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function subscribeWithManualAcks() returns error? {
    Listener 'listener = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/manualackstopic", {connectionConfig: mtlsConnConfig, manualAcks: true});
    Service manualAcksService = service object {
        remote function onMessage(Message message, Caller caller) returns error? {
            log:printInfo(check string:fromBytes(message.payload));
            receivedMessages.push(check string:fromBytes(message.payload));
            check caller->complete();
        }
        remote function onError(Error err) returns error? {
            log:printError("Error occured ", err);
        }
        remote function onCompleted(DeliveryToken token) returns error? {
            log:printInfo("Message delivered " + token.messageId.toString());
            log:printInfo(check string:fromBytes(token.message.payload));
        }
    };
    check 'listener.attach(manualAcksService);
    check 'listener.'start();

    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for manual acks";
    check 'client->publish("mqtt/manualackstopic", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}

@test:Config {enable: true}
function closeWithoutDisconnectTest() returns error? {
    Client 'client = check new (NO_AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: mtlsConnConfig});
    string message = "Test message for closing without disconnect";
    check 'client->publish("mqtt/unrelated", {payload: message.toBytes()});
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
    check 'client->publish("mqtt/unrelated", {payload: message.toBytes()});
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
    check 'client->publish("mqtt/unrelated", {payload: message.toBytes()});
    boolean isConnected = check 'client->isConnected();
    test:assertTrue(isConnected);
    check 'client->disconnect();
    isConnected = check 'client->isConnected();
    test:assertFalse(isConnected);
    check 'client->reconnect();
    runtime:sleep(10);
    isConnected = check 'client->isConnected();
    test:assertTrue(isConnected);
    check stopListenerAndClient('client = 'client);
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
    check 'client->publish("mqtt/gracefulstoptopic", {payload: message.toBytes()});
    runtime:sleep(1);
    test:assertTrue(receivedMessages.indexOf(message) != ());
    check 'listener.gracefulStop();
    message = "Test message 2 for graceful stop";
    check 'client->publish("mqtt/gracefulstoptopic", {payload: message.toBytes()});
    test:assertTrue(receivedMessages.indexOf(message) == ());
    check stopListenerAndClient('client = 'client);
}

@test:Config {enable: true}
function listenerImmediateStopTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/immediatestoptopic", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message 1 for immediate stop";
    check 'client->publish("mqtt/immediatestoptopic", {payload: message.toBytes()});
    runtime:sleep(1);
    test:assertTrue(receivedMessages.indexOf(message) != ());
    check 'listener.immediateStop();
    message = "Test message 2 for immediate stop";
    check 'client->publish("mqtt/immediatestoptopic", {payload: message.toBytes()});
    test:assertTrue(receivedMessages.indexOf(message) == ());
    check stopListenerAndClient('client = 'client);
}

@test:Config {enable: true}
function listenerDetachTest() returns error? {
    Listener 'listener = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), "mqtt/detachtopic", {connectionConfig: authMtlsConnConfig});
    check 'listener.attach(basicService);
    check 'listener.'start();

    Client 'client = check new (AUTH_MTLS_ENDPOINT, uuid:createType1AsString(), {connectionConfig: authMtlsConnConfig});
    string message = "Test message 1 for detach";
    check 'client->publish("mqtt/detachtopic", {payload: message.toBytes()});
    runtime:sleep(1);
    test:assertTrue(receivedMessages.indexOf(message) != ());
    check 'listener.detach(basicService);
    message = "Test message 2 for detach";
    check 'client->publish("mqtt/detachtopic", {payload: message.toBytes()});
    test:assertTrue(receivedMessages.indexOf(message) == ());
    check stopListenerAndClient('client = 'client);
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
    check 'client->publish("mqtt/noonmessagetopic", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

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
    check 'client->publish("mqtt/allconnconfigtopic", {payload: message.toBytes()});
    runtime:sleep(1);

    check stopListenerAndClient('listener, 'client);

    test:assertTrue(receivedMessages.indexOf(message) != ());
}
