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

import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.MethodSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.ParameterNode;
import io.ballerina.compiler.syntax.tree.QualifiedNameReferenceNode;
import io.ballerina.compiler.syntax.tree.RequiredParameterNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Location;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static io.ballerina.compiler.syntax.tree.SyntaxKind.ERROR_TYPE_DESC;
import static io.ballerina.compiler.syntax.tree.SyntaxKind.QUALIFIED_NAME_REFERENCE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CALLER;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.FUNCTION_SHOULD_BE_REMOTE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_CALLER_PARAMETER;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_ERROR_PARAM_COUNT;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_MESSAGE_PARAMETER;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_PARAM_COUNT;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_RETURN_TYPE_ERROR_OR_NIL;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.MUST_HAVE_CALLER_AND_MESSAGE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.MUST_HAVE_ERROR;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.NO_ON_MESSAGE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.ONLY_ERROR_ALLOWED;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.ERROR_PARAM;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.MESSAGE;
import static io.ballerina.stdlib.mqtt.compiler.PluginUtils.getDiagnostic;
import static io.ballerina.stdlib.mqtt.compiler.PluginUtils.getMethodSymbol;
import static io.ballerina.stdlib.mqtt.compiler.PluginUtils.validateModuleId;
import static io.ballerina.tools.diagnostics.DiagnosticSeverity.ERROR;

/**
 * Kafka remote function validator.
 */
public class MqttFunctionValidator {

    private final SyntaxNodeAnalysisContext context;
    private final ServiceDeclarationNode serviceDeclarationNode;
    private final SemanticModel semanticModel;
    FunctionDefinitionNode onMessage;
    FunctionDefinitionNode onError;

    public MqttFunctionValidator(SyntaxNodeAnalysisContext context, FunctionDefinitionNode onMessage,
                                 FunctionDefinitionNode onError) {
        this.context = context;
        this.serviceDeclarationNode = (ServiceDeclarationNode) context.node();
        this.onMessage = onMessage;
        this.onError = onError;
        this.semanticModel = context.semanticModel();
    }

    public void validate() {
        validateMandatoryFunction();
        if (Objects.nonNull(onError)) {
            validateOnError();
        }
    }

    private void validateMandatoryFunction() {
        if (Objects.isNull(onMessage)) {
            reportErrorDiagnostic(NO_ON_MESSAGE, serviceDeclarationNode.location());
            return;
        }
        validateOnMessageFunction();
    }

    private void validateOnMessageFunction() {
        if (!PluginUtils.isRemoteFunction(context, onMessage)) {
            reportErrorDiagnostic(FUNCTION_SHOULD_BE_REMOTE, onMessage.location());
        }
        validateOnMessageParameters(onMessage);
        validateReturnTypeErrorOrNil(onMessage);
    }

    private void validateOnError() {
        if (!PluginUtils.isRemoteFunction(context, onError)) {
            reportErrorDiagnostic(FUNCTION_SHOULD_BE_REMOTE, onError.location());
        }
        validateOnErrorParameters(onError);
        validateReturnTypeErrorOrNil(onError);
    }

    private void validateOnErrorParameters(FunctionDefinitionNode functionDefinitionNode) {
        SeparatedNodeList<ParameterNode> parameters = functionDefinitionNode.functionSignature().parameters();
        if (parameters.size() == 1) {
            validateErrorParameter(parameters.get(0));
        } else if (parameters.size() > 1) {
            reportErrorDiagnostic(INVALID_ERROR_PARAM_COUNT, functionDefinitionNode.functionSignature().location());
        } else {
            reportErrorDiagnostic(MUST_HAVE_ERROR, functionDefinitionNode.functionSignature().location());
        }
    }

    private void validateErrorParameter(ParameterNode parameterNode) {
        SyntaxKind paramSyntaxKind = ((RequiredParameterNode) parameterNode).typeName().kind();
        if (paramSyntaxKind.equals(QUALIFIED_NAME_REFERENCE)) {
            Node parameterTypeNode = ((RequiredParameterNode) parameterNode).typeName();
            Optional<Symbol> paramSymbol = semanticModel.symbol(parameterTypeNode);
            if (!paramSymbol.get().getName().get().equals(ERROR_PARAM) ||
                    !validateModuleId(paramSymbol.get().getModule().get())) {
                reportErrorDiagnostic(ONLY_ERROR_ALLOWED, parameterNode.location());
            }
        } else if (!paramSyntaxKind.equals(ERROR_TYPE_DESC)) {
            reportErrorDiagnostic(ONLY_ERROR_ALLOWED, parameterNode.location());
        }
    }

