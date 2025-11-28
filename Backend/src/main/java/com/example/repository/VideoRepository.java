package com.example.repository;

import com.example.model.Video;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VideoRepository extends JpaRepository<Video, Long> {

    Optional<Video> findByYoutubeId(String youtubeId);

    Page<Video> findByIsActiveTrue(Pageable pageable);

    Page<Video> findByCategory(String category, Pageable pageable);

    Page<Video> findByCategoryAndDifficulty(String category, String difficulty, Pageable pageable);

    @Query("""
        SELECT v FROM Video v
        WHERE v.isActive = true AND (
              LOWER(v.title) LIKE LOWER(CONCAT('%', :query, '%')) OR
              LOWER(v.description) LIKE LOWER(CONCAT('%', :query, '%')) OR
              LOWER(v.tags) LIKE LOWER(CONCAT('%', :query, '%'))
        )
    """)
    Page<Video> searchVideos(@Param("query") String query, Pageable pageable);

    @Query("SELECT DISTINCT v.category FROM Video v WHERE v.isActive = true")
    List<String> findAllCategories();

    List<Video> findByIsFeaturedTrue();

    boolean existsByYoutubeId(String youtubeId);

    // 🔥 Méthode TOP 20 : version recommandée, avec Pageable
    @Query("""
        SELECT v FROM Video v
        WHERE v.category = :category
        ORDER BY COALESCE(v.viewCount, 0) DESC, v.createdAt DESC
    """)
    List<Video> findTopByCategoryOrderByViewCountDesc(
            @Param("category") String category,
            Pageable pageable
    );
}
