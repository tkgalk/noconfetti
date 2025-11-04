// Scala Example - Functional Programming with Type Safety
// Testing: comments, strings, numbers, keywords, case classes, traits, for-comprehensions

package com.example.demo

import java.time.{LocalDateTime, ZoneId}
import scala.collection.mutable
import scala.concurrent.{Future, ExecutionContext}
import scala.util.{Try, Success, Failure}

// Constants
object Constants {
  val ApiVersion: String = "v1.0"
  val MaxUsers: Int = 1000
  val TimeoutSeconds: Int = 30
}

// User role enum (sealed trait + case objects)
sealed trait UserRole {
  def isPrivileged: Boolean = this match {
    case UserRole.Admin => true
    case _ => false
  }
}

object UserRole {
  case object Guest extends UserRole
  case object User extends UserRole
  case object Admin extends UserRole

  def fromString(s: String): Option[UserRole] = s.toLowerCase match {
    case "guest" => Some(Guest)
    case "user" => Some(User)
    case "admin" => Some(Admin)
    case _ => None
  }
}

// User case class (immutable by default)
case class User(
    id: Option[Int] = None,
    name: String,
    email: String,
    age: Int,
    role: UserRole = UserRole.User,
    createdAt: LocalDateTime = LocalDateTime.now()
) {
  def isAdult: Boolean = age >= 18
  def isAdmin: Boolean = role == UserRole.Admin

  def toDisplayString: String =
    s"User(id=${id.getOrElse(0)}, name='$name', age=$age, role=$role)"
}

// Custom error type
sealed trait UserError extends Exception {
  def message: String
}

object UserError {
  case class InvalidAge(age: Int) extends UserError {
    def message: String = s"Invalid age: $age"
  }

  case class InvalidEmail(email: String) extends UserError {
    def message: String = s"Invalid email: $email"
  }

  case class UserNotFound(id: Int) extends UserError {
    def message: String = s"User not found: $id"
  }

  case object RepositoryFull extends UserError {
    def message: String = "Repository is full"
  }
}

// Result type alias
type UserResult[T] = Either[UserError, T]

// Repository trait
trait Repository[T] {
  def find(id: Int): Option[T]
  def findAll(): List[T]
  def save(entity: T): UserResult[T]
  def delete(id: Int): UserResult[Unit]
}

// User repository implementation
class UserRepository extends Repository[User] {
  private val users = mutable.Map[Int, User]()
  private var nextId = 1

  def find(id: Int): Option[User] = users.get(id)

  def findAll(): List[User] = users.values.toList

  def save(entity: User): UserResult[User] = {
    if (users.size >= Constants.MaxUsers) {
      Left(UserError.RepositoryFull)
    } else {
      val id = nextId
      val user = entity.copy(id = Some(id))
      users(id) = user
      nextId += 1
      Right(user)
    }
  }

  def delete(id: Int): UserResult[Unit] = {
    users.remove(id) match {
      case Some(_) => Right(())
      case None => Left(UserError.UserNotFound(id))
    }
  }

  def findByEmail(email: String): Option[User] =
    users.values.find(_.email == email)

  def findByRole(role: UserRole): List[User] =
    users.values.filter(_.role == role).toList

  def count: Int = users.size
}

// User service with business logic
class UserService(repository: Repository[User]) {

  def createUser(
      name: String,
      email: String,
      age: Int,
      role: UserRole = UserRole.User
  ): UserResult[User] = {
    for {
      _ <- validateAge(age)
      _ <- validateEmail(email)
      user = User(name = name, email = email, age = age, role = role)
      saved <- repository.save(user)
    } yield saved
  }

  def getAdultUsers(): List[User] =
    repository.findAll().filter(_.isAdult)

  def getUsersByRole(role: UserRole): List[User] =
    repository.findAll().filter(_.role == role)

  def getAverageAge(): Double = {
    val users = repository.findAll()
    if (users.isEmpty) 0.0
    else users.map(_.age).sum.toDouble / users.length
  }

