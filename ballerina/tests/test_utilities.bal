// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

const NO_AUTH_ENDPOINT = "tcp://localhost:1883";
const AUTH_ONLY_ENDPOINT = "tcp://localhost:1884";
const NO_AUTH_ENCRYPTED_ENDPOINT = "ssl://localhost:8883";
const NO_AUTH_MTLS_ENDPOINT = "ssl://localhost:8884";
const NO_AUTH_EXPIRED_ENDPOINT = "ssl://localhost:8887";
const AUTH_MTLS_ENDPOINT = "ssl://localhost:8888";
const INVALID_ENDPOINT = "http://localhost:8888";

const AUTH_USERNAME = "ballerina";
const AUTH_PASSWORD = "ballerinamqtt";

const INVALID_USERNAME = "mqttuser";
const INVALID_PASSWORD = "password";

const SERVER_CERT_PATH = "tests/resources/certsandkeys/server.crt";
const CLIENT_CERT_PATH = "tests/resources/certsandkeys/client.crt";
const CLIENT_KEY_PATH = "tests/resources/certsandkeys/client.key";
const KEY_PASSWORD = "ballerina";

const TRUSTSTORE_PATH = "tests/resources/certsandkeys/client-trustore.jks";
const TRUSTSTORE_PASSWORD = "ballerina";

const KEYSTORE_PATH = "tests/resources/certsandkeys/client-keystore.p12";
const KEYSTORE_PASSWORD = "ballerina";

const INCORRECT_KEYSTORE_PATH = "tests/resources/certsandkeys/invalid-keystore.p12";
const INCORRECT_KEYSTORE_PASSWORD = "password";

final ConnectionConfiguration authConnConfig = {
    username: AUTH_USERNAME,
    password: AUTH_PASSWORD
};

final ConnectionConfiguration tlsConnConfig = {
    secureSocket: {
        cert: SERVER_CERT_PATH
    }
};

final ConnectionConfiguration mtlsConnConfig = {
    secureSocket: {
        cert: SERVER_CERT_PATH,
        key: {
            certFile: CLIENT_CERT_PATH,
            keyFile: CLIENT_KEY_PATH,
            keyPassword: KEY_PASSWORD
        }
    }
};

final ConnectionConfiguration mtlsWithTrustKeyStoreConnConfig = {
    secureSocket: {
        cert: {path: TRUSTSTORE_PATH, password: TRUSTSTORE_PASSWORD},
        key: {
            path: KEYSTORE_PATH,
            password: KEYSTORE_PASSWORD
        },
        protocol: {name: TLS, version: "1.2"}
    }
};

final ConnectionConfiguration authMtlsConnConfig = {
    username: AUTH_USERNAME,
    password: AUTH_PASSWORD,
    secureSocket: {
        cert: SERVER_CERT_PATH,
        key: {
            certFile: CLIENT_CERT_PATH,
            keyFile: CLIENT_KEY_PATH,
            keyPassword: KEY_PASSWORD
        }
    }
};

function stopListenerAndClient(Listener? 'listener = (), Client? 'client = ()) returns error? {
    if 'client != () {
        check 'client->disconnect();
        check 'client->close();
    }
    if 'listener != () {
        check 'listener.gracefulStop();
    }
}
