package com.snuggy.backend.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionId implements Serializable {
    private Long studentId;
    private Long orderId;
}
