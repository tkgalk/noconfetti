// Swift Example - iOS/macOS Application
// Testing: comments, strings, numbers, keywords, classes, protocols, closures

import Foundation
import Combine

// Constants
let apiVersion = "v1.0"
let maxUsers = 1000
let timeout: TimeInterval = 30

// User role enum
enum UserRole: String, Codable {
    case guest
    case user
    case admin

    var isPrivileged: Bool {
        self == .admin
    }
}

// User struct
struct User: Codable, Identifiable, Equatable {
    var id: Int?
    let name: String
    let email: String
    let age: Int
    let role: UserRole
    let createdAt: Date

    init(name: String, email: String, age: Int, role: UserRole = .user) {
        self.id = nil
        self.name = name
        self.email = email
        self.age = age
        self.role = role
        self.createdAt = Date()
    }

    var isAdult: Bool {
        age >= 18
    }

    var isAdmin: Bool {
        role == .admin
    }

    func displayString() -> String {
        "User(id=\(id ?? 0), name='\(name)', age=\(age))"
    }
}

// Custom error type
enum UserError: Error, LocalizedError {
    case invalidAge(Int)
    case invalidEmail(String)
    case userNotFound(Int)
    case repositoryFull

    var errorDescription: String? {
        switch self {
        case .invalidAge(let age):
            return "Invalid age: \(age)"
        case .invalidEmail(let email):
            return "Invalid email: \(email)"
        case .userNotFound(let id):
            return "User not found: \(id)"
        case .repositoryFull:
            return "Repository is full"
        }
    }
}

// Result type alias
typealias UserResult = Result<User, UserError>

// Repository protocol
protocol Repository {
    associatedtype Entity

    func find(id: Int) -> Entity?
    func findAll() -> [Entity]
    func save(entity: Entity) throws -> Entity
    func delete(id: Int) throws
}

// User repository implementation
class UserRepository: Repository {
    typealias Entity = User

    private var users: [Int: User] = [:]
    private var nextId = 1

    func find(id: Int) -> User? {
        users[id]
    }

    func findAll() -> [User] {
        Array(users.values)
    }

    func save(entity: User) throws -> User {
        guard users.count < maxUsers else {
            throw UserError.repositoryFull
        }

        var user = entity
        let id = nextId
        user.id = id
        users[id] = user
        nextId += 1

        return user
    }

    func delete(id: Int) throws {
        guard users.removeValue(forKey: id) != nil else {
            throw UserError.userNotFound(id)
        }
    }

    func findByEmail(_ email: String) -> User? {
        users.values.first { $0.email == email }
    }

    func findByRole(_ role: UserRole) -> [User] {
        users.values.filter { $0.role == role }
    }
}

// User service with business logic
class UserService {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func createUser(
        name: String,
        email: String,
        age: Int,
        role: UserRole = .user
    ) -> UserResult {
        do {
            try validateAge(age)
            try validateEmail(email)

            let user = User(name: name, email: email, age: age, role: role)
            let saved = try repository.save(entity: user)
            return .success(saved)
        } catch let error as UserError {
            return .failure(error)
        } catch {
            return .failure(.invalidEmail(email))
        }
    }

    func getAdultUsers() -> [User] {
        repository.findAll().filter { $0.isAdult }
    }

    func getUsersByRole(_ role: UserRole) -> [User] {
        repository.findByRole(role)
    }

    func getAverageAge() -> Double {
        let users = repository.findAll()
        guard !users.isEmpty else { return 0.0 }

        let totalAge = users.reduce(0) { $0 + $1.age }
        return Double(totalAge) / Double(users.count)
    }

    func groupByRole() -> [UserRole: [User]] {
        Dictionary(grouping: repository.findAll()) { $0.role }
    }

    private func validateAge(_ age: Int) throws {
        guard age >= 0 && age <= 150 else {
            throw UserError.invalidAge(age)
        }
    }

    private func validateEmail(_ email: String) throws {
        guard email.contains("@") else {
            throw UserError.invalidEmail(email)
        }
    }
}

// Extension on User
extension User {
    func getDisplayName() -> String {
        "\(name) (\(email))"
    }

    func isEligibleForDiscount() -> Bool {
        age <= 18 || age >= 65
    }
}

// Higher-order functions
func processUsers(_ users: [User], predicate: (User) -> Bool) -> [User] {
    users.filter(predicate)
}

func transformUsers(_ users: [User], transform: (User) -> String) -> [String] {
    users.map(transform)
}

