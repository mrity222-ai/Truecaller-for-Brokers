package com.realestate.backend.modules.stories;

import com.realestate.backend.modules.auth_tenant.BrokerUser;
import com.realestate.backend.modules.auth_tenant.BrokerUserRepository;
import com.realestate.backend.modules.inventory.InventoryRepository;
import com.realestate.backend.modules.inventory.InventoryUnit;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StoryService {

    private final StoryRepository storyRepository;
    private final InventoryRepository inventoryRepository;
    private final BrokerUserRepository brokerRepository;

    @Transactional
    public String generateStoryLink(UUID unitId, UUID brokerId) {
        Optional<StoryLink> existing = storyRepository.findByUnitIdAndBrokerId(unitId, brokerId);
        if (existing.isPresent()) {
            return existing.get().getShortCode();
        }

        String shortCode = UUID.randomUUID().toString().substring(0, 6);
        StoryLink link = StoryLink.builder()
                .unitId(unitId)
                .brokerId(brokerId)
                .shortCode(shortCode)
                .viewCount(0)
                .whatsappClickCount(0)
                .expiresAt(LocalDateTime.now().addDays(30))
                .createdAt(LocalDateTime.now())
                .build();

        storyRepository.save(link);
        return shortCode;
    }

    @Transactional
    public String getStoryMicrositeHtml(String shortCode) {
        Optional<StoryLink> linkOpt = storyRepository.findByShortCode(shortCode);
        if (linkOpt.isEmpty()) {
            return "<html><body style='font-family:sans-serif;text-align:center;padding:50px;'><h2>Property Story Expired or Not Found</h2></body></html>";
        }

        StoryLink link = linkOpt.get();
        link.setViewCount(link.getViewCount() + 1);
        storyRepository.save(link);

        InventoryUnit unit = inventoryRepository.findById(link.getUnitId()).orElse(null);
        BrokerUser broker = brokerRepository.findById(link.getBrokerId()).orElse(null);

        String projectName = unit != null ? unit.getProjectName() : "Premium Property";
        String unitNumber = unit != null ? unit.getUnitNumber() : "Exclusive Unit";
        String unitType = unit != null ? unit.getUnitType() : "3BHK Luxury";
        String location = unit != null ? unit.getLocation() : "Noida Expressway";
        double price = unit != null ? unit.getAskingPriceInr() : 8500000;
        double area = unit != null ? unit.getSuperAreaSqft() : 1450;

        String brokerName = broker != null ? broker.getFullName() : "Property Consultant";
        String brokerPhone = broker != null ? broker.getPhoneNumber() : "+919876543210";
        String cleanPhone = brokerPhone.replaceAll("[^0-9]", "");

        String priceStr = price >= 10000000
                ? String.format("₹%.2f Cr", price / 10000000)
                : String.format("₹%.0f Lakh", price / 100000);

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <title>%s - %s</title>
            <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body { background: #000; color: #fff; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; height: 100vh; overflow: hidden; }
                .story-container { max-width: 480px; height: 100vh; margin: 0 auto; position: relative; background: linear-gradient(180deg, rgba(15,76,129,0.9) 0%%, rgba(10,25,47,0.95) 100%%); display: flex; flex-direction: column; justify-content: space-between; padding: 24px 20px; }
                .story-bar { display: flex; gap: 4px; margin-bottom: 16px; }
                .story-progress { height: 3px; flex: 1; background: rgba(255,255,255,0.3); border-radius: 2px; }
                .story-progress.active { background: #fff; }
                .badge { display: inline-block; background: #E5A93C; color: #000; padding: 4px 10px; border-radius: 20px; font-weight: bold; font-size: 12px; margin-bottom: 8px; }
                .title { font-size: 26px; font-weight: 800; line-height: 1.2; margin-bottom: 4px; }
                .subtitle { color: #ccc; font-size: 14px; margin-bottom: 24px; }
                .specs-card { background: rgba(255,255,255,0.08); backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.15); border-radius: 16px; padding: 18px; margin-bottom: 24px; }
                .spec-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.08); font-size: 14px; }
                .spec-row:last-child { border-bottom: none; }
                .spec-label { color: #aaa; }
                .spec-val { font-weight: bold; }
                .price-tag { font-size: 32px; font-weight: 800; color: #4ade80; margin-bottom: 8px; }
                .whatsapp-btn { display: flex; align-items: center; justify-content: center; gap: 10px; width: 100%%; background: #25D366; color: #000; text-decoration: none; padding: 16px; border-radius: 14px; font-weight: bold; font-size: 16px; box-shadow: 0 4px 15px rgba(37,211,102,0.4); }
                .broker-tag { text-align: center; font-size: 12px; color: #888; margin-top: 12px; }
            </style>
        </head>
        <body>
            <div class="story-container">
                <div>
                    <div class="story-bar">
                        <div class="story-progress active"></div>
                        <div class="story-progress active"></div>
                        <div class="story-progress"></div>
                    </div>
                    <span class="badge">Verified Direct Inventory</span>
                    <h1 class="title">%s</h1>
                    <p class="subtitle">%s • %s</p>
                </div>

                <div class="specs-card">
                    <div class="price-tag">%s</div>
                    <div class="spec-row">
                        <span class="spec-label">Configuration</span>
                        <span class="spec-val">%s</span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Super Built-up Area</span>
                        <span class="spec-val">%.0f sq.ft.</span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Facing / Direction</span>
                        <span class="spec-val">Park Facing • East</span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Bank Loan & PMAY</span>
                        <span class="spec-val">Pre-approved SBI / HDFC</span>
                    </div>
                </div>

                <div>
                    <a href="https://wa.me/%s?text=Hi%%20%s,%%20I%%20am%%20interested%%20in%%20%s%%20(%s)%%20listed%%20at%%20%s.%%20Please%%20share%%20more%%20details." class="whatsapp-btn">
                        <span>💬 Chat on WhatsApp with %s</span>
                    </a>
                    <p class="broker-tag">Shared via RealEstate Smart Pro • Direct Owner Deal</p>
                </div>
            </div>
        </body>
        </html>
        """.formatted(
            projectName, unitNumber,
            projectName, unitNumber, location,
            priceStr, unitType, area,
            cleanPhone, brokerName, projectName, unitNumber, priceStr,
            brokerName
        );
    }
}
