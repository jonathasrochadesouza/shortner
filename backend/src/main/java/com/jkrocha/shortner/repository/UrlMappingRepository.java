package com.jkrocha.shortner.repository;

import com.jkrocha.shortner.model.UrlMapping;
import java.util.List;
import java.util.Optional;

public interface UrlMappingRepository {

    UrlMapping save(UrlMapping mapping);

    Optional<UrlMapping> findByShortLink(String shortLink);

    List<UrlMapping> findAll();
}
