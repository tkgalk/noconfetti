// Java Example - Spring Boot REST API
// Testing: comments, strings, numbers, keywords, classes, interfaces, generics

package com.example.demo;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * User entity representing application users
 * Demonstrates Java classes, methods, and annotations
 */
public class User {
    private Long id;
    private String name;
    private String email;
    private int age;
    private LocalDateTime createdAt;

    // Constants
    public static final int MIN_AGE = 0;
    public static final int MAX_AGE = 150;
    public static final String DEFAULT_ROLE = "USER";

    public User(Long id, String name, String email, int age) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.age = age;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public boolean isAdult() {
        return age >= 18;
    }

    @Override
    public String toString() {
        return String.format("User{id=%d, name='%s', email='%s', age=%d}",
                           id, name, email, age);
    }
}

/**
 * Generic repository interface
 */
interface Repository<T, ID> {
    Optional<T> findById(ID id);
    List<T> findAll();
    T save(T entity);
    void delete(ID id);
}

/**
 * User repository implementation with in-memory storage
 */
class UserRepository implements Repository<User, Long> {
    private final Map<Long, User> storage = new HashMap<>();
    private Long nextId = 1L;

    @Override
    public Optional<User> findById(Long id) {
        return Optional.ofNullable(storage.get(id));
    }

    @Override
    public List<User> findAll() {
        return new ArrayList<>(storage.values());
    }

    @Override
    public User save(User user) {
        if (user.getId() == null) {
            user.setId(nextId++);
        }
        storage.put(user.getId(), user);
        return user;
    }

    @Override
    public void delete(Long id) {
        storage.remove(id);
    }

    public List<User> findByAge(int minAge, int maxAge) {
        return storage.values().stream()
                .filter(u -> u.getAge() >= minAge && u.getAge() <= maxAge)
                .collect(Collectors.toList());
    }

    public Optional<User> findByEmail(String email) {
        return storage.values().stream()
                .filter(u -> u.getEmail().equals(email))
                .findFirst();
    }
}

/**
 * Service layer with business logic
 */
class UserService {
    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public User createUser(String name, String email, int age) {
        validateAge(age);
        User user = new User(null, name, email, age);
        return repository.save(user);
    }

    public List<User> getAdultUsers() {
        return repository.findAll().stream()
                .filter(User::isAdult)
                .collect(Collectors.toList());
    }

    public Map<Boolean, List<User>> groupByAdult() {
        return repository.findAll().stream()
                .collect(Collectors.partitioningBy(User::isAdult));
    }

    private void validateAge(int age) {
        if (age < User.MIN_AGE || age > User.MAX_AGE) {
            throw new IllegalArgumentException(
                "Age must be between " + User.MIN_AGE + " and " + User.MAX_AGE
            );
        }
    }
}

/**
 * Main application entry point
 */
public class Example {
    public static void main(String[] args) {
        UserRepository repo = new UserRepository();
        UserService service = new UserService(repo);

        // Create some users
        User alice = service.createUser("Alice Johnson", "alice@example.com", 28);
        User bob = service.createUser("Bob Smith", "bob@example.com", 17);
        User charlie = service.createUser("Charlie Brown", "charlie@example.com", 45);

        // Query users
        List<User> adults = service.getAdultUsers();
        System.out.println("Adult users: " + adults.size());

        // Stream operations
        List<String> names = repo.findAll().stream()
                .map(User::getName)
                .sorted()
                .collect(Collectors.toList());

        double averageAge = repo.findAll().stream()
                .mapToInt(User::getAge)
                .average()
                .orElse(0.0);

        // Group by adult status
        Map<Boolean, List<User>> grouped = service.groupByAdult();
        System.out.println("Adults: " + grouped.get(true).size());
        System.out.println("Minors: " + grouped.get(false).size());

        // Find specific user
        repo.findByEmail("alice@example.com")
                .ifPresent(user -> System.out.println("Found: " + user));
    }
}
