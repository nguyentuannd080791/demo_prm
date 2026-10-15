package com.example.demo.controller;

import com.example.demo.model.Order;
import com.example.demo.model.OrderItem;
import com.example.demo.service.OrderService;
import com.example.demo.service.OrderItemService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderService orderService;
    private final OrderItemService itemService;

    public OrderController(
            OrderService orderService,
            OrderItemService itemService) {
        this.orderService = orderService;
        this.itemService = itemService;
    }

    @GetMapping
    public List<Order> findAll(Authentication authentication) {
        if (authentication != null && authentication.getName() != null && !authentication.getName().isBlank()) {
            return orderService.findByUsername(authentication.getName());
        }
        return orderService.findAll();
    }

    @GetMapping("/{id}")
    public Order findById(@PathVariable Integer id) {
        return orderService.findById(id);
    }

    @GetMapping("/{id}/items")
    public List<OrderItem> findItems(@PathVariable Integer id) {
        orderService.findById(id);
        return itemService.findByOrderId(id);
    }

    @GetMapping("/user/{username}")
    public List<Order> findByUsername(
            @PathVariable String username) {
        return orderService.findByUsername(username);
    }

    @PostMapping
    public ResponseEntity<Order> create(
            @RequestBody Order order,
            Authentication authentication) {
        if ((order.getUsername() == null || order.getUsername().isBlank())
                && authentication != null && authentication.getName() != null) {
            order.setUsername(authentication.getName());
        }
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(orderService.create(order));
    }

    @PatchMapping("/{id}/status")
    public Order updateStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body) {
        return orderService.updateStatus(
            id, body.get("status")
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Integer id) {
        orderService.delete(id);
        return ResponseEntity.noContent().build();
    }
}