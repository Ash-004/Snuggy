package com.snuggy.backend.entity;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;

@Entity
@Table(name="orders")
@Data
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="student_id", referencedColumnName="id")
    private User user;

    @Column(columnDefinition = "jsonb")
    private String items;
    private String status;

    @CreationTimestamp
    private Timestamp createdAt;

    private Timestamp updatedAt;
}
