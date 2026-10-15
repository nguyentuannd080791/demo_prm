package com.example.demo.dto;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;

public record OrderRequest(
    @NotBlank(message = "Username bắt buộc")
    @Size(max = 100)
    String username,

    LocalDateTime date,

    @NotBlank(message = "Trạng thái đơn hàng bắt buộc")
    @Size(max = 30)
    String status
) {}
