// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
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
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/mqtt;
import ballerina/uuid;

mqtt:ListenerConfiguration listenerConfiguration = {
    connectionConfig: {
        username: "ballerina",
        password: "ballerinamqtt"
    },
    manualAcks: false
};

listener mqtt:Listener mqttSubscriber = check new (mqtt:DEFAULT_URL, uuid:createType1AsString(), "mqtt/test", listenerConfiguration);

@display {
    label: "mqttService1"
}
service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) returns mqtt:Error? {
    }

    remote function onComplete(mqtt:DeliveryToken token) returns mqtt:Error? {
    }
}

@display {
    label: "mqttService2"
}
service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) returns error? {
    }

    remote function onComplete(mqtt:DeliveryToken token) returns error? {
    }
}

@display {
    label: "mqttService3"
}
service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) {
    }

    remote function onComplete(mqtt:DeliveryToken token) {
    }
}
