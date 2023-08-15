# Specification: Ballerina MQTT Library

_Owners_: @shafreenAnfar @dilanSachi    
_Reviewers_: @shafreenAnfar  
_Created_: 2023/08/14    
_Updated_: 2023/08/14   
_Edition_: Swan Lake

## Introduction
This is the specification for the MQTT standard library of [Ballerina language](https://ballerina.io/), which can send and receive messages 
by connecting to a MQTT broker.

The MQTT library specification has evolved and may continue to evolve in the future. The released versions of the 
specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the 
[Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community 
feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals 
under discussion can be found with the label `type/proposal` in GitHub.

The conforming implementation of the specification is released to Ballerina central. Any deviation from the specification 
is considered a bug.

## Contents
1. [Overview](#1-overview)
2. [Configurations](#2-configurations)
    *  2.1. [Security Configurations](#21-security-configurations)
3. [Client](#3-producer)
    *  3.1. [Configurations](#31-configurations)
    *  3.2. [Initialization](#32-initialization)
        *    3.2.1. [Insecure Client](#321-insecure-client)
        *    3.2.2. [Secure Client](#322-secure-client)
    *  3.3. [Functions](#33-functions)
4. [Subscriber](#4-consumer)
    *  4.1. [Configurations](#41-configurations)
    *  4.3. [Listener](#43-listener)
        *  4.3.1. [Initialization](#431-initialization)
            *  4.3.1.1. [Insecure Listener](#4311-insecure-listener)
            *  4.3.1.2. [Secure Listener](#4312-secure-listener)
        *  4.3.2. [Usage](#432-usage)
        *  4.3.3. [Caller](#433-caller)
5. [Samples](#5-samples)
    *  5.1. [Publish Messages](#51-produce-messages)
    *  5.2. [Subscribe to Messages](#52-consume-messages)

## 1. Overview
MQTT is a lightweight, publish-subscribe, machine to machine network protocol for message queue/message queuing service.
This specification elaborates on the usage of MQTT clients that connect and interact with the MQTT broker. These clients 
allow publishing and subscribing messages to and from the MQTT broker with resource constraints or limited network 
bandwidth, such as in the Internet of Things.

Ballerina MQTT supports MQTTv5. Currently, it contains two core apis:
* Client - Used to publish messages to the MQTT broker.
* Listener - Used to get the messages from the MQTT broker.

## 2. Configurations
### 2.1. Security Configurations
* `mqtt:CertKey` represents the certificate and the private key of the client.
```ballerina
public type CertKey record {|
    # A file containing the certificate
    string certFile;
    # A file containing the private key
    string keyFile;
    # Password of the private key if it is encrypted
    string keyPassword?;
|}; 
```
* `mqtt:SecureSocket` configuration is used to enable secure communication with the MQTT server.
```ballerina
public type SecureSocket record {|
    # Certificate file that the client trusts or a `crypto:TrustStore`
    crypto:TrustStore|string cert?;
    # Combination of certificate and private key of the client or a `crypto:KeyStore`
    crypto:KeyStore|CertKey key?;
    # Related protocol
    record {|
        Protocol name;
        string version;
    |} protocol?;
|};
```
* In order to authenticate the client with the MQTT broker, the `username` and `password` fields of 
`mqtt:ConnectionConfiguration` can be used.

### 2.1. ConnectionConfiguration
* This record represents the common connection configurations required to initialize both the client and the listener.
```ballerina
public type ConnectionConfiguration record {|
    # The username to use for the connection
    string username?;
    # The password to use for the connection
    string password?;
    # The configurations related to secure communication with the MQTT server
    mqtt:SecureSocket secureSocket?;
    # The maximum delay between reconnects in milliseconds
    int maxReconnectDelay?;
    # The maximum time interval between messages sent or received in seconds
    int keepAliveInterval?;
    # Maximum time interval in seconds the client will wait for the network connection to the MQTT server to be established
    int connectionTimeout?;
    # Whether the client and server should remember state for the client across reconnects
    boolean cleanStart?;
    # List of serverURIs the client may connect to
    string[] serverUris?;
    # Whether the client will automatically attempt to reconnect to the server if the connection is lost
    boolean automaticReconnect?;
|};
```
### 2.3. Message
* This represents the MQTT message that is received from the server.
```ballerina
public type Message record {|
    # The payload of the message as a byte array
    byte[] payload;
    # Quality of service. 0 - at most once, 1 - at least once, 2 - exactly once
    int qos = 1;
    # Indicates whether this message should/is retained by the server
    boolean retained = false;
    # Indicates whether or not this message might be a duplicate
    boolean duplicate = false;
    # The message ID of the message. This is only set on messages received from the server
    int messageId?;
    # The topic this message was received on. This is only set on messages received from the server
    string topic?;
    # The properties of the message
    mqtt:MessageProperties properties?;
|};
```
* `mqtt:MessageProperties` represents the additional properties of the message.
```ballerina
public type MessageProperties record {|
    # The topic to send the response to in reqeust response scenario
    string responseTopic?;
    # The correlation data to uniquely identify the message
    byte[] correlationData?;
|};
```
### 2.4. DeliveryToken
* This represents the token that is returned when a message is published to the MQTT broker.
```ballerina
public type DeliveryToken record {|
    # Message ID of the message that was delivered
    int messageId;
    # Topic for the message that was delivered
    string topic;
|};
```
### 2.5 Subscription
* This represents the subscription that is used to subscribe to a topic.
```ballerina
public type Subscription record {|
    # The topic to subscribe to
    string topic;
    # The QoS level to subscribe at
    int qos = 1;
|};
```
## 3. Client
The `mqtt:Client` allows applications to publish messages to a MQTT broker. A connection with the MQTT broker can be 
established insecurely or securely.
### 3.1. Configurations
* When initializing the client, following configurations can be provided.
```ballerina
public type ClientConfiguration record {|
    # The related connection configuration
    mqtt:ConnectionConfiguration connectionConfig?;
    # The configurations related to the last will message of the client
    mqtt:WillDetails willDetails?; 
|};
```
* `mqtt:WillDetails` represents the last will message of the client that is sent to the broker at the connection initialization.
```ballerina
public type WillDetails record {|
    # The last will message to be sent to the subscribers
   mqtt:Message willMessage;
   # The topic to publish the last will message
   string destinationTopic;
|};
```
### 3.2. Initialization
#### 3.2.1. Insecure Client
A simple insecure client can be initialized by providing the MQTT broker url and a unique id to identify the client.
```ballerina
# Creates a new `mqtt:Client`.
#
# + serverUri - URI of the server to connect to
# + clientId - Unique ID of the client
# + config - Optional configuration values to use for the client
# + return - `mqtt:Error` if an error occurs while creating the client or else `()`
public isolated function init(string serverUri, string clientId, *ClientConfiguration config) returns Error? {
```
#### 3.2.2. Secure Client
A secure client can be initialized by providing either a `crypto:Truststore` or a certificate file to the
`mqtt:SecureSocket` and providing it as the `mqtt:ConnectionConfiguration` to client. Additionally, a `crypto:Keystore` 
or a `mqtt:CertKey` can also be provided in order to ensure two-way secure communication.

Above only provides the configurations related to secure communication. In order to authenticate the client with the broker, 
the `username` and `password` needs to provided in the `mqtt:ConnectionConfiguration`.
```ballerina
mqtt:ConnectionConfiguration connConfig = {
    username: "username",
    password: "password",
    secureSocket: {
        cert: "path/to/crt",
        key: {
            certFile: "path/to/client/crt",
            keyFile: "path/to/client/key",
            keyPassword: "password"
        }
    }
};

mqtt:ClientConfiguration clientConfig = {
    connectionConfig: connConfig
};
```

### 3.3. Functions
* MQTT client API can be used to publish messages to the MQTT broker. For this, the `publish()` method can be used.
```ballerina
# Publishes a message to a topic.
#
# + topic - Topic to publish the message to
# + message - `mqtt:Message` to publish
# + return - `mqtt:DeliveryToken` or else `mqtt:Error` if an error occurs while publishing
isolated remote function publish(string topic, mqtt:Message message) returns mqtt:DeliveryToken|mqtt:Error;
```
* In order to disconnect the client's connection with the broker, the `disconnect()` method can be used.
```ballerina
# Disconnects the client from the server.
#
# + return - `mqtt:Error` if an error occurs while disconnecting or else `()`
isolated remote function disconnect() returns mqtt:Error?;
```
* To check if the client is connected with the broker, the `isConnected()` method can be used.
```ballerina
# Checks if the client is connected to the server.
#
# + return - `true` if the client is connected, `mqtt:Error` if an error occurs in the process
isolated remote function isConnected() returns boolean|mqtt:Error;
```
* To reconnect the client with the broker, the `reconnect()` method can be used.
```ballerina
# Reconnects the client to the server.
#
# + return - `mqtt:Error` if an error occurs while reconnecting or else `()`
isolated remote function reconnect() returns mqtt:Error?;
```
* After disconnecting the client, to close the connection with the broker, the `close()` method can be used.
```ballerina
# Closes the connection to the server.
#
# + return - `mqtt:Error` if an error occurs while closing or else `()`
isolated remote function close() returns mqtt:Error?;
```
* In the request/response scenario, the client can publish a message to a topic and wait for a response from a subscriber 
by subscribing to a response topic. To subscribe to a response topic, the `subscribe()` method can be used.
```ballerina
# Subscribes to a given topic in the request response scenario.
#
# + subscriptions - The topics to be subscribed to
# + return - `mqtt:Error` if an error occurs while subscribing or else `()`
isolated remote function subscribe(string|string[]|mqtt:Subscription|mqtt:Subscription[] subscriptions) returns mqtt:Error?;
```
* To receive the responses sent from a subscriber, the `receiveResponse` method can be used. This method returns a `stream` 
of `mqtt:Message`s and the publisher can asynchronously iterate through the stream to receive the responses.
```ballerina
# Receives messages from the server.
#
# + T - Type of the stream to return
# + return - `stream<Message, error?>` or else`mqtt:Error` if an error occurs while receiving the response
isolated remote function receiveResponse(typedesc<stream<Message, error?>> T = <>) returns T|Error;
```
## 4. Subscriber
The subscriber allows applications to read messages from different topics in the MQTT broker. `mqtt:Listener` is used as 
a subscriber which requires a `mqtt:Service` in order to handle the incoming messages.
### 4.1. Configurations
* When initializing the `mqtt:Listener`, following configurations can be provided.
```ballerina
public type ListenerConfiguration record {|
    # The related connection configuration
    mqtt:ConnectionConfiguration connectionConfig?;
    # Indicates whether or not the client should automatically ack messages
    boolean manualAcks = false;
|};
```
#### 4.2. Initialization
A `mqtt:Listener` can be established insecurely or securely as same as the `mqtt:Client`.
##### 4.2.1. Insecure Listener
A simple insecure connection with the MQTT broker can be easily established by providing the MQTT broker URL, a unique 
id and the subscriptions as the input parameters.
```ballerina
# Creates a new `mqtt:Listener`.
#
# + serverUri - The URI of the remote MQTT server
# + clientId - The unique client ID to identify the listener
# + subscriptions - The topics to be subscribed to
# + return - `mqtt:Error` if an error occurs while creating the listener or else `()`
public isolated function init(string serverUri, string clientId, string|string[]|mqtt:Subscription|mqtt:Subscription[] subscriptions, *mqtt:ListenerConfiguration config) returns mqtt:Error?;
```
##### 4.3.1.2. Secure Listener
A secure client can be established via SSL as same as the `mqtt:Client` using either a `crypto:Truststore` or a
certificate file. Additionally, a `crypto:Keystore` or a key file can also be provided.
```ballerina
mqtt:ConnectionConfiguration connConfig = {
    username: "username",
    password: "password",
    secureSocket: {
        cert: "path/to/crt",
        key: {
            certFile: "path/to/client/crt",
            keyFile: "path/to/client/key",
            keyPassword: "password"
        }
    }
};

mqtt:ListenerConfiguration clientConfig = {
    connectionConfig: connConfig
};
```
#### 4.3.2. Usage
After initializing the listener, a service must be attached to the listener. There are two ways for this.
1. Attach the service to the listener directly.
```ballerina
service on new mqtt:Listener(mqtt:DEFAULT_URL, uuid:createType1AsString(), "mqtt/topic/temperature") {
    remote function onMessage(mqtt:Message message) returns error? {
        // process results
    }
}
```
2. Attach the service dynamically.
```ballerina
// Create a service object
mqtt:Service subscriber =
service object {
    remote function onMessage(mqtt:Message message) returns error? {
        // process results
    }
};
```
The remote function `onMessage()` is called when the listener receives messages from the MQTT broker.

The `mqtt:Service` has the following remote functions to manage the subscription.
* `onMessage`
```ballerina
remote function onMessage(mqtt:Message message) returns error? {
    // process results
}
or
remote function onMessage(mqtt:Message message, mqtt:Caller caller) returns error? {
    // process results
}
```
This is a mandatory remote function which is invoked when the listener receives messages from the MQTT broker. 
Any errors returning from this function will be logged to the console.

* `onError`
```ballerina
remote function onError(mqtt:Error err) returns error? {
    // process error
} 
```
This is an optional remote function which is invoked when an error occurs when invoking the `onMessage` method. If the 
method is not implemented, the error will be logged to the console. Any errors returning from this function will be 
logged to the console.

* `onComplete`
```ballerina
remote function onComplete(mqtt:DeliveryToken token) returns error? {
    // handle the delivery token
}
```
This is an optional remote function which is invoked when the message is successfully delivered to the MQTT broker in 
the request response scenario.

The Listener has the following functions to manage a service.
* `attach()` - can be used to attach a service to the listener dynamically.
```ballerina
# Attaches a service to the listener.
# ```ballerina
# error? result = listener.attach(mqttService);
# ```
#
# + 'service - The service to be attached
# + name - Name of the service
# + return - An `error` if an error is encountered while attaching the service or else `()`
public isolated function attach(Service 'service, string[]|string? name = ()) returns error?;
```
* `detach()` - can be used to detach a service from the listener.
```ballerina
# Detaches a consumer service from the listener.
# ```ballerina
# error? result = listener.detach(mqttService);
# ```
#
# + 'service - The service to be detached
# + return - An `error` if an error is encountered while detaching a service or else `()`
public isolated function detach(Service 'service) returns error?;
```
* `start()` - needs to be called to start the listener.
```ballerina
# Starts the registered services.
# ```ballerina
# error? result = listener.'start();
# ```
#
# + return - An `error` if an error is encountered while starting the server or else `()`
public isolated function 'start() returns error?;
```
* `gracefulStop()` - can be used to gracefully stop the listener from consuming messages.
```ballerina
# Stops the MQTT listener gracefully.
# ```ballerina
# error? result = listener.gracefulStop();
# ```
#
# + return - An `error` if an error is encountered during the listener-stopping process or else `()`
public isolated function gracefulStop() returns error?;
```
* `immediateStop()` - can be used to immediately stop the listener from consuming messages.
```ballerina
# Stops the mqtt listener immediately.
# ```ballerina
# error? result = listener.immediateStop();
# ```
#
# + return - An `error` if an error is encountered during the listener-stopping process or else `()`
public isolated function immediateStop() returns error?;
```

#### 4.3.3. Caller
`mqtt:Caller` is provided as a parameter to the `onMessage` remote function. It can be used to send a response back to 
the publisher in request/response scenario or acknowledge the message when in `manualAcks` mode.
* `complete()` - can be used to acknowledge the message in `manualAcks` mode.
```ballerina
# Completes the received message.
# 
# + return - `mqtt:Error` if the message cannot be completed or else `()`
isolated remote function complete() returns Error?;
```
This will internally use the message id of the message to acknowledge the message.
* `respond()` - can be used to send a response back to the publisher in request/response scenario.
```ballerina
# Send the response for the request message.
#
# + response - The response message to be sent
# + return - `mqtt:Error` if the message cannot be sent or `()`
isolated remote function respond(mqtt:Message response) returns mqtt:Error?;
```
This will internally read the response topic sent by the publisher and send the response to that topic.

## 5. Samples
### 5.1. Publish Messages
```ballerina

```
### 5.3. Request/Response
* Publish

* Subscribe