package com.example.demo.service;

import com.example.demo.model.Order;
import com.example.demo.repository.OrderRepository;
import com.example.demo.repository.OrderItemRepository;
import com.example.demo.repository.BookRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository itemRepository;
    private final BookRepository bookRepository;

    public OrderService(
            OrderRepository orderRepository,
            OrderItemRepository itemRepository,
            BookRepository bookRepository) {
        this.orderRepository = orderRepository;
        this.itemRepository = itemRepository;
        this.bookRepository = bookRepository;
    }

    public List<Order> findAll() {
        List<Order> orders = orderRepository.findAll();
        for (Order o : orders) {
            o.setItems(itemRepository.findByOrderId(o.getId()));
        }
        return orders;
    }

    public Order findById(Integer id) {
        validateId(id);

        Order order = orderRepository.findById(id)
            .orElseThrow(() ->
                new IllegalArgumentException(
                    "Không tìm thấy đơn hàng ID = " + id
                )
            );
        order.setItems(itemRepository.findByOrderId(id));
        return order;
    }

    public List<Order> findByUsername(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException(
                "Username không được để trống."
            );
        }

        List<Order> orders = orderRepository.findByUsername(username.trim());
        for (Order o : orders) {
            o.setItems(itemRepository.findByOrderId(o.getId()));
        }
        return orders;
    }

    @Transactional
    public Order create(Order order) {
        if (order == null
                || order.getUsername() == null
                || order.getUsername().isBlank()) {
            throw new IllegalArgumentException(
                "Username không được để trống."
            );
        }

        if (order.getStatus() == null
                || order.getStatus().isBlank()) {
            order.setStatus("PENDING");
        }

        order.setId(null);
        order.setUsername(order.getUsername().trim());

        if (order.getDate() == null) {
            order.setDate(LocalDateTime.now());
        }

        int id = orderRepository.save(order);

        if (order.getItems() != null) {
            for (com.example.demo.model.OrderItem item : order.getItems()) {
                item.setOrderid(id);
                if (item.getPrice() == null && item.getBookid() != null) {
                    bookRepository.findById(item.getBookid())
                        .ifPresent(b -> item.setPrice(b.getPrice()));
                }
                itemRepository.save(item);
            }
        }

        return findById(id);
    }

    public Order updateStatus(Integer id, String status) {
        validateId(id);

        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException(
                "Status không được để trống."
            );
        }

        findById(id);

        orderRepository.updateStatus(id, status.trim());

        return findById(id);
    }

    @Transactional
    public void delete(Integer id) {
        validateId(id);
        findById(id);

        // Xóa chi tiết trước để tránh vi phạm khóa ngoại
        itemRepository.deleteByOrderId(id);
        orderRepository.deleteById(id);
    }

    private void validateId(Integer id) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                "ID phải là số nguyên dương."
            );
        }
    }
}