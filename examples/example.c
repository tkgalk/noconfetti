// C Example - Systems Programming
// Testing: comments, strings, numbers, keywords, structs, pointers

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>

// Constants and macros
#define MAX_USERS 100
#define MAX_NAME_LEN 50
#define MAX_EMAIL_LEN 100
#define API_VERSION "v1.0"

// Type definitions
typedef struct User {
    int id;
    char name[MAX_NAME_LEN];
    char email[MAX_EMAIL_LEN];
    int age;
    time_t created_at;
} User;

typedef struct UserRepository {
    User* users[MAX_USERS];
    int count;
    int next_id;
} UserRepository;

// Function prototypes
User* user_create(const char* name, const char* email, int age);
void user_destroy(User* user);
bool user_is_adult(const User* user);
void user_print(const User* user);

UserRepository* repository_create(void);
void repository_destroy(UserRepository* repo);
bool repository_add(UserRepository* repo, User* user);
User* repository_find_by_id(const UserRepository* repo, int id);
User** repository_find_all(const UserRepository* repo, int* count);
bool repository_remove(UserRepository* repo, int id);

// User functions implementation
User* user_create(const char* name, const char* email, int age) {
    if (name == NULL || email == NULL) {
        fprintf(stderr, "Error: name and email cannot be NULL\n");
        return NULL;
    }

    if (age < 0 || age > 150) {
        fprintf(stderr, "Error: invalid age %d\n", age);
        return NULL;
    }

    User* user = (User*)malloc(sizeof(User));
    if (user == NULL) {
        fprintf(stderr, "Error: memory allocation failed\n");
        return NULL;
    }

    user->id = 0;
    strncpy(user->name, name, MAX_NAME_LEN - 1);
    user->name[MAX_NAME_LEN - 1] = '\0';
    strncpy(user->email, email, MAX_EMAIL_LEN - 1);
    user->email[MAX_EMAIL_LEN - 1] = '\0';
    user->age = age;
    user->created_at = time(NULL);

    return user;
}

void user_destroy(User* user) {
    if (user != NULL) {
        free(user);
    }
}

bool user_is_adult(const User* user) {
    return user != NULL && user->age >= 18;
}

void user_print(const User* user) {
    if (user == NULL) {
        printf("User is NULL\n");
        return;
    }

    printf("User{id=%d, name=\"%s\", email=\"%s\", age=%d}\n",
           user->id, user->name, user->email, user->age);
}

// Repository functions implementation
UserRepository* repository_create(void) {
    UserRepository* repo = (UserRepository*)malloc(sizeof(UserRepository));
    if (repo == NULL) {
        return NULL;
    }

    repo->count = 0;
    repo->next_id = 1;
    for (int i = 0; i < MAX_USERS; i++) {
        repo->users[i] = NULL;
    }

    return repo;
}

void repository_destroy(UserRepository* repo) {
    if (repo == NULL) {
        return;
    }

    for (int i = 0; i < repo->count; i++) {
        if (repo->users[i] != NULL) {
            user_destroy(repo->users[i]);
        }
    }

    free(repo);
}

bool repository_add(UserRepository* repo, User* user) {
    if (repo == NULL || user == NULL) {
        return false;
    }

    if (repo->count >= MAX_USERS) {
        fprintf(stderr, "Error: repository is full\n");
        return false;
    }

    user->id = repo->next_id++;
    repo->users[repo->count++] = user;
    return true;
}

User* repository_find_by_id(const UserRepository* repo, int id) {
    if (repo == NULL) {
        return NULL;
    }

    for (int i = 0; i < repo->count; i++) {
        if (repo->users[i]->id == id) {
            return repo->users[i];
        }
    }

    return NULL;
}

User** repository_find_all(const UserRepository* repo, int* count) {
    if (repo == NULL || count == NULL) {
        return NULL;
    }

    *count = repo->count;
    return (User**)repo->users;
}

