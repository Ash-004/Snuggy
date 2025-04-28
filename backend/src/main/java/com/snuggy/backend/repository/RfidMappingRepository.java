package com.snuggy.backend.repository;

import com.snuggy.backend.entity.RfidMapping;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RfidMappingRepository extends JpaRepository<RfidMapping, String> {
}