  def groupByRole(): Map[UserRole, List[User]] =
    repository.findAll().groupBy(_.role)

  private def validateAge(age: Int): UserResult[Unit] = {
    if (age >= 0 && age <= 150) Right(())
    else Left(UserError.InvalidAge(age))
  }

  private def validateEmail(email: String): UserResult[Unit] = {
    if (email.contains("@")) Right(())
    else Left(UserError.InvalidEmail(email))
  }
}

// Extension methods using implicit class
implicit class UserOps(user: User) {
  def getDisplayName: String = s"${user.name} (${user.email})"

  def isEligibleForDiscount: Boolean = user.age <= 18 || user.age >= 65
}

// Higher-order functions
object UserOperations {
  def processUsers(users: List[User])(predicate: User => Boolean): List[User] =
    users.filter(predicate)

  def transformUsers[T](users: List[User])(transform: User => T): List[T] =
    users.map(transform)

  def foldUsers[T](users: List[User], initial: T)(combine: (T, User) => T): T =
    users.foldLeft(initial)(combine)
}

// Collection operations
object CollectionDemo {
  def demonstrateCollections(): Unit = {
    val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    // Filter
    val evens = numbers.filter(_ % 2 == 0)
    println(s"Evens: $evens")

    // Map
    val doubled = numbers.map(_ * 2)
    println(s"Doubled: $doubled")

    // Reduce
    val sum = numbers.reduce(_ + _)
    println(s"Sum: $sum")

    // Fold
    val product = numbers.fold(1)(_ * _)
    println(s"Product: $product")

    // Chain operations
    val result = numbers
      .filter(_ % 2 == 0)
      .map(_ * 2)
      .sum
    println(s"Chained result: $result")

    // For-comprehension
    val pairs = for {
      x <- List(1, 2, 3)
      y <- List("a", "b")
    } yield (x, y)
    println(s"Pairs: $pairs")
  }
}

// Option and Either handling
object OptionEitherDemo {
  def demonstrateOptionEither(): Unit = {
    // Option
    val someValue: Option[Int] = Some(42)
    val noneValue: Option[Int] = None

    someValue match {
      case Some(v) => println(s"Got value: $v")
      case None => println("No value")
    }

    // getOrElse
    val value = noneValue.getOrElse(0)
    println(s"Value with default: $value")

    // map and flatMap
    val doubled = someValue.map(_ * 2)
    println(s"Doubled: $doubled")

    // Either
    val right: Either[String, Int] = Right(42)
    val left: Either[String, Int] = Left("error")

    right match {
      case Right(v) => println(s"Success: $v")
      case Left(e) => println(s"Error: $e")
    }

    // For-comprehension with Either
    val result = for {
      x <- Right(2): Either[String, Int]
      y <- Right(3): Either[String, Int]
    } yield x + y

    println(s"Result: $result")
  }
}

// Pattern matching examples
object PatternMatchingDemo {
  def getUserType(user: User): String = user match {
    case User(_, _, _, _, UserRole.Admin, _) => "Administrator"
    case User(_, _, _, age, _, _) if age >= 18 => "Adult User"
    case User(_, _, _, age, _, _) if age < 13 => "Child"
    case _ => "Minor"
  }

  def processResult(result: UserResult[User]): Unit = result match {
    case Right(user) => println(s"Success: $user")
    case Left(error) => println(s"Error: ${error.message}")
  }

  def demonstratePatternMatching(): Unit = {
    val number = 7

    number match {
      case 1 => println("One")
      case n if List(2, 3, 5, 7).contains(n) => println("Prime")
      case n if List(4, 6, 8, 9, 10).contains(n) => println("Composite")
      case _ => println("Other")
    }

    // Destructuring
    val tuple = (1, "hello", 3.14)
    val (first, second, third) = tuple
    println(s"Destructured: $first, $second, $third")
  }
}

