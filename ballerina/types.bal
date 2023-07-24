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

import ballerina/crypto;

# An MQTT message holds the application payload and other metadata.
#
# + payload - The payload of the message as a byte array
# + qos - Quality of service. 0 - at most once, 1 - at least once, 2 - exactly once
# + retained - Indicates whether this message should/is retained by the server
# + duplicate - Indicates whether or not this message might be a duplicate
# + messageId - The message ID of the message. This is only set on messages received from the server
public type Message record {|
    byte[] payload;
    int qos = 1;
    boolean retained = false;
    boolean duplicate = false;
    int messageId?;
|};

# The configurations related to the client initialization.
#
# + connectionConfig - The related connection configuration
public type ClientConfiguration record {|
    ConnectionConfiguration connectionConfig?;
|};

# The configurations related to the listener initialization.
#
# + connectionConfig - The related connection configuration
# + manualAcks - Indicates whether or not the client should automatically ack messages
public type ListenerConfiguration record {|
    ConnectionConfiguration connectionConfig?;
    boolean manualAcks = false;
|};

# An MQTTSubscription which contains the topic and the QoS level.
#
# + topic - The topic to subscribe to
# + qos - The QoS level to subscribe at
public type Subscription record {|
    string topic;
    int qos = 1;
|};

# The configurations related to the connection initialization of `mqtt:Client` and `mqtt:Listener`.
#
# + username - The username to use for the connection  
# + password - The password to use for the connection  
# + secureSocket - The configurations related to secure communication with the MQTT server
# + maxReconnectDelay - The maximum delay between reconnects in milliseconds  
# + keepAliveInterval - The maximum time interval between messages sent or received in seconds  
# + connectionTimeout - Maximum time interval in seconds the client will wait for the network connection to the MQTT server to be established
# + cleanStart - Whether the client and server should remember state for the client across reconnects
# + serverUris - List of serverURIs the client may connect to  
# + automaticReconnect - Whether the client will automatically attempt to reconnect to the server if the connection is lost
public type ConnectionConfiguration record {|
    string username?;
    string password?;
    SecureSocket secureSocket?;
    int maxReconnectDelay?;
    int keepAliveInterval?;
    int connectionTimeout?;
    boolean cleanStart?;
    string[] serverUris?;
    boolean automaticReconnect?;
|};

# The mechanism for tracking the delivery of a message
#
# + message - Message associated with this token
# + grantedQos - The granted QoS list from a suback
# + messageId - Message ID of the message that is associated with the token
# + topics - Topic string(s) for the subscribe being tracked by this token
public type DeliveryToken record {|
    Message message;
    int[] grantedQos;
    int messageId;
    string[] topics;
|};

# Configurations for secure communication with the MQTT server.
#
# + cert - Certificate file that the client trusts
# + key - Combination of certificate and private key of the client
# + protocol - Related protocol
public type SecureSocket record {|
    crypto:TrustStore|string cert?;
    crypto:KeyStore|CertKey key?;
    record {|
        Protocol name;
        string version;
    |} protocol?;
|};

# Represents a combination of certificate, private key, and private key password if encrypted.
#
# + certFile - A file containing the certificate
# + keyFile - A file containing the private key
# + keyPassword - Password of the private key if it is encrypted
public type CertKey record {|
    string certFile;
    string keyFile;
    string keyPassword?;
|};

# Represents protocol options.
public enum Protocol {
    SSL,
    TLS
}

# The MQTT service type.
public type Service distinct service object {};
