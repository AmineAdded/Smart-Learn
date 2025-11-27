package com.example.dto.video;

import com.example.dto.AddXpResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Réponse pour addNote avec informations XP
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VideoNoteResponse {
    private VideoNoteDTO note;
    private AddXpResponse xpResponse;
}