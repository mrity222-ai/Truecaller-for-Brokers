package com.realestate.backend.modules.analytics;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/company/macro")
    public ResponseEntity<CompanyMacroMetricsDto> getCompanyMacroMetrics(@RequestParam UUID companyId) {
        return ResponseEntity.ok(analyticsService.getCompanyMacroMetrics(companyId));
    }

    @GetMapping("/company/spatial")
    public ResponseEntity<List<SpatialLocalityDto>> getSpatialLocalityHeatmap(@RequestParam UUID companyId) {
        return ResponseEntity.ok(analyticsService.getSpatialLocalityHeatmap(companyId));
    }

    @GetMapping("/brokers/performance")
    public ResponseEntity<List<BrokerPerformanceDto>> getBrokersPerformance(@RequestParam UUID companyId) {
        return ResponseEntity.ok(analyticsService.getBrokersPerformance(companyId));
    }
}
