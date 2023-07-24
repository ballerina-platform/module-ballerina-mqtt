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

package io.ballerina.stdlib.mqtt.client;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mqtt.utils.MqttConstants;
import io.ballerina.stdlib.mqtt.utils.MqttUtils;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.client.MqttConnectionOptions;
import org.eclipse.paho.mqttv5.client.persist.MemoryPersistence;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;

/**
 * Class containing the external methods of the publisher.
 */
public class ClientActions {

    public static Object externInit(BObject clientObject, BString serverUri, BString clientId,
                                    BMap<BString, Object> clientConfiguration) {
        try {
            MqttClient publisher = new MqttClient(serverUri.getValue(), clientId.getValue(), new MemoryPersistence());
            MqttConnectionOptions options = MqttUtils.getMqttConnectOptions(clientConfiguration);
            publisher.connect(options);
            clientObject.addNativeData(MqttConstants.CLIENT_OBJECT, publisher);
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externPublish(BObject clientObject, BString topic, BMap message) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.CLIENT_OBJECT);
        MqttMessage mqttMessage = generateMqttMessage(message);
        try {
            publisher.publish(topic.getValue(), mqttMessage);
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externClose(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.CLIENT_OBJECT);
        try {
            publisher.close();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externIsConnected(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.CLIENT_OBJECT);
        return publisher.isConnected();
    }

    public static Object externDisconnect(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.CLIENT_OBJECT);
        try {
            publisher.disconnect();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externReconnect(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.CLIENT_OBJECT);
        try {
            publisher.reconnect();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    private static MqttMessage generateMqttMessage(BMap message) {
        MqttMessage mqttMessage = new MqttMessage();
        mqttMessage.setPayload(((BArray) message.get(StringUtils.fromString(MqttConstants.PAYLOAD))).getByteArray());
        mqttMessage.setQos(((Long) message.get(StringUtils.fromString(MqttConstants.QOS))).intValue());
        mqttMessage.setRetained(((boolean) message.get(StringUtils.fromString(MqttConstants.RETAINED))));
        return mqttMessage;
    }
}
