package com.jkrocha.shortner.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.jkrocha.shortner.config.ShortenerProperties;
import com.jkrocha.shortner.model.UrlMapping;
import com.jkrocha.shortner.repository.UrlMappingRepository;
import java.security.SecureRandom;
import java.util.NoSuchElementException;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class UrlShortenerServiceTest {

    @Mock
    private UrlMappingRepository repository;

    private UrlShortenerService service;

    @BeforeEach
    void setup() {
        var properties = new ShortenerProperties("url-shortner", "https://api.jkrocha.com.br", "");
        service = new UrlShortenerService(repository, properties, new SecureRandom());
    }

    @Test
    void shouldCreateShortLink() {
        when(repository.findByShortLink(any())).thenReturn(Optional.empty());
        when(repository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        var response = service.createShortLink("https://example.com/page");

        assertEquals("https://example.com/page", response.originalLink());
    }

    @Test
    void shouldResolveOriginalLinkWhenShortCodeExists() {
        var mapping = new UrlMapping();
        mapping.setShortLink("abc12345");
        mapping.setOriginalLink("https://example.com/ok");
        when(repository.findByShortLink("abc12345")).thenReturn(Optional.of(mapping));

        var result = service.resolveOriginalLink("abc12345");

        assertEquals("https://example.com/ok", result);
    }

    @Test
    void shouldThrowWhenShortCodeDoesNotExist() {
        when(repository.findByShortLink("missing")).thenReturn(Optional.empty());

        assertThrows(NoSuchElementException.class, () -> service.resolveOriginalLink("missing"));
    }
}
