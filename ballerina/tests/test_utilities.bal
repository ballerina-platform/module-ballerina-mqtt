
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
