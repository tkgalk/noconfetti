// Go Example - HTTP API Server with Goroutines
// Testing: comments, strings, numbers, keywords, structs, interfaces, goroutines

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"
)

// Constants
const (
	APIVersion   = "v1.0"
	MaxUsers     = 1000
	Timeout      = 30 * time.Second
	Port         = ":8080"
)

// User represents a user entity
type User struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Age       int       `json:"age"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
}

// NewUser creates a new user instance
func NewUser(name, email string, age int, role string) *User {
	return &User{
		Name:      name,
		Email:     email,
		Age:       age,
		Role:      role,
		CreatedAt: time.Now(),
	}
}

// IsAdult checks if user is 18 or older
func (u *User) IsAdult() bool {
	return u.Age >= 18
}

// String returns string representation of user
func (u *User) String() string {
	return fmt.Sprintf("User{id=%d, name=%s, age=%d}", u.ID, u.Name, u.Age)
}

// Repository interface for data access
type Repository interface {
	Find(id int) (*User, error)
	FindAll() ([]*User, error)
	Save(user *User) (*User, error)
	Delete(id int) error
}

// UserRepository implements Repository with in-memory storage
type UserRepository struct {
	mu      sync.RWMutex
	users   map[int]*User
	nextID  int
}

// NewUserRepository creates a new repository
func NewUserRepository() *UserRepository {
	return &UserRepository{
		users:  make(map[int]*User),
		nextID: 1,
	}
}

// Find returns user by ID
func (r *UserRepository) Find(id int) (*User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	user, exists := r.users[id]
	if !exists {
		return nil, fmt.Errorf("user not found: %d", id)
	}
	return user, nil
}

// FindAll returns all users
func (r *UserRepository) FindAll() ([]*User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	users := make([]*User, 0, len(r.users))
	for _, user := range r.users {
		users = append(users, user)
	}
	return users, nil
}

// Save adds or updates a user
func (r *UserRepository) Save(user *User) (*User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	if user.ID == 0 {
		user.ID = r.nextID
		r.nextID++
	}
	r.users[user.ID] = user
	return user, nil
}

// Delete removes a user by ID
func (r *UserRepository) Delete(id int) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.users[id]; !exists {
		return fmt.Errorf("user not found: %d", id)
	}
	delete(r.users, id)
	return nil
}

// FindByRole returns users with specific role
func (r *UserRepository) FindByRole(role string) ([]*User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	users := make([]*User, 0)
	for _, user := range r.users {
		if user.Role == role {
			users = append(users, user)
		}
	}
	return users, nil
}

// UserService handles business logic
type UserService struct {
	repo Repository
}

// NewUserService creates a new service
func NewUserService(repo Repository) *UserService {
	return &UserService{repo: repo}
}

// CreateUser creates a new user
func (s *UserService) CreateUser(name, email string, age int, role string) (*User, error) {
	if err := validateAge(age); err != nil {
		return nil, err
	}

	user := NewUser(name, email, age, role)
	return s.repo.Save(user)
}

// GetAdultUsers returns all adult users
func (s *UserService) GetAdultUsers() ([]*User, error) {
	users, err := s.repo.FindAll()
	if err != nil {
		return nil, err
	}

	adults := make([]*User, 0)
	for _, user := range users {
		if user.IsAdult() {
			adults = append(adults, user)
		}
	}
	return adults, nil
}

// GetAverageAge calculates average user age
func (s *UserService) GetAverageAge() (float64, error) {
	users, err := s.repo.FindAll()
	if err != nil {
		return 0, err
	}

	if len(users) == 0 {
		return 0, nil
	}

	totalAge := 0
	for _, user := range users {
		totalAge += user.Age
	}

	return float64(totalAge) / float64(len(users)), nil
}

func validateAge(age int) error {
	if age < 0 || age > 150 {
		return fmt.Errorf("age must be between 0 and 150")
	}
	return nil
}

// HTTP handlers
type Handler struct {
	service *UserService
}

func NewHandler(service *UserService) *Handler {
	return &Handler{service: service}
}

func (h *Handler) GetUsers(w http.ResponseWriter, r *http.Request) {
	users, err := h.service.repo.FindAll()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}

// Goroutine examples
func processUsersConcurrently(users []*User) {
	var wg sync.WaitGroup
	results := make(chan string, len(users))

	for _, user := range users {
		wg.Add(1)
		go func(u *User) {
			defer wg.Done()
			// Simulate processing
			time.Sleep(100 * time.Millisecond)
			results <- fmt.Sprintf("Processed: %s", u.Name)
		}(user)
	}

	// Wait for all goroutines
	go func() {
		wg.Wait()
		close(results)
	}()

	// Collect results
	for result := range results {
		fmt.Println(result)
	}
}

// Select statement example
func timeoutExample() {
	ch := make(chan string, 1)

	go func() {
		time.Sleep(2 * time.Second)
		ch <- "result"
	}()

	select {
	case result := <-ch:
		fmt.Println("Received:", result)
	case <-time.After(1 * time.Second):
		fmt.Println("Timeout!")
	}
}

// Slice operations
func demonstrateSlices() {
	numbers := []int{1, 2, 3, 4, 5}
	fmt.Println("Numbers:", numbers)

	// Append
	numbers = append(numbers, 6, 7, 8)
	fmt.Println("After append:", numbers)

	// Slice
	subset := numbers[2:5]
	fmt.Println("Subset:", subset)

	// Range
	for i, num := range numbers {
		if i < 3 {
			fmt.Printf("Index %d: %d\n", i, num)
		}
	}

	// Filter (using new slice)
	evens := make([]int, 0)
	for _, num := range numbers {
		if num%2 == 0 {
			evens = append(evens, num)
		}
	}
	fmt.Println("Evens:", evens)
}

// Map operations
func demonstrateMaps() {
	// Create map
	config := map[string]interface{}{
		"host":    "localhost",
		"port":    8080,
		"ssl":     true,
		"timeout": 30,
	}

	// Access
	fmt.Println("Host:", config["host"])

	// Check existence
	if port, exists := config["port"]; exists {
		fmt.Println("Port:", port)
	}

	// Iterate
	for key, value := range config {
		fmt.Printf("%s: %v\n", key, value)
	}

	// Delete
	delete(config, "ssl")
}

// Defer example
func demonstrateDefer() {
	fmt.Println("Start")
	defer fmt.Println("Deferred 1")
	defer fmt.Println("Deferred 2")
	fmt.Println("End")
	// Output: Start, End, Deferred 2, Deferred 1
}

// Error handling
type ValidationError struct {
	Field string
	Error string
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("%s: %s", e.Field, e.Error)
}

// Main function
func main() {
	fmt.Println("Go User Management System")
	fmt.Println("API Version:", APIVersion)

	// Create repository and service
	repo := NewUserRepository()
	service := NewUserService(repo)

	// Create users
	alice, _ := service.CreateUser("Alice Johnson", "alice@example.com", 28, "admin")
	bob, _ := service.CreateUser("Bob Smith", "bob@example.com", 17, "user")
	charlie, _ := service.CreateUser("Charlie Brown", "charlie@example.com", 45, "user")

	fmt.Println("\nCreated users:")
	fmt.Println(alice)
	fmt.Println(bob)
	fmt.Println(charlie)

	// Get adult users
	adults, _ := service.GetAdultUsers()
	fmt.Printf("\nAdult users: %d\n", len(adults))
	for _, user := range adults {
		fmt.Printf("  %s (%d)\n", user.Name, user.Age)
	}

	// Average age
	avgAge, _ := service.GetAverageAge()
	fmt.Printf("\nAverage age: %.2f\n", avgAge)

	// Goroutine example
	fmt.Println("\nProcessing users concurrently:")
	processUsersConcurrently([]*User{alice, bob, charlie})

	// Demonstrations
	fmt.Println("\nSlice demonstration:")
	demonstrateSlices()

	fmt.Println("\nMap demonstration:")
	demonstrateMaps()

	fmt.Println("\nDefer demonstration:")
	demonstrateDefer()

	// Start HTTP server (commented out)
	// handler := NewHandler(service)
	// http.HandleFunc("/users", handler.GetUsers)
	// log.Printf("Starting server on %s\n", Port)
	// log.Fatal(http.ListenAndServe(Port, nil))
}
