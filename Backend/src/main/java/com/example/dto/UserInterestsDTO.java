package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List; /**
 * DTO pour récupérer les intérêts d'un utilisateur
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserInterestsDTO {

    private Long userId;
    private List<String> interests;
    private int totalInterests;
    private boolean hasInterests;
}