// Future and async operations
object AsyncDemo {
  implicit val ec: ExecutionContext = ExecutionContext.global

  def fetchUserData(userId: Int): Future[User] = Future {
    Thread.sleep(1000)
    User(id = Some(userId), name = "Async User", email = "async@example.com", age = 30)
  }

  def demonstrateAsync(): Unit = {
    val futureUser = fetchUserData(1)

    futureUser.onComplete {
      case Success(user) => println(s"Fetched user: $user")
      case Failure(exception) => println(s"Failed: ${exception.getMessage}")
    }

    // For-comprehension with futures
    val combined = for {
      user1 <- fetchUserData(1)
      user2 <- fetchUserData(2)
    } yield List(user1, user2)
  }
}

// Trait composition
trait Timestampable {
  val createdAt: LocalDateTime
  val updatedAt: LocalDateTime = LocalDateTime.now()

  def age(): Long = {
    import java.time.temporal.ChronoUnit
    ChronoUnit.DAYS.between(createdAt, LocalDateTime.now())
  }
}

case class Post(
    title: String,
    content: String,
    author: User,
    createdAt: LocalDateTime = LocalDateTime.now()
) extends Timestampable {
  def summary(length: Int = 100): String =
    if (content.length > length) s"${content.take(length)}..."
    else content
}

// Main application
object UserManagementApp extends App {
  println("Scala User Management System")
  println(s"API Version: ${Constants.ApiVersion}")

  // Create repository and service
  val repo = new UserRepository()
  val service = new UserService(repo)

  // Create users
  val aliceResult = service.createUser(
    "Alice Johnson",
    "alice@example.com",
    28,
    UserRole.Admin
  )

  val bobResult = service.createUser(
    "Bob Smith",
    "bob@example.com",
    17
  )

  val charlieResult = service.createUser(
    "Charlie Brown",
    "charlie@example.com",
    45
  )

  // Pattern match on result
  aliceResult match {
    case Right(user) => println(s"\nCreated: $user")
    case Left(error) => println(s"Error: ${error.message}")
  }

  // Get adult users
  val adults = service.getAdultUsers()
  println(s"\nAdult users: ${adults.length}")
  adults.foreach { user =>
    println(s"  ${user.name} (${user.age})")
  }

  // Average age
  val avgAge = service.getAverageAge()
  println(f"\nAverage age: $avgAge%.2f")

  // Group by role
  val grouped = service.groupByRole()
  println("\nUsers by role:")
  grouped.foreach { case (role, users) =>
    println(s"  $role: ${users.length}")
  }

  // Extension method usage
  aliceResult match {
    case Right(alice) =>
      println(s"\nDisplay name: ${alice.getDisplayName}")
      println(s"Eligible for discount: ${alice.isEligibleForDiscount}")
      println(s"User type: ${PatternMatchingDemo.getUserType(alice)}")
    case _ =>
  }

  // Demonstrations
  println("\nCollection operations:")
  CollectionDemo.demonstrateCollections()

  println("\nOption and Either:")
  OptionEitherDemo.demonstrateOptionEither()

  println("\nPattern matching:")
  PatternMatchingDemo.demonstratePatternMatching()

  // Higher-order functions
  val adultNames = UserOperations.transformUsers(adults)(_.name).sorted
  println(s"\nAdult names: $adultNames")

  // Create a post
  aliceResult.foreach { alice =>
    val post = Post(
      title = "Welcome to Scala",
      content = "Scala is a statically-typed programming language that combines object-oriented and functional programming.",
      author = alice
    )
    println(s"\nPost: ${post.title}")
    println(s"Summary: ${post.summary(50)}")
    println(s"Created at: ${post.createdAt}")
  }

  // Try/Success/Failure
  val result = Try {
    10 / 2
  }

  result match {
    case Success(value) => println(s"\nDivision result: $value")
    case Failure(exception) => println(s"Error: ${exception.getMessage}")
  }
}
