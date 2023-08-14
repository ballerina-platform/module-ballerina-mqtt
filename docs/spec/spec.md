# Specification: Ballerina MQTT Library

_Owners_: @shafreenAnfar @dilanSachi    
_Reviewers_: @shafreenAnfar  
_Created_: 2023/08/14    
_Updated_: 2023/08/14   
_Edition_: Swan Lake

## Introduction
This is the specification for the MQTT standard library of [Ballerina language](https://ballerina.io/), which can send and receive messages by connecting to a MQTT broker.

The MQTT library specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in GitHub.

The conforming implementation of the specification is released to Ballerina central. Any deviation from the specification is considered a bug.

## Contents
1. [Overview](#1-overview)
2. [Configurations](#2-configurations)
    *  2.1. [Security Configurations](#21-security-configurations)
3. [Client](#3-producer)
    *  3.1. [Configurations](#31-configurations)
    *  3.2. [Initialization](#32-initialization)
        *    3.2.1. [Insecure Client](#321-insecure-client)
        *    3.2.2. [Secure Client](#322-secure-client)
    *  3.3. [Functions](#33-functions)
4. [Subscriber](#4-consumer)
    *  4.1. [Configurations](#41-configurations)
    *  4.3. [Listener](#43-listener)
        *  4.3.1. [Initialization](#431-initialization)
            *  4.3.1.1. [Insecure Listener](#4311-insecure-listener)
            *  4.3.1.2. [Secure Listener](#4312-secure-listener)
        *  4.3.2. [Usage](#432-usage)
        *  4.3.3. [Caller](#433-caller)
5. [Samples](#5-samples)
    *  5.1. [Publish Messages](#51-produce-messages)
    *  5.2. [Subscribe to Messages](#52-consume-messages)

## 1. Overview
