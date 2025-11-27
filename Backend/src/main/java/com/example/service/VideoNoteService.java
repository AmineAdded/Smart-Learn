package com.example.service;

import com.example.dto.AddXpResponse;
import com.example.dto.video.VideoNoteDTO;
import com.example.dto.video.VideoNoteRequest;
import com.example.dto.video.VideoNoteResponse;
import com.example.model.User;
import com.example.model.Video;
import com.example.model.VideoNote;
import com.example.repository.UserRepository;
import com.example.repository.VideoNoteRepository;
import com.example.repository.VideoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class VideoNoteService {

    @Autowired
    private VideoNoteRepository noteRepository;

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ProgressService progressService;

    // 🎯 CONSTANTE XP
    private static final int XP_NOTE_ADDED = 10;

    /**
     * Récupérer l'utilisateur connecté
     */
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Récupérer toutes les notes d'une vidéo
     */
    public List<VideoNoteDTO> getNotesByVideo(Long videoId) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));

        List<VideoNote> notes = noteRepository.findByUserAndVideoOrderByTimestampAsc(user, video);

        return notes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 🆕 Ajouter une note + XP
     */
    @Transactional
    public VideoNoteResponse addNote(Long videoId, VideoNoteRequest request) {
        User user = getCurrentUser();
        Video video = videoRepository.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Vidéo non trouvée"));

        VideoNote note = VideoNote.builder()
                .user(user)
                .video(video)
                .content(request.getContent())
                .timestamp(request.getTimestamp())
                .build();

        note = noteRepository.save(note);

        // 🎯 AJOUTER XP
        log.info("📝 Note ajoutée - Attribution de {} XP", XP_NOTE_ADDED);
        AddXpResponse xpResponse = progressService.addXp(
            XP_NOTE_ADDED,
            "Note ajoutée sur vidéo: " + video.getTitle(),
            "NOTE_ADDED"
        );

        return VideoNoteResponse.builder()
                .note(convertToDTO(note))
                .xpResponse(xpResponse)
                .build();
    }

    /**
     * Modifier une note
     */
    @Transactional
    public VideoNoteDTO updateNote(Long noteId, VideoNoteRequest request) {
        User user = getCurrentUser();
        VideoNote note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note non trouvée"));

        if (!note.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Non autorisé à modifier cette note");
        }

        note.setContent(request.getContent());
        if (request.getTimestamp() != null) {
            note.setTimestamp(request.getTimestamp());
        }

        note = noteRepository.save(note);
        return convertToDTO(note);
    }

    /**
     * Supprimer une note
     */
    @Transactional
    public void deleteNote(Long noteId) {
        User user = getCurrentUser();
        VideoNote note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note non trouvée"));

        if (!note.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Non autorisé à supprimer cette note");
        }

        noteRepository.delete(note);
    }

    /**
     * Récupérer toutes les notes de l'utilisateur
     */
    public List<VideoNoteDTO> getAllUserNotes() {
        User user = getCurrentUser();
        List<VideoNote> notes = noteRepository.findByUserOrderByCreatedAtDesc(user);

        return notes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Convertir VideoNote en DTO
     */
    private VideoNoteDTO convertToDTO(VideoNote note) {
        String formattedTimestamp = null;
        if (note.getTimestamp() != null) {
            int minutes = note.getTimestamp() / 60;
            int seconds = note.getTimestamp() % 60;
            formattedTimestamp = String.format("%d:%02d", minutes, seconds);
        }

        return VideoNoteDTO.builder()
                .id(note.getId())
                .content(note.getContent())
                .timestamp(note.getTimestamp())
                .formattedTimestamp(formattedTimestamp)
                .createdAt(note.getCreatedAt())
                .updatedAt(note.getUpdatedAt())
                .build();
    }
}