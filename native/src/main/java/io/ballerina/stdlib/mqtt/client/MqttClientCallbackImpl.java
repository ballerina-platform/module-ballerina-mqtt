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

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.eclipse.paho.mqttv5.client.IMqttToken;
import org.eclipse.paho.mqttv5.client.MqttCallback;
import org.eclipse.paho.mqttv5.client.MqttDisconnectResponse;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.eclipse.paho.mqttv5.common.packet.MqttProperties;

import java.util.concurrent.LinkedBlockingQueue;

import static io.ballerina.stdlib.mqtt.utils.MqttUtils.getBMqttMessage;
import static io.ballerina.stdlib.mqtt.utils.MqttUtils.getMqttDeliveryToken;

/**
 * Class containing the callback of Mqtt client.
 */
public class MqttClientCallbackImpl implements MqttCallback {

    private final LinkedBlockingQueue blockingQueue;
    private final LinkedBlockingQueue deliveryTokenQueue;

    public MqttClientCallbackImpl(LinkedBlockingQueue blockingQueue, LinkedBlockingQueue deliveryTokenQueue) {
        this.blockingQueue = blockingQueue;
        this.deliveryTokenQueue = deliveryTokenQueue;
    }

    public void disconnected(MqttDisconnectResponse disconnectResponse) {}

    @Override
    public void mqttErrorOccurred(MqttException exception) {}

    @Override
    public void messageArrived(String topic, MqttMessage message) throws Exception {
        BMap<BString, Object> bMqttMessage = getBMqttMessage(message, topic);
        blockingQueue.put(bMqttMessage);
    }

    @Override
    public void deliveryComplete(IMqttToken token) {
        BMap<BString, Object> bMqttToken = getMqttDeliveryToken(token);
        try {
            deliveryTokenQueue.put(bMqttToken);
        } catch (InterruptedException exception) {
            exception.printStackTrace();
        }
    }

    @Override
    public void connectComplete(boolean reconnect, String serverURI) {}

    @Override
    public void authPacketArrived(int reasonCode, MqttProperties properties) {}
}
