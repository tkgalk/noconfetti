// C# Example - ASP.NET Core Web API
// Testing: comments, strings, numbers, keywords, classes, LINQ, async/await

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace Example.Api
{
    /// <summary>
    /// User entity with properties and validation
    /// </summary>
    public class User
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public int Age { get; set; }
        public DateTime CreatedAt { get; set; }
        public UserRole Role { get; set; }

        // Computed property
        public bool IsAdult => Age >= 18;

        public User(string name, string email, int age)
        {
            Name = name;
            Email = email;
            Age = age;
            CreatedAt = DateTime.UtcNow;
            Role = UserRole.User;
        }

        public override string ToString()
        {
            return $"User {{ Id = {Id}, Name = \"{Name}\", Age = {Age} }}";
        }
    }

    /// <summary>
    /// User role enumeration
    /// </summary>
    public enum UserRole
    {
        Guest = 0,
        User = 1,
        Admin = 2,
        SuperAdmin = 3
    }

    /// <summary>
    /// Generic repository interface
    /// </summary>
    public interface IRepository<T> where T : class
    {
        Task<T> GetByIdAsync(int id);
        Task<IEnumerable<T>> GetAllAsync();
        Task<T> AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(int id);
    }

    /// <summary>
    /// User repository implementation
    /// </summary>
    public class UserRepository : IRepository<User>
    {
        private readonly List<User> _users = new();
        private int _nextId = 1;

        public async Task<User> GetByIdAsync(int id)
        {
            await Task.Delay(10); // Simulate async operation
            return _users.FirstOrDefault(u => u.Id == id);
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            await Task.Delay(10);
            return _users.ToList();
        }

        public async Task<User> AddAsync(User user)
        {
            user.Id = _nextId++;
            _users.Add(user);
            await Task.Delay(10);
            return user;
        }

        public async Task UpdateAsync(User user)
        {
            var existing = await GetByIdAsync(user.Id);
            if (existing != null)
            {
                existing.Name = user.Name;
                existing.Email = user.Email;
                existing.Age = user.Age;
            }
        }

        public async Task DeleteAsync(int id)
        {
            var user = await GetByIdAsync(id);
            if (user != null)
            {
                _users.Remove(user);
            }
        }

        // LINQ queries
        public IEnumerable<User> FindByRole(UserRole role)
        {
            return _users.Where(u => u.Role == role);
        }

        public IEnumerable<User> FindAdults()
        {
            return _users.Where(u => u.IsAdult);
        }
    }

    /// <summary>
    /// User service with business logic
    /// </summary>
    public class UserService
    {
        private readonly IRepository<User> _repository;
        private const int MinAge = 0;
        private const int MaxAge = 150;

        public UserService(IRepository<User> repository)
        {
            _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        }

        public async Task<User> CreateUserAsync(string name, string email, int age)
        {
            ValidateAge(age);
            var user = new User(name, email, age);
            return await _repository.AddAsync(user);
        }

        public async Task<IEnumerable<User>> GetAdultUsersAsync()
        {
            var users = await _repository.GetAllAsync();
            return users.Where(u => u.IsAdult);
        }

        public async Task<Dictionary<UserRole, int>> GetUserCountByRoleAsync()
        {
            var users = await _repository.GetAllAsync();
            return users.GroupBy(u => u.Role)
                       .ToDictionary(g => g.Key, g => g.Count());
        }

        private void ValidateAge(int age)
        {
            if (age < MinAge || age > MaxAge)
            {
                throw new ArgumentException($"Age must be between {MinAge} and {MaxAge}");
            }
        }
    }

    /// <summary>
    /// API Controller for user management
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly UserService _userService;

        public UsersController(UserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetAll()
        {
            var users = await _userService.GetAdultUsersAsync();
            return Ok(users);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetById(int id)
        {
            var user = await _userService.CreateUserAsync("Test", "test@example.com", 25);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }

        [HttpPost]
        public async Task<ActionResult<User>> Create([FromBody] CreateUserRequest request)
        {
            try
            {
                var user = await _userService.CreateUserAsync(
                    request.Name,
                    request.Email,
                    request.Age
                );
                return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }

    public record CreateUserRequest(string Name, string Email, int Age);

    /// <summary>
    /// Extension methods
    /// </summary>
    public static class UserExtensions
    {
        public static bool IsEligibleForDiscount(this User user)
        {
            return user.Age >= 65 || user.Age <= 18;
        }

        public static string GetDisplayName(this User user)
        {
            return $"{user.Name} ({user.Email})";
        }
    }

    // LINQ examples
    public class QueryExamples
    {
        public void DemonstrateQueries(List<User> users)
        {
            // Method syntax
            var adults = users.Where(u => u.Age >= 18)
                             .OrderBy(u => u.Name)
                             .Select(u => u.Name)
                             .ToList();

            // Query syntax
            var adminNames = from user in users
                            where user.Role == UserRole.Admin
                            orderby user.Name
                            select user.Name;

            // Aggregations
            var averageAge = users.Average(u => u.Age);
            var oldestUser = users.MaxBy(u => u.Age);
            var totalUsers = users.Count();

            // Grouping
            var groupedByRole = users.GroupBy(u => u.Role)
                                    .Select(g => new { Role = g.Key, Count = g.Count() });
        }
    }
}
