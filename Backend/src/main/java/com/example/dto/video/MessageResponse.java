package com.example.dto.video;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@lombok.Data
@lombok.Builder
@lombok.NoArgsConstructor
class MessageResponse {
    private String message;
    
    public MessageResponse(String message) {
        this.message = message;
    }
}
