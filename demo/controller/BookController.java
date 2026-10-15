
package com.example.demo.controller;

import com.example.demo.model.Book;
import com.example.demo.service.BookService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookController {

    private final BookService service;

    public BookController(BookService service) {
        this.service = service;
    }

    // GET /api/books
    @GetMapping
    public List<Book> findAll() {
        return service.findAll();
    }

    // GET /api/books/{id}
    @GetMapping("/{id}")
    public Book findById(@PathVariable int id) {
        return service.findById(id);
    }

    // POST /api/books
    @PostMapping
    public ResponseEntity<Book> create(
            @Valid @RequestBody Book book) {

        Book created = service.create(book);

        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(created);
    }

    // PUT /api/books/{id}
    @PutMapping("/{id}")
    public Book update(
            @PathVariable int id,
            @Valid @RequestBody Book book) {

        return service.update(id, book);
    }

    // DELETE /api/books/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable int id) {

        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
