package com.example.demo.model;

import java.time.LocalDateTime;
import java.util.List;

public class Order {

    private Integer id;
    private String username;
    private LocalDateTime date;
    private String status;
    private List<OrderItem> items;

    public Order() {
    }

    public Order(Integer id, String username,
                 LocalDateTime date, String status) {
        this(id, username, date, status, null);
    }

    public Order(Integer id, String username,
                 LocalDateTime date, String status, List<OrderItem> items) {
        this.id = id;
        this.username = username;
        this.date = date;
        this.status = status;
        this.items = items;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }
}