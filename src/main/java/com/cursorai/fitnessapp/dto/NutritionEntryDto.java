package com.cursorai.fitnessapp.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NutritionEntryDto {
    private Long id;
    private LocalDateTime timestamp;
    private String food;
    private Integer calories;
    private Double proteinG;
    private Double fatG;
    private Double carbsG;
}
