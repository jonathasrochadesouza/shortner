package com.jkrocha.shortner.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "shortener")
public record ShortenerProperties(String tableName, String domainBaseUrl, String dynamodbEndpoint) {
}
