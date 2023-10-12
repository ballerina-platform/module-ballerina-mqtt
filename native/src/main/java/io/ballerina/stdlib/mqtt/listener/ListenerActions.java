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

package io.ballerina.stdlib.mqtt.listener;

import io.ballerina.runtime.api.Environment;
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
import org.eclipse.paho.mqttv5.common.MqttSubscription;

/**
 * Class containing the external methods of the listener.
 */
public final class ListenerActions {

    private ListenerActions() {}

    public static Object externInit(BObject clientObject, BString serverUri, BString clientId,
                                    BMap<BString, Object> listenerConfiguration) {
        try {
            MqttClient subscriber = new MqttClient(serverUri.getValue(), clientId.getValue(), new MemoryPersistence());
            MqttConnectionOptions options = MqttUtils.getMqttConnectOptions(listenerConfiguration);
            boolean manualAcks = listenerConfiguration.getBooleanValue(StringUtils
                    .fromString(MqttConstants.MANUAL_ACKS));
            subscriber.setManualAcks(manualAcks);
            subscriber.connect(options);
            clientObject.addNativeData(MqttConstants.MQTT_CLIENT, subscriber);
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externAttach(Environment environment, BObject clientObject, BObject service, Object topics) {
        clientObject.addNativeData("service", service);
        MqttClient subscriber = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        subscriber.setCallback(new MqttListenerCallbackImpl(environment, service, subscriber));
        return null;
    }

    public static Object externDetach(BObject clientObject, BObject service) {
        MqttClient subscriber = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        try {
            subscriber.disconnect();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        clientObject.addNativeData(MqttConstants.SERVICE, null);
        return null;
    }

    public static Object externStart(BObject clientObject, BArray subscriptions) {
        MqttClient subscriber = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        MqttSubscription[] mqttSubscriptions = new MqttSubscription[subscriptions.size()];
        for (int i = 0; i < subscriptions.size(); i++) {
            BMap topicSubscription = (BMap) subscriptions.getValues()[i];
            mqttSubscriptions[i] = new MqttSubscription(topicSubscription.getStringValue(MqttConstants.TOPIC)
                    .getValue(), topicSubscription.getIntValue(MqttConstants.BQOS).intValue());
        }
        try {
            subscriber.subscribe(mqttSubscriptions);
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externGracefulStop(BObject clientObject) {
        MqttClient subscriber = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        try {
            subscriber.disconnect();
            subscriber.close();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        clientObject.addNativeData(MqttConstants.SERVICE, null);
        return null;
    }

    public static Object externImmediateStop(BObject clientObject) {
        MqttClient subscriber = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        try {
            subscriber.disconnectForcibly();
            subscriber.close();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        clientObject.addNativeData(MqttConstants.SERVICE, null);
        return null;
    }

}
