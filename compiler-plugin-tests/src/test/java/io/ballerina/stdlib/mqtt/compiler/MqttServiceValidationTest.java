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

import io.ballerina.projects.DiagnosticResult;
import io.ballerina.projects.Package;
import io.ballerina.projects.PackageCompilation;
import io.ballerina.projects.directory.BuildProject;
import io.ballerina.tools.diagnostics.Diagnostic;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.nio.file.Path;

import static io.ballerina.stdlib.mqtt.compiler.CompilerPluginTestUtils.BALLERINA_SOURCES;
import static io.ballerina.stdlib.mqtt.compiler.CompilerPluginTestUtils.RESOURCE_DIRECTORY;
import static io.ballerina.stdlib.mqtt.compiler.CompilerPluginTestUtils.getEnvironmentBuilder;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.FUNCTION_SHOULD_BE_REMOTE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_CALLER_PARAMETER;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_DELIVERY_TOKEN_PARAM_COUNT;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_MESSAGE_PARAMETER;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_MULTIPLE_LISTENERS;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_REMOTE_FUNCTION;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_RESOURCE_FUNCTION;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.INVALID_RETURN_TYPE_ERROR_OR_NIL;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.MUST_HAVE_CALLER_AND_MESSAGE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.MUST_HAVE_DELIVERY_TOKEN;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.MUST_HAVE_ERROR;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.NO_ON_MESSAGE;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.ONLY_DELIVERY_TOKEN_ALLOWED;
import static io.ballerina.stdlib.mqtt.compiler.PluginConstants.CompilationErrors.ONLY_ERROR_ALLOWED;

/**
 * Tests for Kafka package compiler plugin.
 */
public class MqttServiceValidationTest {

    private Package loadPackage(String path) {
        Path projectDirPath = RESOURCE_DIRECTORY.resolve(BALLERINA_SOURCES).resolve(path);
        BuildProject project = BuildProject.load(getEnvironmentBuilder(), projectDirPath);
        return project.currentPackage();
    }

    private void assertDiagnostic(Diagnostic diagnostic, PluginConstants.CompilationErrors error) {
        Assert.assertEquals(diagnostic.diagnosticInfo().code(), error.getErrorCode());
        Assert.assertEquals(diagnostic.diagnosticInfo().messageFormat(),
                error.getError());
    }

    @Test(enabled = true, description = "Service validating return types")
    public void testValidService1() {
        Package currentPackage = loadPackage("valid_service_1");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Validating import as")
    public void testValidService2() {
        Package currentPackage = loadPackage("valid_service_2");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Validate basic service")
    public void testValidService3() {
        Package currentPackage = loadPackage("valid_service_3");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Validating using only mqtt:Message")
    public void testValidService4() {
        Package currentPackage = loadPackage("valid_service_4");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Validate onError function")
    public void testValidService5() {
        Package currentPackage = loadPackage("valid_service_5");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Validate onError function return types")
    public void testValidService6() {
        Package currentPackage = loadPackage("valid_service_6");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Validate service with annotation")
    public void testValidService7() {
        Package currentPackage = loadPackage("valid_service_7");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate service with onMessage remote function")
    public void testValidService8() {
        Package currentPackage = loadPackage("valid_service_8");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(enabled = true, description = "Service validating return types")
    public void testInvalidService1() {
        Package currentPackage = loadPackage("invalid_service_1");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, NO_ON_MESSAGE);
    }

    @Test(enabled = true, description = "Validate invalid remote method")
    public void testInvalidService2() {
        Package currentPackage = loadPackage("invalid_service_2");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, INVALID_REMOTE_FUNCTION);
    }

    @Test(enabled = true, description = "Validate onMessage without remote keyword")
    public void testInvalidService3() {
        Package currentPackage = loadPackage("invalid_service_3");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, FUNCTION_SHOULD_BE_REMOTE);
    }

    @Test(enabled = true, description = "Validate invalid 1st parameter in 2 parameter scenario")
    public void testInvalidService4() {
        Package currentPackage = loadPackage("invalid_service_4");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 3);
        Object[] diagnostics = diagnosticResult.errors().toArray();
        for (Object obj : diagnostics) {
            Diagnostic diagnostic = (Diagnostic) obj;
            assertDiagnostic(diagnostic, INVALID_CALLER_PARAMETER);
        }
    }

    @Test(enabled = true, description = "Validate invalid 2nd parameter in 2 parameter scenario")
    public void testInvalidService5() {
        Package currentPackage = loadPackage("invalid_service_5");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 3);
        Object[] diagnostics = diagnosticResult.errors().toArray();
        for (Object obj : diagnostics) {
            Diagnostic diagnostic = (Diagnostic) obj;
            assertDiagnostic(diagnostic, INVALID_MESSAGE_PARAMETER);
        }
    }

    @Test(enabled = true, description = "Validate invalid return type")
    public void testInvalidService6() {
        Package currentPackage = loadPackage("invalid_service_6");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 5);
        Object[] diagnostics = diagnosticResult.errors().toArray();
        for (Object obj : diagnostics) {
            Diagnostic diagnostic = (Diagnostic) obj;
            assertDiagnostic(diagnostic, INVALID_RETURN_TYPE_ERROR_OR_NIL);
        }
    }

    @Test(enabled = true, description = "Validate multiple listeners")
    public void testInvalidService7() {
        Package currentPackage = loadPackage("invalid_service_7");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, INVALID_MULTIPLE_LISTENERS);
    }

    @Test(enabled = true, description = "Validate resource function")
    public void testInvalidService8() {
        Package currentPackage = loadPackage("invalid_service_8");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, INVALID_RESOURCE_FUNCTION);
    }

