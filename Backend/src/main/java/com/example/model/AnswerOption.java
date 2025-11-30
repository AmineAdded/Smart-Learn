package com.example.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "answer_options")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AnswerOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String optionText;

    @Column(name = "option_letter")
    private String optionLetter; // A, B, C, D

    @Column(name = "is_correct", nullable = false)
    private Boolean isCorrect = false;

    @Column(name = "order_number")
    private Integer orderNumber;
}