// Collection operations
func demonstrateCollections() {
    let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    // Filter
    let evens = numbers.filter { $0 % 2 == 0 }
    print("Evens: \(evens)")

    // Map
    let doubled = numbers.map { $0 * 2 }
    print("Doubled: \(doubled)")

    // Reduce
    let sum = numbers.reduce(0, +)
    print("Sum: \(sum)")

    // CompactMap (filter nil)
    let strings = ["1", "2", "three", "4"]
    let validNumbers = strings.compactMap { Int($0) }
    print("Valid numbers: \(validNumbers)")

    // Chain operations
    let result = numbers
        .filter { $0 % 2 == 0 }
        .map { $0 * 2 }
        .reduce(0, +)
    print("Chained result: \(result)")
}

// Optional handling
func demonstrateOptionals() {
    var optionalString: String? = nil
    let nonOptionalString = "Hello"

    // Optional binding
    if let str = optionalString {
        print("Not nil: \(str)")
    } else {
        print("Is nil")
    }

    // Nil coalescing
    let value = optionalString ?? "default"
    print("Value with default: \(value)")

    // Optional chaining
    let length = optionalString?.count
    print("Length: \(String(describing: length))")

    // Guard let
    guard let str = optionalString else {
        print("Early return due to nil")
        return
    }
    print("Not reached if nil: \(str)")
}

// Pattern matching
func getUserType(_ user: User) -> String {
    switch user {
    case _ where user.isAdmin:
        return "Administrator"
    case _ where user.isAdult:
        return "Adult User"
    case _ where user.age < 13:
        return "Child"
    default:
        return "Minor"
    }
}

// Closure examples
func demonstrateClosures() {
    let numbers = [5, 2, 8, 1, 9]

    // Trailing closure
    let sorted = numbers.sorted { $0 < $1 }
    print("Sorted: \(sorted)")

    // Capture list
    var counter = 0
    let incrementer = { [counter] in
        print("Captured counter: \(counter)")
    }
    counter += 1
    incrementer() // Prints 0, not 1

    // Escaping closure
    var completionHandlers: [() -> Void] = []
    func addHandler(handler: @escaping () -> Void) {
        completionHandlers.append(handler)
    }

    addHandler {
        print("Handler executed")
    }
}

// Generic function
func findMax<T: Comparable>(_ items: [T]) -> T? {
    guard !items.isEmpty else { return nil }

    var max = items[0]
    for item in items[1...] {
        if item > max {
            max = item
        }
    }
    return max
}

// Property wrappers example
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>

    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(range.lowerBound, wrappedValue), range.upperBound)
    }
}

struct Settings {
    @Clamped(0...100) var volume: Int = 50
    @Clamped(0...150) var age: Int = 25
}

// Async/await example
func fetchUserData(userId: Int) async throws -> User {
    // Simulate async operation
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return User(id: userId, name: "Async User", email: "async@example.com", age: 30)
}

// Main execution
@main
struct UserManagementApp {
    static func main() {
        print("Swift User Management System")
        print("API Version: \(apiVersion)")

        // Create repository and service
        let repo = UserRepository()
        let service = UserService(repository: repo)

        // Create users
        let aliceResult = service.createUser(
            name: "Alice Johnson",
            email: "alice@example.com",
            age: 28,
            role: .admin
        )

        let bobResult = service.createUser(
            name: "Bob Smith",
            email: "bob@example.com",
            age: 17
        )

        let charlieResult = service.createUser(
            name: "Charlie Brown",
            email: "charlie@example.com",
            age: 45
        )

        // Pattern match on result
        switch aliceResult {
        case .success(let user):
            print("\nCreated: \(user)")
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }

        // Get adult users
        let adults = service.getAdultUsers()
        print("\nAdult users: \(adults.count)")
        for user in adults {
            print("  \(user.name) (\(user.age))")
        }

        // Average age
        let avgAge = service.getAverageAge()
        print("\nAverage age: \(String(format: "%.2f", avgAge))")

        // Group by role
        let grouped = service.groupByRole()
        print("\nUsers by role:")
        for (role, users) in grouped {
            print("  \(role.rawValue): \(users.count)")
        }

        // Extension usage
        if case .success(let alice) = aliceResult {
            print("\nDisplay name: \(alice.getDisplayName())")
            print("Eligible for discount: \(alice.isEligibleForDiscount())")
            print("User type: \(getUserType(alice))")
        }

        // Demonstrations
        print("\nCollection operations:")
        demonstrateCollections()

        print("\nOptional handling:")
        demonstrateOptionals()

        print("\nClosure demonstration:")
        demonstrateClosures()

        // Generic function
        let numbers = [3, 7, 1, 9, 2]
        if let max = findMax(numbers) {
            print("\nMax number: \(max)")
        }

        // Property wrapper
        var settings = Settings()
        print("\nInitial volume: \(settings.volume)")
        settings.volume = 150 // Will be clamped to 100
        print("Clamped volume: \(settings.volume)")
    }
}
