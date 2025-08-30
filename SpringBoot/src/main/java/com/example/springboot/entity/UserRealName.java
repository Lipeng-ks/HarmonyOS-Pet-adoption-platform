package com.example.springboot.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "user_real_name", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id"}),
    @UniqueConstraint(columnNames = {"id_number"})
}, indexes = {
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_id_number", columnList = "id_number")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRealName {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    @Column(name = "full_name", nullable = false, length = 100)
    @NotBlank
    private String fullName;

    @Column(name = "id_number", nullable = false, length = 50, unique = true)
    @NotBlank
    private String idNumber;
}


