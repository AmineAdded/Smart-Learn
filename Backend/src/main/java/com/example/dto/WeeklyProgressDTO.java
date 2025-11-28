// package com.example.dto;


// import lombok.AllArgsConstructor;
// import lombok.Builder;
// import lombok.Data;
// import lombok.NoArgsConstructor;

// import java.util.List;

// @Data
// @NoArgsConstructor
// @AllArgsConstructor
// @Builder
// public class WeeklyProgressDTO {
//     private Integer currentWeekXp;
//     private Integer lastWeekXp;
//     private Double changePercentage;
//     private List<DailyProgress> dailyProgress;
    
//     @Data
//     @NoArgsConstructor
//     @AllArgsConstructor
//     @Builder
//     public static class DailyProgress {
//         private String day; // Lun, Mar, Mer...
//         private String fullDate; // 2024-01-15
//         private Integer xpEarned;
//         private Integer quizCompleted;
//         private Integer studyTimeMinutes;
//         private Boolean hasActivity;
//     }
// }


package com.example.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyProgressDTO {
    private int currentWeekXp;
    private int lastWeekXp;
    private double changePercentage;
    private List<DailyProgress> dailyProgress;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyProgress {
        private String day;
        private String fullDate;
        private int xpEarned;
        private int quizCompleted;
        private int studyTimeMinutes;
        private boolean hasActivity;
    }
}
