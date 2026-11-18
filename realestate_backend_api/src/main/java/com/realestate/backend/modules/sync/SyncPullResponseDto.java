package com.realestate.backend.modules.sync;

import com.realestate.backend.modules.client_leads.LeadEntity;
import com.realestate.backend.modules.inventory.InventoryUnit;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SyncPullResponseDto {
    private Long serverTimestamp;
    private List<LeadEntity> updatedLeads;
    private List<InventoryUnit> updatedInventories;
    private String status;
}
