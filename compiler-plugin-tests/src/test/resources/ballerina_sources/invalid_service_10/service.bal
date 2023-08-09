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

service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) returns mqtt:Error? {
    }

    remote function onError(mqtt:Message message) returns mqtt:Error? {
    }
}

service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) returns mqtt:Error? {
    }

    remote function onError(mqtt:Message[] message) returns mqtt:Error? {
    }
}

service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) returns mqtt:Error? {
    }

    remote function onError(mqtt:Caller caller) returns mqtt:Error? {
    }
}

service on mqttSubscriber {
    remote function onMessage(mqtt:Message message) returns mqtt:Error? {
    }

    remote function onError(int val) returns mqtt:Error? {
    }
}
