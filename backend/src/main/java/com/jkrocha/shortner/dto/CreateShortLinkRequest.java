package com.jkrocha.shortner.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record CreateShortLinkRequest(
        @NotBlank(message = "originalLink is mandatory")
        @Pattern(
                regexp = "^(https?)://.+$",
                message = "originalLink must start with http:// or https://"
        )
        String originalLink
) {
}
