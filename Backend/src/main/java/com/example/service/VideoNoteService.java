package com.example.service;

import com.example.dto.video.VideoNoteDTO;
import com.example.dto.video.VideoNoteRequest;
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

import java.util.List;
import java.util.stream.Collectors;

@Service
public class VideoNoteService {

    @Autowired
    private VideoNoteRepository noteRepository;

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Récupérer l'utilisateur connecté
     */
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Ajouter une note sur une vidéo
     */
    @Transactional
    public VideoNoteDTO addNote(Long videoId, VideoNoteRequest request) {
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
        return convertToDTO(note);
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
     * Modifier une note
     */
    @Transactional
    public VideoNoteDTO updateNote(Long noteId, VideoNoteRequest request) {
        User user = getCurrentUser();
        VideoNote note = noteRepository.findByIdAndUser(noteId, user)
                .orElseThrow(() -> new RuntimeException("Note non trouvée"));

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
        VideoNote note = noteRepository.findByIdAndUser(noteId, user)
                .orElseThrow(() -> new RuntimeException("Note non trouvée"));

        noteRepository.delete(note);
    }

    /**
     * Convertir VideoNote en VideoNoteDTO
     */
    private VideoNoteDTO convertToDTO(VideoNote note) {
        return VideoNoteDTO.builder()
                .id(note.getId())
                .content(note.getContent())
                .timestamp(note.getTimestamp())
                .formattedTimestamp(note.getFormattedTimestamp())
                .createdAt(note.getCreatedAt())
                .updatedAt(note.getUpdatedAt())
                .build();
    }
}