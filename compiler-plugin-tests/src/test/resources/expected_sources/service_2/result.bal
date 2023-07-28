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
    int x = 5;
    string y = "xx";
	remote function onMessage(mqtt:Message message, mqtt:Caller caller) returns mqtt:Error? {

	}
}
