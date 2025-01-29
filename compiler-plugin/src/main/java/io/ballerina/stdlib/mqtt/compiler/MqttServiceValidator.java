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

import io.ballerina.compiler.api.symbols.MethodSymbol;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.util.Optional;

import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.ON_MESSAGE_FUNC;

/**
 * Validates a Ballerina Mqtt Service.
 */
public class MqttServiceValidator {

    public void validate(SyntaxNodeAnalysisContext context) {
        ServiceDeclarationNode serviceDeclarationNode = (ServiceDeclarationNode) context.node();
        NodeList<Node> memberNodes = serviceDeclarationNode.members();

        boolean hasOnMessageRemoteFunction = serviceDeclarationNode.members().stream().anyMatch(child ->
                child.kind() == SyntaxKind.OBJECT_METHOD_DEFINITION &&
                        PluginUtils.isRemoteFunction(context, (FunctionDefinitionNode) child) &&
                        ((FunctionDefinitionNode) child).functionName().toString().equals(ON_MESSAGE_FUNC));
        if (serviceDeclarationNode.members().isEmpty() || !hasOnMessageRemoteFunction) {
            DiagnosticInfo diagnosticInfo = new DiagnosticInfo(
                    PluginConstants.CompilationErrors.TEMPLATE_CODE_GENERATION_HINT.getErrorCode(),
                    PluginConstants.CompilationErrors.TEMPLATE_CODE_GENERATION_HINT.getError(),
                    DiagnosticSeverity.INTERNAL);
            context.reportDiagnostic(DiagnosticFactory.createDiagnostic(diagnosticInfo,
                    serviceDeclarationNode.location()));
        }

        FunctionDefinitionNode onMessage = null;
        FunctionDefinitionNode onError = null;
        FunctionDefinitionNode onComplete = null;

        for (Node node : memberNodes) {
            if (node.kind() == SyntaxKind.OBJECT_METHOD_DEFINITION) {
                FunctionDefinitionNode functionDefinitionNode = (FunctionDefinitionNode) node;
                MethodSymbol methodSymbol = PluginUtils.getMethodSymbol(context, functionDefinitionNode);
                Optional<String> functionName = methodSymbol.getName();
                if (functionName.isPresent()) {
                    if (functionName.get().equals(ON_MESSAGE_FUNC)) {
                        onMessage = functionDefinitionNode;
                    } else if (functionName.get().equals(PluginConstants.ON_ERROR_FUNC)) {
                        onError = functionDefinitionNode;
                    } else if (functionName.get().equals(PluginConstants.ON_COMPLETE_FUNC)) {
                        onComplete = functionDefinitionNode;
                    } else if (PluginUtils.isRemoteFunction(context, functionDefinitionNode)) {
                        context.reportDiagnostic(PluginUtils.getDiagnostic(
                                PluginConstants.CompilationErrors.INVALID_REMOTE_FUNCTION,
                                DiagnosticSeverity.ERROR, functionDefinitionNode.location()));
                    }
                }
            } else if (node.kind() == SyntaxKind.RESOURCE_ACCESSOR_DEFINITION) {
                context.reportDiagnostic(PluginUtils.getDiagnostic(
                        PluginConstants.CompilationErrors.INVALID_RESOURCE_FUNCTION,
                        DiagnosticSeverity.ERROR, node.location()));
            }
        }
        new MqttFunctionValidator(context, onMessage, onError, onComplete).validate();
    }
}
