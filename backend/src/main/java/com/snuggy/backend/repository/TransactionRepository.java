package com.snuggy.backend.repository;

import com.snuggy.backend.entity.Transaction;
import com.snuggy.backend.entity.TransactionId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, TransactionId> {

}
