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

package io.ballerina.stdlib.mqtt.compiler;

/**
 * Mqtt compiler plugin constants.
 */
public class PluginConstants {
    // compiler plugin constants
    public static final String PACKAGE_PREFIX = "mqtt";
    public static final String ON_MESSAGE_FUNC = "onMessage";
    public static final String ON_ERROR_FUNC = "onError";
    public static final String ON_COMPLETE_FUNC = "onComplete";
    public static final String PACKAGE_ORG = "ballerina";

    // parameters
    public static final String CALLER = "Caller";
    public static final String MESSAGE = "Message";
    public static final String ERROR_PARAM = "Error";
    public static final String DELIVERY_TOKEN = "DeliveryToken";

    // return types error or nil
    public static final String BALLERINA_ERROR = "error";

    // Code template related constants
    public static final String NODE_LOCATION = "node.location";
    public static final String LS = System.lineSeparator();
    public static final String CODE_TEMPLATE_NAME_WITH_CALLER = "ADD_REMOTE_FUNCTION_CODE_SNIPPET_WITH_CALLER";
    public static final String CODE_TEMPLATE_NAME_WITHOUT_CALLER = "ADD_REMOTE_FUNCTION_CODE_SNIPPET_WITHOUT_CALLER";

    /**
     * Compilation errors.
     */
    public enum CompilationErrors {
        NO_ON_MESSAGE("Service must have remote method onMessage.", "MQTT_101"),
        INVALID_REMOTE_FUNCTION("Invalid remote method.", "MQTT_102"),
        INVALID_RESOURCE_FUNCTION("Resource functions not allowed.", "MQTT_103"),
        FUNCTION_SHOULD_BE_REMOTE("Method must have the remote qualifier.", "MQTT_104"),
        MUST_HAVE_CALLER_AND_MESSAGE("Must have the required parameter mqtt:Message" +
                " and optional parameter mqtt:Caller.", "MQTT_105"),
        INVALID_MESSAGE_PARAMETER("Invalid method parameter. Only mqtt:Message is allowed.", "MQTT_106"),
        INVALID_CALLER_PARAMETER("Invalid method parameter. Only mqtt:Caller is allowed", "MQTT_107"),
        INVALID_PARAM_COUNT("Invalid method parameter count. " +
                "Only mqtt:Caller and mqtt:Message are allowed.", "MQTT_108"),
        INVALID_RETURN_TYPE_ERROR_OR_NIL("Invalid return type. Only error? or mqtt:Error? is allowed.",
                "MQTT_109"),
        INVALID_MULTIPLE_LISTENERS("Multiple listener attachments. Only one mqtt:Listener is allowed.",
                "MQTT_110"),
        MUST_HAVE_ERROR("Must have the required parameter mqtt:Error", "MQTT_111"),
        INVALID_ERROR_PARAM_COUNT("Invalid method parameter count. Only mqtt:Error is allowed.", "MQTT_112"),
        ONLY_ERROR_ALLOWED("Invalid method parameter. Only mqtt:Error or error is allowed", "MQTT_113"),
        TEMPLATE_CODE_GENERATION_HINT("Template generation for empty service", "MQTT_114"),
        ONLY_DELIVERY_TOKEN_ALLOWED("Invalid method parameter. Only mqtt:DeliveryToken is allowed", "MQTT_115"),
        INVALID_DELIVERY_TOKEN_PARAM_COUNT("Invalid method parameter count. Only mqtt:DeliveryToken is allowed",
                "MQTT_116"),
        MUST_HAVE_DELIVERY_TOKEN("Must have the required parameter mqtt:DeliveryToken", "MQTT_117");

        private final String error;
        private final String errorCode;

        CompilationErrors(String error, String errorCode) {
            this.error = error;
            this.errorCode = errorCode;
        }

        String getError() {
            return error;
        }

        String getErrorCode() {
            return errorCode;
        }
    }

    private PluginConstants() {
    }
}
