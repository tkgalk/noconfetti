// Rust Example - Safe Systems Programming with Ownership
// Testing: comments, strings, numbers, keywords, structs, enums, traits, lifetimes

use std::collections::HashMap;
use std::error::Error;
use std::fmt;
use std::time::SystemTime;

// Constants
const API_VERSION: &str = "v1.0";
const MAX_USERS: usize = 1000;
const TIMEOUT_SECS: u64 = 30;

// User role enum
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum UserRole {
    Guest,
    User,
    Admin,
}

impl fmt::Display for UserRole {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            UserRole::Guest => write!(f, "guest"),
            UserRole::User => write!(f, "user"),
            UserRole::Admin => write!(f, "admin"),
        }
    }
}

// User struct
#[derive(Debug, Clone)]
struct User {
    id: Option<u32>,
    name: String,
    email: String,
    age: u8,
    role: UserRole,
    created_at: SystemTime,
}

impl User {
    fn new(name: String, email: String, age: u8, role: UserRole) -> Self {
        Self {
            id: None,
            name,
            email,
            age,
            role,
            created_at: SystemTime::now(),
        }
    }

    fn is_adult(&self) -> bool {
        self.age >= 18
    }

    fn is_admin(&self) -> bool {
        self.role == UserRole::Admin
    }
}

impl fmt::Display for User {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "User{{id={:?}, name=\"{}\", age={}}}",
            self.id, self.name, self.age
        )
    }
}

// Custom error type
#[derive(Debug)]
enum UserError {
    InvalidAge(u8),
    InvalidEmail(String),
    UserNotFound(u32),
    RepositoryFull,
}

impl fmt::Display for UserError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            UserError::InvalidAge(age) => write!(f, "Invalid age: {}", age),
            UserError::InvalidEmail(email) => write!(f, "Invalid email: {}", email),
            UserError::UserNotFound(id) => write!(f, "User not found: {}", id),
            UserError::RepositoryFull => write!(f, "Repository is full"),
        }
    }
}

impl Error for UserError {}

// Repository trait
trait Repository<T> {
    fn find(&self, id: u32) -> Option<&T>;
    fn find_all(&self) -> Vec<&T>;
    fn save(&mut self, entity: T) -> Result<&T, UserError>;
    fn delete(&mut self, id: u32) -> Result<(), UserError>;
}

// User repository implementation
struct UserRepository {
    users: HashMap<u32, User>,
    next_id: u32,
}

impl UserRepository {
    fn new() -> Self {
        Self {
            users: HashMap::new(),
            next_id: 1,
        }
    }

    fn find_by_email(&self, email: &str) -> Option<&User> {
        self.users.values().find(|user| user.email == email)
    }

    fn find_by_role(&self, role: UserRole) -> Vec<&User> {
        self.users
            .values()
            .filter(|user| user.role == role)
            .collect()
    }

    fn count(&self) -> usize {
        self.users.len()
    }
}

impl Repository<User> for UserRepository {
    fn find(&self, id: u32) -> Option<&User> {
        self.users.get(&id)
    }

    fn find_all(&self) -> Vec<&User> {
        self.users.values().collect()
    }

    fn save(&mut self, mut entity: User) -> Result<&User, UserError> {
        if self.users.len() >= MAX_USERS {
            return Err(UserError::RepositoryFull);
        }

        let id = self.next_id;
        entity.id = Some(id);
        self.users.insert(id, entity);
        self.next_id += 1;

        Ok(self.users.get(&id).unwrap())
    }

    fn delete(&mut self, id: u32) -> Result<(), UserError> {
        self.users
            .remove(&id)
            .map(|_| ())
            .ok_or(UserError::UserNotFound(id))
    }
}

// User service with business logic
struct UserService {
    repository: UserRepository,
}

impl UserService {
    fn new(repository: UserRepository) -> Self {
        Self { repository }
    }

    fn create_user(
        &mut self,
        name: String,
        email: String,
        age: u8,
        role: UserRole,
    ) -> Result<&User, UserError> {
        Self::validate_age(age)?;
        Self::validate_email(&email)?;

        let user = User::new(name, email, age, role);
        self.repository.save(user)
    }

    fn get_adult_users(&self) -> Vec<&User> {
        self.repository
            .find_all()
            .into_iter()
            .filter(|user| user.is_adult())
            .collect()
    }

    fn get_average_age(&self) -> f64 {
        let users = self.repository.find_all();
        if users.is_empty() {
            return 0.0;
        }

        let total_age: u32 = users.iter().map(|user| user.age as u32).sum();
        total_age as f64 / users.len() as f64
    }

    fn group_by_role(&self) -> HashMap<UserRole, Vec<&User>> {
        let mut groups: HashMap<UserRole, Vec<&User>> = HashMap::new();

        for user in self.repository.find_all() {
            groups.entry(user.role).or_insert_with(Vec::new).push(user);
        }

        groups
    }

    fn validate_age(age: u8) -> Result<(), UserError> {
        if age > 150 {
            Err(UserError::InvalidAge(age))
        } else {
            Ok(())
        }
    }

