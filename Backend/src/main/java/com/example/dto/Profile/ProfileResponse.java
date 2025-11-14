package com.example.dto.Profile;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfileResponse {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String niveau;
    private String role;
    private String createdAt;
}
