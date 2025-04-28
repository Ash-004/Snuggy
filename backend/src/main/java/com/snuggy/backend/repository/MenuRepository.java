package com.snuggy.backend.repository;

import com.snuggy.backend.entity.Menu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MenuRepository extends JpaRepository<Menu, Long> {
    @Query("SELECT m FROM Menu m JOIN m.tags t WHERE t.name = :tagName")
    List<Menu> findAllByTagName(@Param("tagName") String tagName);
}
