package com.realestate.backend.modules.stories;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StoryController {

    private final StoryService storyService;

    @PostMapping("/api/v1/stories/generate")
    public ResponseEntity<Map<String, String>> generateStoryLink(
            @RequestParam UUID unitId,
            @RequestParam UUID brokerId) {
        String shortCode = storyService.generateStoryLink(unitId, brokerId);
        String fullUrl = "http://localhost:8080/s/" + shortCode;

        return ResponseEntity.ok(Map.of(
                "shortCode", shortCode,
                "storyUrl", fullUrl,
                "status", "ACTIVE"
        ));
    }

    @GetMapping(value = "/s/{shortCode}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> viewPropertyStory(@PathVariable String shortCode) {
        String html = storyService.getStoryMicrositeHtml(shortCode);
        return ResponseEntity.ok(html);
    }
}