    @Test(enabled = true, description = "Validate 0 parameter scenario")
    public void testInvalidService9() {
        Package currentPackage = loadPackage("invalid_service_9");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, MUST_HAVE_CALLER_AND_MESSAGE);
    }

    @Test(enabled = true, description = "Validate invalid parameter for onError")
    public void testInvalidService10() {
        Package currentPackage = loadPackage("invalid_service_10");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 4);
        Object[] diagnostics = diagnosticResult.errors().toArray();
        for (Object obj : diagnostics) {
            Diagnostic diagnostic = (Diagnostic) obj;
            assertDiagnostic(diagnostic, ONLY_ERROR_ALLOWED);
        }
    }

    @Test(enabled = true, description = "Validate 0 parameter for onError")
    public void testInvalidService11() {
        Package currentPackage = loadPackage("invalid_service_11");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, MUST_HAVE_ERROR);
    }

    @Test(enabled = true, description = "Validate invalid remote function with onError")
    public void testInvalidService12() {
        Package currentPackage = loadPackage("invalid_service_12");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 2);
        Object[] diagnostics = diagnosticResult.errors().toArray();
        for (Object obj : diagnostics) {
            Diagnostic diagnostic = (Diagnostic) obj;
            assertDiagnostic(diagnostic, INVALID_REMOTE_FUNCTION);
        }
    }

    @Test(enabled = true, description = "Validate no remote keyword for onError")
    public void testInvalidService13() {
        Package currentPackage = loadPackage("invalid_service_13");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, FUNCTION_SHOULD_BE_REMOTE);
    }

    @Test(enabled = true, description = "Validate resource functions with onError")
    public void testInvalidService14() {
        Package currentPackage = loadPackage("invalid_service_14");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 2);
        Object[] diagnostics = diagnosticResult.errors().toArray();
        for (Object obj : diagnostics) {
            Diagnostic diagnostic = (Diagnostic) obj;
            assertDiagnostic(diagnostic, INVALID_RESOURCE_FUNCTION);
        }
    }

    @Test(description = "Validate parameter in onComplete")
    public void testInvalidService15() {
        Package currentPackage = loadPackage("invalid_service_15");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, ONLY_DELIVERY_TOKEN_ALLOWED);
    }

    @Test(description = "Validate parameter count in onComplete")
    public void testInvalidService16() {
        Package currentPackage = loadPackage("invalid_service_16");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, INVALID_DELIVERY_TOKEN_PARAM_COUNT);
    }

    @Test(description = "Validate no delivery token parameter in onComplete")
    public void testInvalidService17() {
        Package currentPackage = loadPackage("invalid_service_17");
        PackageCompilation compilation = currentPackage.getCompilation();
        DiagnosticResult diagnosticResult = compilation.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 1);
        Diagnostic diagnostic = (Diagnostic) diagnosticResult.errors().toArray()[0];
        assertDiagnostic(diagnostic, MUST_HAVE_DELIVERY_TOKEN);
    }
}
