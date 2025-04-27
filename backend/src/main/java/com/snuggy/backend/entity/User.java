package com.snuggy.backend.entity;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;

@Entity
@Table(name="users")
@Data
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private  String name;

    @Column(unique = true,nullable = false)
    private  String email;

    private  String password_hash;

    @CreationTimestamp
    private Timestamp createdAt;

}
