package com.jkrocha.shortner.controller;

import com.jkrocha.shortner.dto.CreateShortLinkRequest;
import com.jkrocha.shortner.dto.CreateShortLinkResponse;
import com.jkrocha.shortner.service.UrlShortenerService;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping
public class UrlShortenerController {

    private final UrlShortenerService service;

    public UrlShortenerController(UrlShortenerService service) {
        this.service = service;
    }

    @PostMapping("/api/v1/links")
    public ResponseEntity<CreateShortLinkResponse> createShortLink(@Valid @RequestBody CreateShortLinkRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createShortLink(request.originalLink()));
    }

    @GetMapping("/api/v1/links")
    public ResponseEntity<List<CreateShortLinkResponse>> listLinks() {
        return ResponseEntity.ok(service.listLinks());
    }

    @GetMapping("/{shortCode}")
    public ResponseEntity<Void> redirect(@PathVariable String shortCode) {
        var originalLink = service.resolveOriginalLink(shortCode);
        return ResponseEntity.status(HttpStatus.FOUND)
                .location(URI.create(originalLink))
                .build();
    }

    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<Map<String, String>> handleNoSuchElementException(NoSuchElementException exception) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("message", exception.getMessage()));
    }
}
