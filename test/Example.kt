// Kotlin Example - Android/JVM Application
// Testing: comments, strings, numbers, keywords, classes, data classes, lambdas

package com.example.demo

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

// Constants
const val API_VERSION = "v1.0"
const val MAX_USERS = 1000
const val TIMEOUT_MS = 30000L

// Enum class
enum class UserRole {
    GUEST, USER, ADMIN;

    fun isPrivileged() = this == ADMIN
}

// Data class (automatically generates equals, hashCode, toString, copy)
data class User(
    var id: Int = 0,
    val name: String,
    val email: String,
    val age: Int,
    val role: UserRole = UserRole.USER,
    val createdAt: LocalDateTime = LocalDateTime.now()
) {
    // Computed property
    val isAdult: Boolean
        get() = age >= 18

    val isAdmin: Boolean
        get() = role == UserRole.ADMIN

    // Member function
    fun toDisplayString(): String {
        return "User(id=$id, name='$name', age=$age, role=$role)"
    }
}

// Sealed class for Result type
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// Generic repository interface
interface Repository<T> {
    fun find(id: Int): T?
    fun findAll(): List<T>
    fun save(entity: T): T
    fun delete(id: Int): Boolean
}

// User repository implementation
class UserRepository : Repository<User> {
    private val users = mutableMapOf<Int, User>()
    private var nextId = 1

    override fun find(id: Int): User? {
        return users[id]
    }

    override fun findAll(): List<User> {
        return users.values.toList()
    }

    override fun save(entity: User): User {
        if (entity.id == 0) {
            entity.id = nextId++
        }
        users[entity.id] = entity
        return entity
    }

    override fun delete(id: Int): Boolean {
        return users.remove(id) != null
    }

    // Extension function on repository
    fun findByRole(role: UserRole): List<User> {
        return users.values.filter { it.role == role }
    }

    fun findByEmail(email: String): User? {
        return users.values.find { it.email == email }
    }
}

// User service with business logic
class UserService(private val repository: Repository<User>) {

    fun createUser(
        name: String,
        email: String,
        age: Int,
        role: UserRole = UserRole.USER
    ): Result<User> {
        return try {
            validateAge(age)
            validateEmail(email)

            val user = User(name = name, email = email, age = age, role = role)
            val saved = repository.save(user)
            Result.Success(saved)
        } catch (e: Exception) {
            Result.Error(e.message ?: "Unknown error")
        }
    }

    fun getAdultUsers(): List<User> {
        return repository.findAll().filter { it.isAdult }
    }

    fun getUsersByRole(role: UserRole): List<User> {
        return repository.findAll().filter { it.role == role }
    }

    fun getAverageAge(): Double {
        val users = repository.findAll()
        return if (users.isEmpty()) {
            0.0
        } else {
            users.map { it.age }.average()
        }
    }

    fun groupByRole(): Map<UserRole, List<User>> {
        return repository.findAll().groupBy { it.role }
    }

    private fun validateAge(age: Int) {
        require(age in 0..150) { "Age must be between 0 and 150" }
    }

    private fun validateEmail(email: String) {
        require(email.contains("@")) { "Invalid email format" }
    }
}

// Extension functions
fun User.getDisplayName(): String {
    return "$name ($email)"
}

fun User.isEligibleForDiscount(): Boolean {
    return age <= 18 || age >= 65
}

// Higher-order functions
fun processUsers(users: List<User>, predicate: (User) -> Boolean): List<User> {
    return users.filter(predicate)
}

fun transformUsers(users: List<User>, transform: (User) -> String): List<String> {
    return users.map(transform)
}

// Demonstrating collections and lambdas
fun demonstrateCollections() {
    val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    // Filter
    val evens = numbers.filter { it % 2 == 0 }
    println("Evens: $evens")

    // Map
    val doubled = numbers.map { it * 2 }
    println("Doubled: $doubled")

    // Reduce
    val sum = numbers.reduce { acc, n -> acc + n }
    println("Sum: $sum")

    // Fold
    val product = numbers.fold(1) { acc, n -> acc * n }
    println("Product: $product")

    // Chain operations
    val result = numbers
        .filter { it % 2 == 0 }
        .map { it * 2 }
        .sum()
    println("Chained result: $result")

    // Partition
    val (adults, minors) = listOf(
        User(name = "Alice", email = "alice@example.com", age = 28),
        User(name = "Bob", email = "bob@example.com", age = 17)
    ).partition { it.isAdult }
    println("Adults: ${adults.size}, Minors: ${minors.size}")
}

