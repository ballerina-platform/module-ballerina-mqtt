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

package io.ballerina.stdlib.mqtt.caller;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.mqtt.utils.MqttConstants;
import io.ballerina.stdlib.mqtt.utils.MqttUtils;
import io.ballerina.stdlib.mqtt.utils.Util;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;

import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static io.ballerina.stdlib.mqtt.utils.MqttUtils.generateMqttMessage;

/**
 * Class containing the external methods of the caller.
 */
public final class CallerActions {

    private CallerActions() {}

    private static final ExecutorService executorService = Executors.newCachedThreadPool(new CallerThreadFactory());

    public static Object complete(Environment env, BObject callerObject) {
        MqttClient subscriber = (MqttClient) callerObject.getNativeData(MqttConstants.SUBSCRIBER);
        int messageId = (int) callerObject.getNativeData(MqttConstants.MESSAGE_ID);
        int qos = (int) callerObject.getNativeData(MqttConstants.QOS);
        return env.yieldAndRun(() -> {
            CompletableFuture<Object> future = new CompletableFuture<>();
            executorService.execute(() -> {
                try {
                    subscriber.messageArrivedComplete(messageId, qos);
                    future.complete(null);
                } catch (MqttException e) {
                    future.complete(MqttUtils.createMqttError(e));
                }
            });
            return Util.getResult(future);
        });
    }

    public static Object respond(Environment env, BObject callerObject, BMap message) {
        MqttClient subscriber = (MqttClient) callerObject.getNativeData(MqttConstants.SUBSCRIBER);
        byte[] correlationData = (byte[]) callerObject.getNativeData(MqttConstants.CORRELATION_DATA);
        String responseTopic = (String) callerObject.getNativeData(MqttConstants.RESPONSE_TOPIC.getValue());
        MqttMessage mqttMessage = generateMqttMessage(message);
        if (Objects.isNull(responseTopic)) {
            return MqttUtils.createMqttError(new Exception("Response topic is not set"));
        }
        if (Objects.nonNull(correlationData)) {
            mqttMessage.getProperties().setCorrelationData(correlationData);
        }
        return env.yieldAndRun(() -> {
            CompletableFuture<Object> future = new CompletableFuture<>();
            executorService.execute(() -> {
                try {
                    subscriber.publish(responseTopic, mqttMessage);
                    future.complete(null);
                } catch (MqttException e) {
                    future.complete(MqttUtils.createMqttError(e));
                }
            });
            return Util.getResult(future);
        });
    }
}
