package com.jkrocha.shortner.repository;

import com.jkrocha.shortner.config.ShortenerProperties;
import com.jkrocha.shortner.model.UrlMapping;
import java.util.Optional;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;

@Repository
public class DynamoDbUrlMappingRepository implements UrlMappingRepository {

    private final DynamoDbTable<UrlMapping> table;

    public DynamoDbUrlMappingRepository(DynamoDbClient dynamoDbClient, ShortenerProperties properties) {
        var enhancedClient = DynamoDbEnhancedClient.builder().dynamoDbClient(dynamoDbClient).build();
        this.table = enhancedClient.table(properties.tableName(), TableSchema.fromBean(UrlMapping.class));
    }

    @Override
    public UrlMapping save(UrlMapping mapping) {
        table.putItem(mapping);
        return mapping;
    }

    @Override
    public Optional<UrlMapping> findByShortLink(String shortLink) {
        return Optional.ofNullable(table.getItem(Key.builder().partitionValue(shortLink).build()));
    }
}