    private void validateOnMessageParameters(FunctionDefinitionNode functionDefinitionNode) {
        SeparatedNodeList<ParameterNode> parameters = functionDefinitionNode.functionSignature().parameters();
        Location location = functionDefinitionNode.functionSignature().location();
        if (parameters.size() > 2) {
            reportErrorDiagnostic(INVALID_PARAM_COUNT, location);
            return;
        } else if (parameters.size() < 1) {
             reportErrorDiagnostic(MUST_HAVE_CALLER_AND_MESSAGE, location);
             return;
        } else if (parameters.size() == 2) {
            validateMessageParam((RequiredParameterNode) parameters.get(0));
            validateCallerParam((RequiredParameterNode) parameters.get(1));
        } else {
            validateMessageParam((RequiredParameterNode) parameters.get(0));
        }
    }

    private void validateCallerParam(RequiredParameterNode requiredParameterNode) {
        if (requiredParameterNode.typeName().kind() == QUALIFIED_NAME_REFERENCE) {
            QualifiedNameReferenceNode referenceNode = (QualifiedNameReferenceNode) requiredParameterNode.typeName();
            Optional<Symbol> symbol = semanticModel.symbol(referenceNode);
            if (symbol.isPresent() && symbol.get().getName().isPresent() &&
                    symbol.get().getName().get().equals(CALLER) && symbol.get().getModule().isPresent() &&
                    validateModuleId(symbol.get().getModule().get())) {
                return;
            }
        }
        reportErrorDiagnostic(INVALID_CALLER_PARAMETER, requiredParameterNode.location());
    }

    private void validateMessageParam(RequiredParameterNode requiredParameterNode) {
        if (requiredParameterNode.typeName().kind() == QUALIFIED_NAME_REFERENCE) {
            QualifiedNameReferenceNode referenceNode = (QualifiedNameReferenceNode) requiredParameterNode.typeName();
            Optional<Symbol> symbol = semanticModel.symbol(referenceNode);
            if (symbol.isPresent() && symbol.get().getName().isPresent() &&
                    symbol.get().getName().get().equals(MESSAGE) && symbol.get().getModule().isPresent() &&
                    validateModuleId(symbol.get().getModule().get())) {
                return;
            }
        }
        reportErrorDiagnostic(INVALID_MESSAGE_PARAMETER, requiredParameterNode.location());
    }

    private void validateReturnTypeErrorOrNil(FunctionDefinitionNode functionDefinitionNode) {
        MethodSymbol methodSymbol = getMethodSymbol(context, functionDefinitionNode);
        if (methodSymbol != null) {
            Optional<TypeSymbol> returnTypeDesc = methodSymbol.typeDescriptor().returnTypeDescriptor();
            if (returnTypeDesc.isPresent()) {
                if (returnTypeDesc.get().typeKind() == TypeDescKind.UNION) {
                    List<TypeSymbol> returnTypeMembers =
                            ((UnionTypeSymbol) returnTypeDesc.get()).memberTypeDescriptors();
                    for (TypeSymbol returnType : returnTypeMembers) {
                        if (returnType.typeKind() != TypeDescKind.NIL) {
                            if (returnType.typeKind() == TypeDescKind.TYPE_REFERENCE) {
                                TypeReferenceTypeSymbol returnTypeSymbol = (TypeReferenceTypeSymbol) returnType;
                                if (!returnType.signature().equals(PluginConstants.BALLERINA_ERROR) &&
                                        !(validateModuleId(returnType.getModule().get()) &&
                                                returnTypeSymbol.typeDescriptor().typeKind() == TypeDescKind.ERROR)) {
                                    reportErrorDiagnostic(INVALID_RETURN_TYPE_ERROR_OR_NIL,
                                            returnType.getLocation().get());
                                }
                            } else if (returnType.typeKind() != TypeDescKind.ERROR) {
                                reportErrorDiagnostic(INVALID_RETURN_TYPE_ERROR_OR_NIL,
                                        returnType.getLocation().get());
                            }
                        }
                    }
                } else if (returnTypeDesc.get().typeKind() != TypeDescKind.NIL) {
                    reportErrorDiagnostic(INVALID_RETURN_TYPE_ERROR_OR_NIL, functionDefinitionNode.location());
                }
            }
        }
    }

    public void reportErrorDiagnostic(PluginConstants.CompilationErrors error, Location location) {
        context.reportDiagnostic(getDiagnostic(error, ERROR, location));
    }
}
