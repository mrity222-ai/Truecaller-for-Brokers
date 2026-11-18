package com.realestate.backend.modules.analytics;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SpatialLocalityDto {
    private String locality;
    private long leadCount;
    private double averageBudgetInr;
    private double demandPercentage;
}
