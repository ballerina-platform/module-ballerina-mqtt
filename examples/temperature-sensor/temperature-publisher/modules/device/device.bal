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

import ballerina/random;
import ballerina/time;

int temperatureReadCount = 0;

public function getTemperatureDetails() returns TemperatureDetails|random:Error {
    return {
        deviceId: "DEVICE-001",
        temperature: <float>(check random:createIntInRange(0, 100)) + random:createDecimal(),
        timestamp: time:utcNow()
    };
}

public function isCharging() returns boolean {
    temperatureReadCount = temperatureReadCount + 1;
    return temperatureReadCount != 15;
}

public type TemperatureDetails record {|
    string deviceId;
    float temperature;
    time:Utc timestamp;
|};
