#!/usr/bin/env python3
"""
Python Example - REST API with Flask and SQLAlchemy
Testing: comments, strings, numbers, keywords, functions, types, decorators
"""

from typing import List, Optional, Dict, Any
from dataclasses import dataclass
from datetime import datetime
import logging
import json

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constants
API_VERSION = "v1"
MAX_CONNECTIONS = 100
TIMEOUT = 30.0
DEBUG = True


@dataclass
class User:
    """User model with automatic initialization"""
    id: int
    name: str
    email: str
    age: int
    created_at: datetime = datetime.now()

    def is_adult(self) -> bool:
        """Check if user is 18 or older"""
        return self.age >= 18

    def to_dict(self) -> Dict[str, Any]:
        """Convert user to dictionary representation"""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'age': self.age,
            'adult': self.is_adult(),
            'created_at': self.created_at.isoformat()
        }


class UserRepository:
    """Repository pattern for user data access"""

    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self.users: List[User] = []

    def find_by_id(self, user_id: int) -> Optional[User]:
        """Find user by ID"""
        for user in self.users:
            if user.id == user_id:
                return user
        return None

    def find_by_email(self, email: str) -> Optional[User]:
        """Find user by email address"""
        return next((u for u in self.users if u.email == email), None)

    def save(self, user: User) -> User:
        """Save user to repository"""
        if user not in self.users:
            self.users.append(user)
            logger.info(f"Saved user: {user.name}")
        return user

    def delete(self, use/var/folders/jx/jjcb6twx7zv391tp_q72_r840000gn/T/TemporaryItems/NSIRD_screencaptureui_WaLkpL/Screenshot\ 2025-11-04\ at\ 14.48.00.png r_id: int) -> bool:
        """Delete user by ID"""
        user = self.find_by_id(user_id)
        if user:
            self.users.remove(user)
            return True
        return False


def process_batch(items: List[Any], batch_size: int = 10) -> List[List[Any]]:
    """Split items into batches"""
    batches = []
    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]
        batches.append(batch)
    return batches


# List comprehensions and generators
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
squares = [n ** 2 for n in numbers]
evens = [n for n in numbers if n % 2 == 0]
doubled_evens = [n * 2 for n in numbers if n % 2 == 0]

# Generator expression
sum_of_squares = sum(n ** 2 for n in range(100))

# Dictionary comprehension
user_map = {u.id: u.name for u in [
    User(1, "Alice", "alice@example.com", 25),
    User(2, "Bob", "bob@example.com", 30),
]}

# String formatting
name = "World"
greeting = f"Hello, {name}!"
multiline = """
This is a multiline string
with multiple lines
and {API_VERSION} interpolation
"""

# Context manager
class DatabaseConnection:
    def __enter__(self):
        logger.info("Opening database connection")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        logger.info("Closing database connection")
        return False

    def execute(self, query: str) -> List[Dict]:
        return []


# Using context manager
with DatabaseConnection() as db:
    results = db.execute("SELECT * FROM users WHERE age > 18")


# Async/await example
async def fetch_data(url: str) -> Optional[Dict]:
    """Fetch data from URL asynchronously"""
    try:
        # Simulated async operation
        await asyncio.sleep(1)
        return {"status": "ok", "data": []}
    except Exception as e:
        logger.error(f"Error fetching data: {e}")
        return None


if __name__ == "__main__":
    # Create repository and add users
    repo = UserRepository("postgresql://localhost/mydb")

    alice = User(1, "Alice Johnson", "alice@example.com", 28)
    bob = User(2, "Bob Smith", "bob@example.com", 17)

    repo.save(alice)
    repo.save(bob)

    # Query users
    found = repo.find_by_email("alice@example.com")
    if found:
        print(f"Found user: {found.name}, Adult: {found.is_adult()}")

    print(f"API Version: {API_VERSION}")
    print(f"Total users: {len(repo.users)}")
