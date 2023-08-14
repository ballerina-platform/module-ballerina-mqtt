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

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Future;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.StreamType;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.mqtt.utils.MqttConstants;
import io.ballerina.stdlib.mqtt.utils.MqttUtils;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.client.MqttConnectionOptions;
import org.eclipse.paho.mqttv5.client.persist.MemoryPersistence;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.eclipse.paho.mqttv5.common.MqttSubscription;

import java.util.ArrayList;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;

import static io.ballerina.stdlib.mqtt.utils.ModuleUtils.getModule;
import static io.ballerina.stdlib.mqtt.utils.MqttConstants.CLIENT_EXECUTOR_SERVICES;
import static io.ballerina.stdlib.mqtt.utils.MqttConstants.DELIVERY_TOKEN_QUEUE;
import static io.ballerina.stdlib.mqtt.utils.MqttConstants.RESPONSE_EXECUTOR_SERVICE;
import static io.ballerina.stdlib.mqtt.utils.MqttConstants.RESPONSE_QUEUE;
import static io.ballerina.stdlib.mqtt.utils.MqttConstants.STREAM_ITERATOR;
import static io.ballerina.stdlib.mqtt.utils.MqttUtils.generateMqttMessage;

/**
 * Class containing the external methods of the publisher.
 */
public class ClientActions {

    private static final ExecutorService publishExecutorService =
            Executors.newCachedThreadPool(new ClientThreadFactory());

    public static Object externInit(BObject clientObject, BString serverUri, BString clientId,
                                    BMap<BString, Object> clientConfiguration) {
        try {
            MqttClient publisher = new MqttClient(serverUri.getValue(), clientId.getValue(), new MemoryPersistence());
            MqttConnectionOptions options = MqttUtils.getMqttConnectOptions(clientConfiguration);
            publisher.connect(options);
            LinkedBlockingQueue blockingQueue = new LinkedBlockingQueue<>();
            LinkedBlockingQueue deliveryTokenQueue = new LinkedBlockingQueue<>();
            clientObject.addNativeData(RESPONSE_QUEUE, blockingQueue);
            clientObject.addNativeData(DELIVERY_TOKEN_QUEUE, deliveryTokenQueue);
            clientObject.addNativeData(MqttConstants.MQTT_CLIENT, publisher);
            clientObject.addNativeData(CLIENT_EXECUTOR_SERVICES, new ArrayList<ExecutorService>());
            publisher.setCallback(new MqttClientCallbackImpl(blockingQueue, deliveryTokenQueue));
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externSubscribe(BObject clientObject, BArray subscriptions) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        MqttSubscription[] mqttSubscriptions = new MqttSubscription[subscriptions.size()];
        for (int i = 0; i < subscriptions.size(); i++) {
            BMap topicSubscription = (BMap) subscriptions.getValues()[i];
            mqttSubscriptions[i] = new MqttSubscription(topicSubscription.getStringValue(MqttConstants.TOPIC)
                    .getValue(), topicSubscription.getIntValue(MqttConstants.BQOS).intValue());
        }
        try {
            publisher.subscribe(mqttSubscriptions);
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externPublish(Environment env, BObject clientObject, BString topic, BMap message) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        MqttMessage mqttMessage = generateMqttMessage(message);
        try {
            Future future = env.markAsync();
            publisher.publish(topic.getValue(), mqttMessage);
            LinkedBlockingQueue deliveryTokenQueue = (LinkedBlockingQueue) clientObject
                    .getNativeData(DELIVERY_TOKEN_QUEUE);
            publishExecutorService.execute(() -> {
                try {
                    future.complete(deliveryTokenQueue.take());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    future.complete(MqttUtils.createMqttError(e));
                }
            });
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externReceive(BObject clientObject, BTypedesc bTypedesc) {
        LinkedBlockingQueue blockingQueue = (LinkedBlockingQueue) clientObject.getNativeData(RESPONSE_QUEUE);
        ExecutorService responseExecutorService = Executors.newCachedThreadPool(new ClientThreadFactory());
        BObject streamIterator = ValueCreator.createObjectValue(getModule(), STREAM_ITERATOR);
        streamIterator.addNativeData(RESPONSE_QUEUE, blockingQueue);
        streamIterator.addNativeData(RESPONSE_EXECUTOR_SERVICE, responseExecutorService);
        ((ArrayList<ExecutorService>) clientObject.getNativeData(CLIENT_EXECUTOR_SERVICES))
                .add(responseExecutorService);
        StreamType streamType = (StreamType) bTypedesc.getDescribingType();
        BStream bStream = ValueCreator.createStreamValue(TypeCreator.createStreamType(
                streamType.getConstrainedType(), streamType.getCompletionType()), streamIterator);
        return bStream;
    }

    public static Object externClose(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        ((ArrayList<ExecutorService>) clientObject.getNativeData(CLIENT_EXECUTOR_SERVICES))
                .forEach(ExecutorService::shutdown);
        try {
            publisher.close();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externIsConnected(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        return publisher.isConnected();
    }

    public static Object externDisconnect(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        try {
            publisher.disconnect();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object externReconnect(BObject clientObject) {
        MqttClient publisher = (MqttClient) clientObject.getNativeData(MqttConstants.MQTT_CLIENT);
        try {
            publisher.reconnect();
        } catch (MqttException e) {
            return MqttUtils.createMqttError(e);
        }
        return null;
    }

    public static Object nextResult(Environment env, BObject streamIterator) {
        BlockingQueue<?> messageQueue = (BlockingQueue<?>) streamIterator.getNativeData(RESPONSE_QUEUE);
        ExecutorService executor = (ExecutorService) streamIterator.getNativeData(RESPONSE_EXECUTOR_SERVICE);
        Future future = env.markAsync();
        executor.execute(() -> {
            try {
                BMap message = (BMap) messageQueue.take();
                future.complete(message);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                future.complete(MqttUtils.createMqttError(e));
            }
        });
        return null;
    }

    public static void closeStream(BObject streamIterator) {
        BlockingQueue<?> messageQueue = (BlockingQueue<?>) streamIterator.getNativeData(RESPONSE_QUEUE);
        ExecutorService executor = (ExecutorService) streamIterator.getNativeData(RESPONSE_EXECUTOR_SERVICE);
        messageQueue.clear();
        executor.shutdown();
        streamIterator.addNativeData(RESPONSE_QUEUE, null);
    }
}
