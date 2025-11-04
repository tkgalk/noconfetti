// C++ Example - Modern C++17/20 with STL
// Testing: comments, strings, numbers, keywords, templates, lambdas

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <memory>
#include <algorithm>
#include <functional>
#include <optional>
#include <chrono>

using namespace std;

// Constants
constexpr int MAX_USERS = 1000;
constexpr double PI = 3.14159265359;
const string API_VERSION = "v1.0";

/**
 * User class with modern C++ features
 */
class User {
private:
    int id;
    string name;
    string email;
    int age;
    chrono::system_clock::time_point createdAt;

public:
    // Constructor with member initializer list
    User(int id, const string& name, const string& email, int age)
        : id(id), name(name), email(email), age(age),
          createdAt(chrono::system_clock::now()) {}

    // Getters
    int getId() const { return id; }
    const string& getName() const { return name; }
    const string& getEmail() const { return email; }
    int getAge() const { return age; }

    // Setters
    void setName(const string& newName) { name = newName; }
    void setEmail(const string& newEmail) { email = newEmail; }
    void setAge(int newAge) { age = newAge; }

    // Computed property
    bool isAdult() const {
        return age >= 18;
    }

    // Friend function for output
    friend ostream& operator<<(ostream& os, const User& user) {
        os << "User{id=" << user.id
           << ", name=\"" << user.name << "\""
           << ", age=" << user.age << "}";
        return os;
    }
};

/**
 * Generic repository template class
 */
template<typename T>
class Repository {
private:
    map<int, shared_ptr<T>> storage;
    int nextId = 1;

public:
    // Add item to repository
    shared_ptr<T> save(shared_ptr<T> item) {
        storage[nextId++] = item;
        return item;
    }

    // Find by ID
    optional<shared_ptr<T>> findById(int id) const {
        auto it = storage.find(id);
        if (it != storage.end()) {
            return it->second;
        }
        return nullopt;
    }

    // Get all items
    vector<shared_ptr<T>> findAll() const {
        vector<shared_ptr<T>> result;
        for (const auto& [id, item] : storage) {
            result.push_back(item);
        }
        return result;
    }

    // Remove by ID
    bool remove(int id) {
        return storage.erase(id) > 0;
    }

    // Get count
    size_t count() const {
        return storage.size();
    }
};

/**
 * User service with business logic
 */
class UserService {
private:
    Repository<User> repository;

public:
    shared_ptr<User> createUser(const string& name, const string& email, int age) {
        validateAge(age);
        auto user = make_shared<User>(0, name, email, age);
        return repository.save(user);
    }

    vector<shared_ptr<User>> getAdultUsers() {
        auto users = repository.findAll();
        vector<shared_ptr<User>> adults;

        copy_if(users.begin(), users.end(), back_inserter(adults),
                [](const auto& user) { return user->isAdult(); });

        return adults;
    }

    optional<shared_ptr<User>> findById(int id) {
        return repository.findById(id);
    }

private:
    void validateAge(int age) {
        if (age < 0 || age > 150) {
            throw invalid_argument("Age must be between 0 and 150");
        }
    }
};

// Lambda examples
auto isAdult = [](const User& user) { return user.getAge() >= 18; };
auto getAge = [](const User& user) { return user.getAge(); };

// Function template
template<typename T>
void printVector(const vector<T>& vec) {
    cout << "[";
    for (size_t i = 0; i < vec.size(); ++i) {
        cout << vec[i];
        if (i < vec.size() - 1) cout << ", ";
    }
    cout << "]" << endl;
}

// Template specialization
template<>
void printVector<string>(const vector<string>& vec) {
    cout << "[";
    for (size_t i = 0; i < vec.size(); ++i) {
        cout << "\"" << vec[i] << "\"";
        if (i < vec.size() - 1) cout << ", ";
    }
    cout << "]" << endl;
}

// Generic algorithms demonstration
void demonstrateAlgorithms() {
    vector<int> numbers = {5, 2, 8, 1, 9, 3, 7, 4, 6};

    // Sort
    sort(numbers.begin(), numbers.end());

    // Find
    auto it = find(numbers.begin(), numbers.end(), 5);
    if (it != numbers.end()) {
        cout << "Found 5 at position " << distance(numbers.begin(), it) << endl;
    }

    // Transform
    vector<int> doubled(numbers.size());
    transform(numbers.begin(), numbers.end(), doubled.begin(),
              [](int n) { return n * 2; });

    // Filter
    vector<int> evens;
    copy_if(numbers.begin(), numbers.end(), back_inserter(evens),
            [](int n) { return n % 2 == 0; });

    // Accumulate
    int sum = accumulate(numbers.begin(), numbers.end(), 0);
    cout << "Sum: " << sum << endl;
}

// Smart pointers example
class ResourceManager {
private:
    unique_ptr<vector<int>> data;
    shared_ptr<string> name;

public:
    ResourceManager(const string& n)
        : data(make_unique<vector<int>>()),
          name(make_shared<string>(n)) {
        cout << "ResourceManager created: " << *name << endl;
    }

    ~ResourceManager() {
        cout << "ResourceManager destroyed: " << *name << endl;
    }

    void addData(int value) {
        data->push_back(value);
    }

    size_t getDataSize() const {
        return data->size();
    }
};

// Main function
int main() {
    UserService service;

    // Create users
    auto alice = service.createUser("Alice Johnson", "alice@example.com", 28);
    auto bob = service.createUser("Bob Smith", "bob@example.com", 17);
    auto charlie = service.createUser("Charlie Brown", "charlie@example.com", 45);

    cout << "Created users:" << endl;
    cout << *alice << endl;
    cout << *bob << endl;
    cout << *charlie << endl;

    // Get adult users
    auto adults = service.getAdultUsers();
    cout << "\nAdult users: " << adults.size() << endl;

    // Lambda usage
    for (const auto& user : adults) {
        if (isAdult(*user)) {
            cout << "  " << user->getName() << " (age " << getAge(*user) << ")" << endl;
        }
    }

    // STL algorithm examples
    cout << "\nAlgorithm demonstrations:" << endl;
    demonstrateAlgorithms();

    // Smart pointer example
    {
        ResourceManager manager("TestManager");
        manager.addData(42);
        cout << "Data size: " << manager.getDataSize() << endl;
    } // manager destroyed here

    return 0;
}
