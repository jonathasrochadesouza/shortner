package com.jkrocha.shortner.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;
import java.net.URI;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;

@Configuration
@EnableConfigurationProperties(ShortenerProperties.class)
public class ShortenerConfiguration {

    @Bean
    public DynamoDbClient dynamoDbClient(ShortenerProperties properties) {
        var builder = DynamoDbClient.builder()
                .region(Region.of(System.getenv().getOrDefault("AWS_REGION", "us-east-1")));

        if (StringUtils.hasText(properties.dynamodbEndpoint())) {
            builder.endpointOverride(URI.create(properties.dynamodbEndpoint()));
        }

        return builder.build();
    }
}
