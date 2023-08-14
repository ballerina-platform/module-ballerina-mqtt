/*
 * Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.mqtt.utils;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Contains the constant values related in the runtime.
 */
public class MqttConstants {

    public static final BString CONNECTION_CONFIGURATION = StringUtils.fromString("connectionConfig");
    public static final BString USERNAME = StringUtils.fromString("username");
    public static final BString PASSWORD = StringUtils.fromString("password");
    public static final BString MAX_RECONNECT_DELAY = StringUtils.fromString("maxReconnectDelay");
    public static final BString KEEP_ALIVE_INTERVAL = StringUtils.fromString("keepAliveInterval");
    public static final BString CONNECTION_TIMEOUT = StringUtils.fromString("connectionTimeout");
    public static final BString CLEAN_START = StringUtils.fromString("cleanStart");
    public static final BString SERVER_URIS = StringUtils.fromString("serverUris");
    public static final BString AUTOMATIC_RECONNECT = StringUtils.fromString("automaticReconnect");
    public static final BString SECURE_SOCKET = StringUtils.fromString("secureSocket");
    public static final BString CERT = StringUtils.fromString("cert");
    public static final BString KEY = StringUtils.fromString("key");
    public static final BString TOPIC = StringUtils.fromString("topic");
    public static final BString BQOS = StringUtils.fromString("qos");
    public static final BString CERT_FILE = StringUtils.fromString("certFile");
    public static final BString KEY_FILE = StringUtils.fromString("keyFile");
    public static final BString KEY_PASSWORD = StringUtils.fromString("keyPassword");
    public static final BString KEY_STORE_PASSWORD = StringUtils.fromString("password");
    public static final BString KEY_STORE_PATH = StringUtils.fromString("path");
    public static final BString PROTOCOL_NAME = StringUtils.fromString("name");
    public static final BString PROTOCOL_VERSION = StringUtils.fromString("version");

    public static final String ERROR_NAME = "Error";

    public static final String MQTT_CLIENT = "mqttClient";
    public static final String SUBSCRIBER = "subscriber";
    public static final String MESSAGE_ID = "messageId";
    public static final String QOS = "qos";
    public static final String PAYLOAD = "payload";
    public static final String RETAINED = "retained";
    public static final String DUPLICATE = "duplicate";
    public static final String MANUAL_ACKS = "manualAcks";
    public static final String SERVICE = "service";
    public static final String CALLER = "Caller";
    public static final String RECORD_MESSAGE = "Message";
    public static final String RECORD_MESSAGE_PROPERTIES = "MessageProperties";
    public static final String RECORD_DELIVERY_TOKEN = "DeliveryToken";
    public static final BString RESPONSE_TOPIC = StringUtils.fromString("responseTopic");
    public static final String CORRELATION_DATA = "correlationData";
    public static final BString MESSAGE_PROPERTIES = StringUtils.fromString("properties");
    public static final BString REASON_CODE = StringUtils.fromString("reasonCode");
    
    public static final String ONCOMPLETE = "onComplete";
    public static final String ONMESSAGE = "onMessage";
    public static final String ONERROR = "onError";

    public static final String RESPONSE_QUEUE = "responseQueue";
    public static final String DELIVERY_TOKEN_QUEUE = "deliveryTokenQueue";
    public static final String RESPONSE_EXECUTOR_SERVICE = "responseExecutorService";
    public static final String STREAM_ITERATOR = "StreamIterator";
    public static final String ERROR_DETAILS = "ErrorDetails";

    public static final BString CRYPTO_TRUSTSTORE_PATH = StringUtils.fromString("path");
    public static final BString CRYPTO_TRUSTSTORE_PASSWORD = StringUtils.fromString("password");

    public static final String NATIVE_DATA_PUBLIC_KEY_CERTIFICATE = "NATIVE_DATA_PUBLIC_KEY_CERTIFICATE";
    public static final String NATIVE_DATA_PRIVATE_KEY = "NATIVE_DATA_PRIVATE_KEY";
    public static final String DEFAULT_TLS_PROTOCOL = "TLSv1.2";

}
