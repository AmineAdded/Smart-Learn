package com.example.controller;

import com.example.dto.ErrorResponse;
import com.example.dto.MessageResponse;
import com.example.dto.Settings.UserSettingsResponse;
import com.example.service.SettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*", maxAge = 3600)
public class SettingsController {

    @Autowired
    private SettingsService settingsService;

    /**
     * GET /api/settings
     * Récupérer les paramètres de l'utilisateur
     */
    @GetMapping
    public ResponseEntity<?> getSettings() {
        try {
            UserSettingsResponse settings = settingsService.getUserSettings();
            return ResponseEntity.ok(settings);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de récupérer les paramètres")
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }

    /**
     * PUT /api/settings
     * Mettre à jour les paramètres
     */
    @PutMapping
    public ResponseEntity<?> updateSettings(@RequestBody Map<String, Object> updates) {
        try {
            UserSettingsResponse settings = settingsService.updateSettings(updates);
            return ResponseEntity.ok(settings);
        } catch (RuntimeException e) {
            return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorResponse.builder()
                    .error("Erreur de mise à jour")
                    .message(e.getMessage())
                    .status(HttpStatus.BAD_REQUEST.value())
                    .build());
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de mettre à jour les paramètres")
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }

    /**
     * POST /api/settings/reset
     * Réinitialiser les paramètres par défaut
     */
    @PostMapping("/reset")
    public ResponseEntity<?> resetSettings() {
        try {
            UserSettingsResponse settings = settingsService.resetToDefault();
            return ResponseEntity.ok(settings);
        } catch (Exception e) {
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.builder()
                    .error("Erreur serveur")
                    .message("Impossible de réinitialiser les paramètres")
                    .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                    .build());
        }
    }
}