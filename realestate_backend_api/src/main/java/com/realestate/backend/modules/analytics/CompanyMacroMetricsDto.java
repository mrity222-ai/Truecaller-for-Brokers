package com.realestate.backend.modules.analytics;

import lombok.*;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CompanyMacroMetricsDto {
    private String companyName;
    private int totalLeads;
    private double totalPipelineValueInr;
    private double averageSalesCycleDays;
    private int activeBrokersCount;
    private int closedWonDeals;
    private double conversionRatePct;
    private Map<String, Integer> stageDistribution;
    private List<StageVelocitySummary> stageVelocities;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StageVelocitySummary {
        private String stageId;
        private String stageName;
        private double averageDays;
        private int count;
    }
}
