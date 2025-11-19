package com.example.repository;

import com.example.model.User;
import com.example.model.UserInterest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserInterestRepository extends JpaRepository<UserInterest, Long> {

    /**
     * Récupère tous les intérêts actifs d'un utilisateur
     */
    List<UserInterest> findByUserAndIsActiveTrue(User user);

    /**
     * Récupère tous les intérêts d'un utilisateur (actifs et inactifs)
     */
    List<UserInterest> findByUser(User user);

    /**
     * Vérifie si un utilisateur a déjà un intérêt pour une catégorie
     */
    Optional<UserInterest> findByUserAndCategory(User user, String category);

    /**
     * Compte le nombre d'intérêts actifs d'un utilisateur
     */
    @Query("SELECT COUNT(ui) FROM UserInterest ui WHERE ui.user = ?1 AND ui.isActive = true")
    long countActiveInterestsByUser(User user);

    /**
     * Supprime tous les intérêts d'un utilisateur
     */
    @Modifying
    @Query("DELETE FROM UserInterest ui WHERE ui.user = ?1")
    void deleteAllByUser(User user);

    /**
     * Désactive tous les intérêts d'un utilisateur
     */
    @Modifying
    @Query("UPDATE UserInterest ui SET ui.isActive = false WHERE ui.user = ?1")
    void deactivateAllByUser(User user);

    /**
     * Vérifie si un utilisateur a au moins un intérêt actif
     */
    boolean existsByUserAndIsActiveTrue(User user);
}