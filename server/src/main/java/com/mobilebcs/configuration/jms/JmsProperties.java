package com.mobilebcs.configuration.jms;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "activemq")
public class JmsProperties {
    private Long receiveTimeout;
    private Long timeToLive;
    private String brokerUrl;
    private String password;
    private String username;

    public Long getReceiveTimeout() {
        return receiveTimeout;
    }

    public void setReceiveTimeout(Long receiveTimeout) {
        this.receiveTimeout = receiveTimeout;
    }

    public Long getTimeToLive() {
        return timeToLive;
    }

    public void setTimeToLive(Long timeToLive) {
        this.timeToLive = timeToLive;
    }

    public String getBrokerUrl() {
        return brokerUrl;
    }

    public void setBrokerUrl(String brokerUrl) {
        this.brokerUrl = brokerUrl;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public String toString() {
        return "JmsProperties{" +
                "receiveTimeout=" + receiveTimeout +
                ", timeToLive=" + timeToLive +
                ", brokerUrl='" + brokerUrl + '\'' +
                ", password='" + password + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
