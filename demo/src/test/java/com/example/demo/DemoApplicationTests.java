package com.example.demo;

import com.example.demo.repository.OrderItemRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
class DemoApplicationTests {

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Test
    void testOrderItemRepository() {
        assertNotNull(orderItemRepository.findAll());
    }
}
