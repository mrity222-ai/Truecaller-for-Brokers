package com.realestate.backend.modules.analytics;

import com.realestate.backend.modules.auth_tenant.BrokerUser;
import com.realestate.backend.modules.auth_tenant.BrokerUserRepository;
import com.realestate.backend.modules.auth_tenant.Company;
import com.realestate.backend.modules.auth_tenant.CompanyRepository;
import com.realestate.backend.modules.client_leads.LeadEntity;
import com.realestate.backend.modules.client_leads.LeadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final LeadRepository leadRepository;
    private final BrokerUserRepository brokerRepository;
    private final CompanyRepository companyRepository;

    @Transactional(readOnly = true)
    public CompanyMacroMetricsDto getCompanyMacroMetrics(UUID companyId) {
        Company company = companyRepository.findById(companyId).orElse(null);
        String compName = company != null ? company.getCompanyName() : "RealEstate Agency";

        List<LeadEntity> leads = leadRepository.findByCompanyId(companyId);
        List<BrokerUser> brokers = brokerRepository.findByCompanyId(companyId);

        if (leads.isEmpty()) {
            return CompanyMacroMetricsDto.builder()
                    .companyName(compName)
                    .totalLeads(0)
                    .totalPipelineValueInr(0)
                    .averageSalesCycleDays(0)
                    .activeBrokersCount(brokers.size())
                    .closedWonDeals(0)
                    .conversionRatePct(0)
                    .stageDistribution(Map.of())
                    .stageVelocities(List.of())
                    .build();
        }

        double totalValue = leads.stream().mapToDouble(LeadEntity::getBudgetInr).sum();
        int closedWon = (int) leads.stream().filter(l -> "deal_closed".equalsIgnoreCase(l.getCurrentStageId())).count();
        double convRate = ((double) closedWon / leads.size()) * 100.0;

        // Stage distribution
        Map<String, Integer> stageDist = leads.stream()
                .collect(Collectors.groupingBy(LeadEntity::getCurrentStageId, Collectors.collectingAndThen(Collectors.counting(), Long::intValue)));

        // Stage velocities
        LocalDateTime now = LocalDateTime.now();
        Map<String, List<LeadEntity>> byStage = leads.stream().collect(Collectors.groupingBy(LeadEntity::getCurrentStageId));
        List<CompanyMacroMetricsDto.StageVelocitySummary> stageVelocities = new ArrayList<>();

        double totalCycleDays = 0;
        for (LeadEntity lead : leads) {
            long days = Duration.between(lead.getCreatedAt(), now).toDays();
            totalCycleDays += days > 0 ? days : 1;
        }

        byStage.forEach((stageId, stageLeads) -> {
            double avgDays = stageLeads.stream()
                    .mapToDouble(l -> {
                        long d = Duration.between(l.getUpdatedAt(), now).toDays();
                        return d > 0 ? d : 1.0;
                    })
                    .average()
                    .orElse(0.0);

            stageVelocities.add(CompanyMacroMetricsDto.StageVelocitySummary.builder()
                    .stageId(stageId)
                    .stageName(formatStageName(stageId))
                    .averageDays(avgDays)
                    .count(stageLeads.size())
                    .build());
        });

        return CompanyMacroMetricsDto.builder()
                .companyName(compName)
                .totalLeads(leads.size())
                .totalPipelineValueInr(totalValue)
                .averageSalesCycleDays(totalCycleDays / leads.size())
                .activeBrokersCount(brokers.size())
                .closedWonDeals(closedWon)
                .conversionRatePct(convRate)
                .stageDistribution(stageDist)
                .stageVelocities(stageVelocities)
                .build();
    }

    @Transactional(readOnly = true)
    public List<SpatialLocalityDto> getSpatialLocalityHeatmap(UUID companyId) {
        List<LeadEntity> leads = leadRepository.findByCompanyId(companyId);
        if (leads.isEmpty()) return List.of();

        long totalCount = leads.size();
        Map<String, List<LeadEntity>> byLocality = leads.stream()
                .collect(Collectors.groupingBy(l -> l.getPreferredLocation() != null && !l.getPreferredLocation().isBlank()
                        ? l.getPreferredLocation() : "General Region"));

        List<SpatialLocalityDto> list = new ArrayList<>();
        byLocality.forEach((loc, locLeads) -> {
            double avgBudget = locLeads.stream().mapToDouble(LeadEntity::getBudgetInr).average().orElse(0.0);
            double pct = ((double) locLeads.size() / totalCount) * 100.0;
            list.add(SpatialLocalityDto.builder()
                    .locality(loc)
                    .leadCount(locLeads.size())
                    .averageBudgetInr(avgBudget)
                    .demandPercentage(pct)
                    .build());
        });

        list.sort((a, b) -> Long.compare(b.getLeadCount(), a.getLeadCount()));
        return list;
    }

    @Transactional(readOnly = true)
    public List<BrokerPerformanceDto> getBrokersPerformance(UUID companyId) {
        List<BrokerUser> brokers = brokerRepository.findByCompanyId(companyId);
        List<LeadEntity> allLeads = leadRepository.findByCompanyId(companyId);
        LocalDateTime now = LocalDateTime.now();

        return brokers.stream().map(b -> {
            List<LeadEntity> brokerLeads = allLeads.stream()
                    .filter(l -> b.getId().equals(l.getBrokerId()))
                    .toList();

            int total = brokerLeads.size();
            int won = (int) brokerLeads.stream().filter(l -> "deal_closed".equalsIgnoreCase(l.getCurrentStageId())).count();
            int active = total - won;
            double rate = total > 0 ? ((double) won / total) * 100.0 : 0.0;
            double value = brokerLeads.stream().mapToDouble(LeadEntity::getBudgetInr).sum();

            double avgCloseDays = brokerLeads.stream()
                    .filter(l -> "deal_closed".equalsIgnoreCase(l.getCurrentStageId()))
                    .mapToDouble(l -> Duration.between(l.getCreatedAt(), l.getUpdatedAt()).toDays())
                    .average()
                    .orElse(0.0);

            return BrokerPerformanceDto.builder()
                    .brokerId(b.getId())
                    .brokerName(b.getFullName())
                    .role(b.getRole())
                    .localOnlyMode(b.isLocalOnlyMode())
                    .totalLeads(total)
                    .activeDeals(active)
                    .wonDeals(won)
                    .conversionRate(rate)
                    .avgDaysToClose(avgCloseDays)
                    .totalPipelineValue(value)
                    .build();
        }).collect(Collectors.toList());
    }

    private String formatStageName(String stageId) {
        if ("new_lead".equalsIgnoreCase(stageId)) return "New Lead";
        if ("site_visit_scheduled".equalsIgnoreCase(stageId)) return "Site Visit";
        if ("token_biana_pending".equalsIgnoreCase(stageId)) return "Token / Biana";
        if ("deal_closed".equalsIgnoreCase(stageId)) return "Closed Deal";
        return stageId;
    }
}
