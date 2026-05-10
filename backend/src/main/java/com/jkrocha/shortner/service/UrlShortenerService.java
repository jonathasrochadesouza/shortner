package com.jkrocha.shortner.service;

import com.jkrocha.shortner.config.ShortenerProperties;
import com.jkrocha.shortner.dto.CreateShortLinkResponse;
import com.jkrocha.shortner.model.UrlMapping;
import com.jkrocha.shortner.repository.UrlMappingRepository;
import java.security.SecureRandom;
import java.util.List;
import java.util.NoSuchElementException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UrlShortenerService {

    private static final String ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

    private final UrlMappingRepository repository;
    private final ShortenerProperties properties;
    private final SecureRandom random;

    @Autowired
    public UrlShortenerService(UrlMappingRepository repository, ShortenerProperties properties) {
        this(repository, properties, new SecureRandom());
    }

    UrlShortenerService(UrlMappingRepository repository, ShortenerProperties properties, SecureRandom random) {
        this.repository = repository;
        this.properties = properties;
        this.random = random;
    }

    public CreateShortLinkResponse createShortLink(String originalLink) {
        var shortCode = generateUniqueShortCode();
        var mapping = new UrlMapping();
        mapping.setShortLink(shortCode);
        mapping.setOriginalLink(originalLink);

        repository.save(mapping);

        return new CreateShortLinkResponse(originalLink, properties.domainBaseUrl() + "/" + shortCode);
    }

    public String resolveOriginalLink(String shortCode) {
        return repository.findByShortLink(shortCode)
                .map(UrlMapping::getOriginalLink)
                .orElseThrow(() -> new NoSuchElementException("Short link not found"));
    }

    public List<CreateShortLinkResponse> listLinks() {
        return repository.findAll().stream()
                .map(m -> new CreateShortLinkResponse(
                        m.getOriginalLink(),
                        properties.domainBaseUrl() + "/" + m.getShortLink()))
                .toList();
    }

    private String generateUniqueShortCode() {
        String candidate;
        do {
            candidate = randomCode(8);
        } while (repository.findByShortLink(candidate).isPresent());

        return candidate;
    }

    private String randomCode(int size) {
        var builder = new StringBuilder(size);
        for (int i = 0; i < size; i++) {
            builder.append(ALPHABET.charAt(random.nextInt(ALPHABET.length())));
        }
        return builder.toString();
    }
}
