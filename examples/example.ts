// TypeScript Example - React Component with Hooks and Context
// Testing: types, interfaces, generics, decorators, JSX

import React, { useState, useEffect, useContext, createContext } from 'react';

// Type definitions and interfaces
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
  role: UserRole;
  createdAt: Date;
}

type UserRole = 'admin' | 'user' | 'guest';

interface ApiResponse<T> {
  data: T;
  status: number;
  message?: string;
}

interface UserRepository {
  findById(id: number): Promise<User | null>;
  findAll(): Promise<User[]>;
  save(user: User): Promise<User>;
  delete(id: number): Promise<boolean>;
}

// Generic utility types
type Nullable<T> = T | null;
type Optional<T> = T | undefined;
type ReadOnly<T> = { readonly [K in keyof T]: T[K] };

// Constants
const API_ENDPOINT = 'https://api.example.com';
const MAX_RETRIES = 3;
const TIMEOUT_MS = 5000;

// Class with decorators (conceptual)
class UserService {
  private users: User[] = [];

  async fetchUser(id: number): Promise<Nullable<User>> {
    try {
      const response = await fetch(`${API_ENDPOINT}/users/${id}`);
      const data: ApiResponse<User> = await response.json();
      return data.data;
    } catch (error) {
      console.error('Failed to fetch user:', error);
      return null;
    }
  }

  isAdult(user: User): boolean {
    return user.age >= 18;
  }

  filterByRole(role: UserRole): User[] {
    return this.users.filter(u => u.role === role);
  }
}

// React Context for user management
interface UserContextType {
  users: User[];
  loading: boolean;
  error: string | null;
  addUser: (user: User) => void;
  removeUser: (id: number) => void;
}

const UserContext = createContext<UserContextType | undefined>(undefined);

// Custom hook
function useUsers() {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUsers must be used within UserProvider');
  }
  return context;
}

// React component with TypeScript
interface UserListProps {
  filter?: UserRole;
  onUserClick?: (user: User) => void;
}

const UserList: React.FC<UserListProps> = ({ filter, onUserClick }) => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedId, setSelectedId] = useState<number | null>(null);

  useEffect(() => {
    const service = new UserService();
    // Simulated async data fetch
    const loadUsers = async () => {
      setLoading(true);
      try {
        // Mock data
        const mockUsers: User[] = [
          {
            id: 1,
            name: 'Alice Johnson',
            email: 'alice@example.com',
            age: 28,
            role: 'admin',
            createdAt: new Date(),
          },
          {
            id: 2,
            name: 'Bob Smith',
            email: 'bob@example.com',
            age: 17,
            role: 'user',
            createdAt: new Date(),
          },
        ];
        setUsers(mockUsers);
      } finally {
        setLoading(false);
      }
    };

    loadUsers();
  }, [filter]);

  const handleClick = (user: User) => {
    setSelectedId(user.id);
    onUserClick?.(user);
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  const filteredUsers = filter
    ? users.filter(u => u.role === filter)
    : users;

  return (
    <div className="user-list">
      <h2>Users ({filteredUsers.length})</h2>
      <ul>
        {filteredUsers.map(user => (
          <li
            key={user.id}
            onClick={() => handleClick(user)}
            className={selectedId === user.id ? 'selected' : ''}
          >
            <span className="name">{user.name}</span>
            <span className="email">{user.email}</span>
            <span className="age">Age: {user.age}</span>
            <span className="role">{user.role}</span>
          </li>
        ))}
      </ul>
    </div>
  );
};

// Generic helper functions
function groupBy<T, K extends keyof T>(array: T[], key: K): Map<T[K], T[]> {
  return array.reduce((map, item) => {
    const keyValue = item[key];
    const group = map.get(keyValue) || [];
    group.push(item);
    map.set(keyValue, group);
    return map;
  }, new Map<T[K], T[]>());
}

function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout;
  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
}

// Type guards
function isUser(obj: any): obj is User {
  return (
    typeof obj === 'object' &&
    'id' in obj &&
    'name' in obj &&
    'email' in obj &&
    'age' in obj
  );
}

// Utility functions with generics
const mapUsers = (users: User[]): string[] => users.map(u => u.name);
const filterAdults = (users: User[]): User[] => users.filter(u => u.age >= 18);
const sortByAge = (users: User[]): User[] =>
  [...users].sort((a, b) => a.age - b.age);

export { UserList, useUsers, UserService, groupBy, debounce };
export type { User, UserRole, ApiResponse, UserRepository };
