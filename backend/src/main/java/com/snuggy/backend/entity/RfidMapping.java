package com.snuggy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;

@Entity
@Table(name = "rfid_mappings")
@Data
public class RfidMapping {
    @Id    private String rfidUid;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name ="student_id", referencedColumnName="id")
    private User user;

    @CreationTimestamp
    private Timestamp createdAt;

}
