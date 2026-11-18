package com.realestate.backend.modules.sync;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/sync")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SyncController {

    private final DeltaSyncService syncService;

    @PostMapping("/push")
    public ResponseEntity<SyncPullResponseDto> pushDelta(@RequestBody SyncPushRequestDto request) {
        SyncPullResponseDto response = syncService.processPush(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/pull")
    public ResponseEntity<SyncPullResponseDto> pullDelta(
            @RequestParam UUID companyId,
            @RequestParam(required = false, defaultValue = "0") Long since) {
        SyncPullResponseDto response = syncService.processPull(companyId, since);
        return ResponseEntity.ok(response);
    }
}