// Scope functions demonstration
fun demonstrateScopeFunctions() {
    // let
    val user = User(name = "Test", email = "test@example.com", age = 25)
    user.let {
        println("User name: ${it.name}")
        println("Is adult: ${it.isAdult}")
    }

    // apply
    val newUser = User(name = "New", email = "new@example.com", age = 30).apply {
        id = 100
    }

    // also
    val savedUser = newUser.also {
        println("Saving user: ${it.name}")
    }

    // run
    val displayName = user.run {
        "$name - $email"
    }
    println("Display: $displayName")

    // with
    with(user) {
        println("Name: $name")
        println("Age: $age")
    }
}

// Null safety demonstration
fun demonstrateNullSafety() {
    val nullableString: String? = null
    val nonNullString: String = "Hello"

    // Safe call operator
    println("Length: ${nullableString?.length}")

    // Elvis operator
    val length = nullableString?.length ?: 0
    println("Length with default: $length")

    // Let with null check
    nullableString?.let {
        println("Not null: $it")
    }

    // Not-null assertion (use carefully)
    // val len = nullableString!!.length  // Would throw NPE
}

// When expression (enhanced switch)
fun getUserType(user: User): String {
    return when {
        user.isAdmin -> "Administrator"
        user.isAdult -> "Adult User"
        user.age < 13 -> "Child"
        else -> "Minor"
    }
}

fun processResult(result: Result<User>) {
    when (result) {
        is Result.Success -> println("Success: ${result.data}")
        is Result.Error -> println("Error: ${result.message}")
        is Result.Loading -> println("Loading...")
    }
}

// Coroutine-like suspend function (conceptual)
suspend fun fetchUserData(userId: Int): User? {
    // Simulate async operation
    kotlinx.coroutines.delay(1000)
    return User(id = userId, name = "Async User", email = "async@example.com", age = 30)
}

// Main function
fun main() {
    println("Kotlin User Management System")
    println("API Version: $API_VERSION")

    // Create repository and service
    val repo = UserRepository()
    val service = UserService(repo)

    // Create users
    val aliceResult = service.createUser("Alice Johnson", "alice@example.com", 28, UserRole.ADMIN)
    val bobResult = service.createUser("Bob Smith", "bob@example.com", 17)
    val charlieResult = service.createUser("Charlie Brown", "charlie@example.com", 45)

    // Pattern match on results
    when (aliceResult) {
        is Result.Success -> println("\nCreated: ${aliceResult.data}")
        is Result.Error -> println("Error: ${aliceResult.message}")
        Result.Loading -> println("Loading...")
    }

    // Get adult users
    val adults = service.getAdultUsers()
    println("\nAdult users: ${adults.size}")
    adults.forEach { user ->
        println("  ${user.name} (${user.age})")
    }

    // Average age
    val avgAge = service.getAverageAge()
    println("\nAverage age: ${"%.2f".format(avgAge)}")

    // Group by role
    val grouped = service.groupByRole()
    println("\nUsers by role:")
    grouped.forEach { (role, users) ->
        println("  $role: ${users.size}")
    }

    // Extension function usage
    if (aliceResult is Result.Success) {
        val alice = aliceResult.data
        println("\nDisplay name: ${alice.getDisplayName()}")
        println("Eligible for discount: ${alice.isEligibleForDiscount()}")
        println("User type: ${getUserType(alice)}")
    }

    // Demonstrations
    println("\nCollection operations:")
    demonstrateCollections()

    println("\nScope functions:")
    demonstrateScopeFunctions()

    println("\nNull safety:")
    demonstrateNullSafety()

    // Lambda usage
    val adultNames = service.getAdultUsers()
        .map { it.name }
        .sorted()
    println("\nAdult names: $adultNames")

    // Higher-order function
    val admins = processUsers(repo.findAll()) { it.isAdmin }
    println("Admin count: ${admins.size}")
}