bool repository_remove(UserRepository* repo, int id) {
    if (repo == NULL) {
        return false;
    }

    for (int i = 0; i < repo->count; i++) {
        if (repo->users[i]->id == id) {
            user_destroy(repo->users[i]);

            // Shift remaining users
            for (int j = i; j < repo->count - 1; j++) {
                repo->users[j] = repo->users[j + 1];
            }

            repo->users[repo->count - 1] = NULL;
            repo->count--;
            return true;
        }
    }

    return false;
}

// Helper functions
void print_adults(const UserRepository* repo) {
    printf("\nAdult users:\n");
    for (int i = 0; i < repo->count; i++) {
        if (user_is_adult(repo->users[i])) {
            printf("  ");
            user_print(repo->users[i]);
        }
    }
}

double calculate_average_age(const UserRepository* repo) {
    if (repo == NULL || repo->count == 0) {
        return 0.0;
    }

    int total_age = 0;
    for (int i = 0; i < repo->count; i++) {
        total_age += repo->users[i]->age;
    }

    return (double)total_age / repo->count;
}

// Array operations
void demonstrate_arrays(void) {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);

    printf("\nArray demonstration:\n");
    printf("Numbers: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", numbers[i]);
    }
    printf("\n");

    // Sum
    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += numbers[i];
    }
    printf("Sum: %d\n", sum);

    // Find max
    int max = numbers[0];
    for (int i = 1; i < size; i++) {
        if (numbers[i] > max) {
            max = numbers[i];
        }
    }
    printf("Max: %d\n", max);
}

// String operations
void demonstrate_strings(void) {
    char str1[50] = "Hello";
    char str2[50] = "World";
    char result[100];

    printf("\nString demonstration:\n");

    // Concatenation
    strcpy(result, str1);
    strcat(result, ", ");
    strcat(result, str2);
    strcat(result, "!");
    printf("Concatenated: %s\n", result);

    // Length
    printf("Length: %zu\n", strlen(result));

    // Comparison
    int cmp = strcmp(str1, str2);
    printf("Comparison: %d\n", cmp);

    // String formatting
    char formatted[100];
    snprintf(formatted, sizeof(formatted),
             "Formatted: %s %d %.2f", "test", 42, 3.14159);
    printf("%s\n", formatted);
}

// Pointer demonstration
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void demonstrate_pointers(void) {
    int x = 10;
    int y = 20;
    int* ptr = &x;

    printf("\nPointer demonstration:\n");
    printf("Before swap: x=%d, y=%d\n", x, y);
    swap(&x, &y);
    printf("After swap: x=%d, y=%d\n", x, y);
    printf("Pointer value: %d\n", *ptr);
}

// Main function
int main(int argc, char* argv[]) {
    printf("C User Management System\n");
    printf("API Version: %s\n", API_VERSION);

    // Create repository
    UserRepository* repo = repository_create();
    if (repo == NULL) {
        fprintf(stderr, "Failed to create repository\n");
        return 1;
    }

    // Create users
    User* alice = user_create("Alice Johnson", "alice@example.com", 28);
    User* bob = user_create("Bob Smith", "bob@example.com", 17);
    User* charlie = user_create("Charlie Brown", "charlie@example.com", 45);

    // Add to repository
    if (alice) repository_add(repo, alice);
    if (bob) repository_add(repo, bob);
    if (charlie) repository_add(repo, charlie);

    // Print all users
    printf("\nAll users:\n");
    int count;
    User** users = repository_find_all(repo, &count);
    for (int i = 0; i < count; i++) {
        user_print(users[i]);
    }

    // Print adults
    print_adults(repo);

    // Calculate average age
    double avg_age = calculate_average_age(repo);
    printf("\nAverage age: %.2f\n", avg_age);

    // Find by ID
    User* found = repository_find_by_id(repo, 1);
    if (found) {
        printf("\nFound user with ID 1:\n");
        user_print(found);
    }

    // Demonstrations
    demonstrate_arrays();
    demonstrate_strings();
    demonstrate_pointers();

    // Cleanup
    repository_destroy(repo);

    return 0;
}
