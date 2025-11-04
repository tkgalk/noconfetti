<?php
/**
 * PHP Example - Laravel-style Application
 * Testing: comments, strings, numbers, keywords, classes, traits
 */

declare(strict_types=1);

namespace App\Example;

use DateTime;
use Exception;

// Constants
const API_VERSION = 'v1';
const MAX_USERS = 1000;
const TIMEOUT = 30;

/**
 * User model class
 */
class User
{
    private int $id;
    private string $name;
    private string $email;
    private int $age;
    private DateTime $createdAt;
    private string $role;

    public function __construct(
        int $id,
        string $name,
        string $email,
        int $age,
        string $role = 'user'
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->email = $email;
        $this->age = $age;
        $this->role = $role;
        $this->createdAt = new DateTime();
    }

    // Getters
    public function getId(): int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getAge(): int
    {
        return $this->age;
    }

    public function getRole(): string
    {
        return $this->role;
    }

    // Business logic
    public function isAdult(): bool
    {
        return $this->age >= 18;
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'age' => $this->age,
            'role' => $this->role,
            'adult' => $this->isAdult(),
            'created_at' => $this->createdAt->format('Y-m-d H:i:s'),
        ];
    }

    public function __toString(): string
    {
        return sprintf(
            "User{id=%d, name='%s', email='%s', age=%d}",
            $this->id,
            $this->name,
            $this->email,
            $this->age
        );
    }
}

/**
 * Repository interface
 */
interface RepositoryInterface
{
    public function find(int $id): ?User;
    public function findAll(): array;
    public function save(User $user): User;
    public function delete(int $id): bool;
}

/**
 * User repository implementation
 */
class UserRepository implements RepositoryInterface
{
    private array $users = [];
    private int $nextId = 1;

    public function find(int $id): ?User
    {
        return $this->users[$id] ?? null;
    }

    public function findAll(): array
    {
        return array_values($this->users);
    }

    public function save(User $user): User
    {
        $this->users[$this->nextId] = $user;
        $this->nextId++;
        return $user;
    }

    public function delete(int $id): bool
    {
        if (isset($this->users[$id])) {
            unset($this->users[$id]);
            return true;
        }
        return false;
    }

    public function findByEmail(string $email): ?User
    {
        foreach ($this->users as $user) {
            if ($user->getEmail() === $email) {
                return $user;
            }
        }
        return null;
    }

    public function findByRole(string $role): array
    {
        return array_filter(
            $this->users,
            fn(User $user) => $user->getRole() === $role
        );
    }
}

/**
 * User service with business logic
 */
class UserService
{
    private RepositoryInterface $repository;

    public function __construct(RepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function createUser(
        string $name,
        string $email,
        int $age,
        string $role = 'user'
    ): User {
        $this->validateAge($age);
        $this->validateEmail($email);

        $user = new User(0, $name, $email, $age, $role);
        return $this->repository->save($user);
    }

    public function getAdultUsers(): array
    {
        $users = $this->repository->findAll();
        return array_filter($users, fn(User $u) => $u->isAdult());
    }

    public function getUsersByRole(string $role): array
    {
        return $this->repository->findByRole($role);
    }

    public function getAverageAge(): float
    {
        $users = $this->repository->findAll();
        if (empty($users)) {
            return 0.0;
        }

        $totalAge = array_reduce(
            $users,
            fn(int $sum, User $user) => $sum + $user->getAge(),
            0
        );

        return $totalAge / count($users);
    }

    private function validateAge(int $age): void
    {
        if ($age < 0 || $age > 150) {
            throw new Exception('Age must be between 0 and 150');
        }
    }

    private function validateEmail(string $email): void
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Invalid email address');
        }
    }
}

// Array functions and operations
function demonstrateArrays(): void
{
    $numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // Map
    $doubled = array_map(fn($n) => $n * 2, $numbers);

    // Filter
    $evens = array_filter($numbers, fn($n) => $n % 2 === 0);

    // Reduce
    $sum = array_reduce($numbers, fn($carry, $n) => $carry + $n, 0);

    // Array destructuring
    [$first, $second, ...$rest] = $numbers;

    // Associative arrays
    $config = [
        'host' => 'localhost',
        'port' => 3306,
        'database' => 'myapp',
        'username' => 'root',
    ];

    // Spread operator
    $extendedConfig = [...$config, 'charset' => 'utf8mb4'];

    echo "Sum: $sum\n";
    echo "First: $first, Second: $second\n";
}

// Trait example
trait Timestampable
{
    protected DateTime $createdAt;
    protected DateTime $updatedAt;

    public function touchTimestamps(): void
    {
        $now = new DateTime();
        if (!isset($this->createdAt)) {
            $this->createdAt = $now;
        }
        $this->updatedAt = $now;
    }

    public function getCreatedAt(): DateTime
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): DateTime
    {
        return $this->updatedAt;
    }
}

// Using trait
class Post
{
    use Timestampable;

    private string $title;
    private string $content;

    public function __construct(string $title, string $content)
    {
        $this->title = $title;
        $this->content = $content;
        $this->touchTimestamps();
    }
}

// Main execution
$repository = new UserRepository();
$service = new UserService($repository);

try {
    // Create users
    $alice = $service->createUser('Alice Johnson', 'alice@example.com', 28, 'admin');
    $bob = $service->createUser('Bob Smith', 'bob@example.com', 17);
    $charlie = $service->createUser('Charlie Brown', 'charlie@example.com', 45);

    echo "Created users:\n";
    echo $alice . "\n";
    echo $bob . "\n";
    echo $charlie . "\n";

    // Get adult users
    $adults = $service->getAdultUsers();
    echo "\nAdult users: " . count($adults) . "\n";

    // Average age
    $avgAge = $service->getAverageAge();
    echo "Average age: " . number_format($avgAge, 2) . "\n";

    // Get users by role
    $admins = $service->getUsersByRole('admin');
    echo "Admin users: " . count($admins) . "\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

// Demonstrate arrays
demonstrateArrays();
