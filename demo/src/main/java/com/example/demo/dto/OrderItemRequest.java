package com.example.demo.dto;



import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public record OrderItemRequest(
    @NotNull @Positive(message = "Order ID phải lớn hơn 0")
    Integer orderid,

    @NotNull @Positive(message = "Book ID phải lớn hơn 0")
    Integer bookid,

    @NotNull @Positive(message = "Số lượng phải lớn hơn 0")
    Integer quantity,

    @NotNull
    @DecimalMin(value = "0.0", message = "Giá không được âm")
    BigDecimal price
) {}
