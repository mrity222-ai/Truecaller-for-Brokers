package com.realestate.backend.modules.stories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StoryRepository extends JpaRepository<StoryLink, UUID> {
    Optional<StoryLink> findByShortCode(String shortCode);
    Optional<StoryLink> findByUnitIdAndBrokerId(UUID unitId, UUID brokerId);
}
