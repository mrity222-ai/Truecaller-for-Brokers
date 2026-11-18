package com.realestate.backend.modules.analytics;

import lombok.*;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BrokerPerformanceDto {
    private UUID brokerId;
    private String brokerName;
    private String role;
    private boolean localOnlyMode;
    private int totalLeads;
    private int activeDeals;
    private int wonDeals;
    private double conversionRate;
    private double avgDaysToClose;
    private double totalPipelineValue;
}
