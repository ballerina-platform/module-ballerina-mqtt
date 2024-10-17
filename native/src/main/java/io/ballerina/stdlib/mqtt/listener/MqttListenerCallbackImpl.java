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
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.RemoteMethodType;
import io.ballerina.runtime.api.types.ServiceType;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mqtt.utils.MqttConstants;
import io.ballerina.stdlib.mqtt.utils.MqttUtils;
import io.ballerina.stdlib.mqtt.utils.Util;
import org.eclipse.paho.mqttv5.client.IMqttToken;
import org.eclipse.paho.mqttv5.client.MqttCallback;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.client.MqttDisconnectResponse;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.eclipse.paho.mqttv5.common.packet.MqttProperties;

import java.util.Objects;
import java.util.Optional;

import static io.ballerina.stdlib.mqtt.utils.ModuleUtils.getModule;
import static io.ballerina.stdlib.mqtt.utils.MqttConstants.MESSAGE_ID;
import static io.ballerina.stdlib.mqtt.utils.MqttUtils.getBMqttMessage;
import static io.ballerina.stdlib.mqtt.utils.MqttUtils.getMqttDeliveryToken;

/**
 * Class containing the callback of Mqtt subscriber.
 */
public class MqttListenerCallbackImpl implements MqttCallback {

    private final Runtime runtime;
    private final BObject service;
    private final MqttClient subscriber;

    public MqttListenerCallbackImpl(Environment environment, BObject service, MqttClient subscriber) {
        this.runtime = environment.getRuntime();
        this.service = service;
        this.subscriber = subscriber;
    }

    @Override
    public void disconnected(MqttDisconnectResponse disconnectResponse) {
        BError mqttError = MqttUtils.createMqttError(disconnectResponse.getException());
        invokeOnError(mqttError);
    }

    @Override
    public void mqttErrorOccurred(MqttException exception) {
        BError mqttError = MqttUtils.createMqttError(exception);
        invokeOnError(mqttError);
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        invokeOnMessage(message, topic);
    }

    @Override
    public void connectComplete(boolean reconnect, String serverURI) {}

    @Override
    public void authPacketArrived(int reasonCode, MqttProperties properties) {}

    @Override
    public void deliveryComplete(IMqttToken token) {
        invokeOnComplete(token);
    }

    private void invokeOnMessage(MqttMessage message, String topic) {
        BMap<BString, Object> bMqttMessage = getBMqttMessage(message, topic);
        boolean callerExists = isCallerAvailable();
        if (!isMethodImplemented(MqttConstants.ONMESSAGE)) {
            invokeOnError(MqttUtils.createMqttError(new NoSuchMethodException("method onMessage not found")));
            return;
        }
        if (callerExists) {
            BObject callerObject = ValueCreator.createObjectValue(getModule(), MqttConstants.CALLER);
            callerObject.addNativeData(MqttConstants.SUBSCRIBER, subscriber);
            callerObject.addNativeData(MESSAGE_ID, message.getId());
            callerObject.addNativeData(MqttConstants.QOS, message.getQos());
            if (Objects.nonNull(message.getProperties().getResponseTopic())) {
                callerObject.addNativeData(MqttConstants.RESPONSE_TOPIC.getValue(),
                        message.getProperties().getResponseTopic());
            }
            if (Objects.nonNull(message.getProperties().getCorrelationData())) {
                callerObject.addNativeData(MqttConstants.CORRELATION_DATA,
                        message.getProperties().getCorrelationData());
            }
            try {
                Object result = runtime.call(service, MqttConstants.ONMESSAGE, bMqttMessage, callerObject);
                Util.notifySuccess(result);
            } catch (BError bError) {
                Util.notifyFailure(bError);
            }
        } else {
            try {
                Object result = runtime.call(service, MqttConstants.ONMESSAGE, bMqttMessage);
                Util.notifySuccess(result);
            } catch (BError bError) {
                Util.notifyFailure(bError);
            }
        }
    }

    private void invokeOnError(BError bError) {
        if (!isMethodImplemented(MqttConstants.ONERROR)) {
            bError.printStackTrace();
            return;
        }
        try {
            Object result = runtime.call(service, MqttConstants.ONERROR, bError);
            Util.notifySuccess(result);
        } catch (BError error) {
            Util.notifyFailure(error);
        }
    }

    private void invokeOnComplete(IMqttToken token) {
        if (!isMethodImplemented(MqttConstants.ONCOMPLETE)) {
            return;
        }
        BMap<BString, Object> bMqttToken;
        bMqttToken = getMqttDeliveryToken(token);
        try {
            Object result = runtime.call(service, MqttConstants.ONCOMPLETE, bMqttToken);
            Util.notifySuccess(result);
        } catch (BError bError) {
            Util.notifyFailure(bError);
        }
    }

    private boolean isMethodImplemented(String methodName) {
        Optional<RemoteMethodType> methodType = getRemoteMethodType(methodName);
        return methodType.isPresent();
    }

    private boolean isCallerAvailable() {
        Optional<RemoteMethodType> onMessageMethodType = getRemoteMethodType(MqttConstants.ONMESSAGE);
        return onMessageMethodType.isPresent() && onMessageMethodType.get().getType().getParameters().length == 2;
    }

    private Optional<RemoteMethodType> getRemoteMethodType(String methodName) {
        RemoteMethodType[] methodTypes = ((ServiceType) service.getOriginalType()).getRemoteMethods();
        for (RemoteMethodType methodType: methodTypes) {
            if (methodType.getName().equals(methodName)) {
                return Optional.of(methodType);
            }
        }
        return Optional.empty();
    }
}
