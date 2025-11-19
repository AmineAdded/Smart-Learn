package com.example.repository;

import com.example.model.User;
import com.example.model.UserSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserSettingsRepository extends JpaRepository<UserSettings, Long> {
    
    Optional<UserSettings> findByUser(User user);
    
    Optional<UserSettings> findByUserId(Long userId);
    
    boolean existsByUserId(Long userId);
}