    fn validate_email(email: &str) -> Result<(), UserError> {
        if !email.contains('@') {
            Err(UserError::InvalidEmail(email.to_string()))
        } else {
            Ok(())
        }
    }
}

// Iterator examples
fn demonstrate_iterators() {
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // Map
    let doubled: Vec<i32> = numbers.iter().map(|n| n * 2).collect();
    println!("Doubled: {:?}", doubled);

    // Filter
    let evens: Vec<&i32> = numbers.iter().filter(|n| *n % 2 == 0).collect();
    println!("Evens: {:?}", evens);

    // Fold (reduce)
    let sum: i32 = numbers.iter().fold(0, |acc, n| acc + n);
    println!("Sum: {}", sum);

    // Chain
    let result: Vec<i32> = numbers
        .iter()
        .filter(|n| *n % 2 == 0)
        .map(|n| n * 2)
        .collect();
    println!("Chained result: {:?}", result);
}

// Option and Result examples
fn demonstrate_option_result() {
    // Option
    let some_value = Some(42);
    let none_value: Option<i32> = None;

    match some_value {
        Some(v) => println!("Got value: {}", v),
        None => println!("No value"),
    }

    // Unwrap with default
    let value = none_value.unwrap_or(0);
    println!("Value with default: {}", value);

    // Result
    let result: Result<i32, &str> = Ok(42);
    let error: Result<i32, &str> = Err("Something went wrong");

    if let Ok(v) = result {
        println!("Success: {}", v);
    }

    if let Err(e) = error {
        println!("Error: {}", e);
    }
}

// Pattern matching examples
fn demonstrate_pattern_matching() {
    let number = 7;

    match number {
        1 => println!("One"),
        2 | 3 | 5 | 7 => println!("Prime"),
        4 | 6 | 8 | 9 | 10 => println!("Composite"),
        _ => println!("Other"),
    }

    // Match with guards
    match number {
        n if n < 0 => println!("Negative"),
        n if n == 0 => println!("Zero"),
        n if n > 0 => println!("Positive: {}", n),
        _ => unreachable!(),
    }
}

// Struct with lifetime example
#[derive(Debug)]
struct UserRef<'a> {
    name: &'a str,
    email: &'a str,
}

impl<'a> UserRef<'a> {
    fn new(name: &'a str, email: &'a str) -> Self {
        Self { name, email }
    }

    fn display(&self) -> String {
        format!("UserRef{{ name: {}, email: {} }}", self.name, self.email)
    }
}

// Generic function
fn find_max<T: PartialOrd>(items: &[T]) -> Option<&T> {
    if items.is_empty() {
        return None;
    }

    let mut max = &items[0];
    for item in &items[1..] {
        if item > max {
            max = item;
        }
    }

    Some(max)
}

// Main function
fn main() -> Result<(), Box<dyn Error>> {
    println!("Rust User Management System");
    println!("API Version: {}", API_VERSION);

    // Create repository and service
    let repo = UserRepository::new();
    let mut service = UserService::new(repo);

    // Create users
    let alice = service.create_user(
        "Alice Johnson".to_string(),
        "alice@example.com".to_string(),
        28,
        UserRole::Admin,
    )?;
    println!("\nCreated: {}", alice);

    let bob = service.create_user(
        "Bob Smith".to_string(),
        "bob@example.com".to_string(),
        17,
        UserRole::User,
    )?;
    println!("Created: {}", bob);

    let charlie = service.create_user(
        "Charlie Brown".to_string(),
        "charlie@example.com".to_string(),
        45,
        UserRole::User,
    )?;
    println!("Created: {}", charlie);

    // Get adult users
    let adults = service.get_adult_users();
    println!("\nAdult users: {}", adults.len());
    for user in &adults {
        println!("  {} ({})", user.name, user.age);
    }

    // Average age
    let avg_age = service.get_average_age();
    println!("\nAverage age: {:.2}", avg_age);

    // Group by role
    let grouped = service.group_by_role();
    println!("\nUsers by role:");
    for (role, users) in &grouped {
        println!("  {}: {}", role, users.len());
    }

    // Demonstrations
    println!("\nIterator demonstration:");
    demonstrate_iterators();

    println!("\nOption and Result demonstration:");
    demonstrate_option_result();

    println!("\nPattern matching demonstration:");
    demonstrate_pattern_matching();

    // Lifetime example
    let name = String::from("Test User");
    let email = String::from("test@example.com");
    let user_ref = UserRef::new(&name, &email);
    println!("\n{}", user_ref.display());

    // Generic function example
    let numbers = vec![3, 7, 1, 9, 2];
    if let Some(max) = find_max(&numbers) {
        println!("\nMax number: {}", max);
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_is_adult() {
        let user = User::new(
            "Test".to_string(),
            "test@example.com".to_string(),
            20,
            UserRole::User,
        );
        assert!(user.is_adult());
    }

    #[test]
    fn test_user_is_minor() {
        let user = User::new(
            "Test".to_string(),
            "test@example.com".to_string(),
            15,
            UserRole::User,
        );
        assert!(!user.is_adult());
    }
}
