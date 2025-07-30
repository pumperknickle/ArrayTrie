# ArrayTrie

A Swift implementation of a trie (prefix tree) data structure that uses arrays of strings as keys instead of individual characters.

## Overview

`ArrayTrie` is a specialized trie data structure designed for working with paths composed of string segments. Unlike traditional tries that typically use single characters as keys, this implementation uses whole strings for each segment of the path, making it ideal for:

- File path management
- URL routing
- Hierarchical data organization
- Menu structures
- Any data that naturally forms a tree-like structure with string segments

## Features

- Fast lookups, insertions, and deletions
- Efficient memory usage through prefix sharing
- Support for traversing subtries
- Immutable operations with functional-style return values
- Generic value type to store any kind of data
- Comprehensive test coverage

## Requirements

- Swift 5.0+
- Swift Collections package (for TreeDictionary)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file's dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ArrayTrie.git", from: "1.0.0"),
]
```

Then include it in your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ArrayTrie", package: "ArrayTrie"),
        ]),
]
```

## Usage

### Basic Operations

```swift
import ArrayTrie

// Create an empty trie
var trie = ArrayTrie<String>()

// Store values at specific paths
trie.set(["users", "john"], value: "John Doe")
trie.set(["users", "jane"], value: "Jane Smith")
trie.set(["admins", "bob"], value: "Bob Admin")

// Retrieve values
let john = trie.get(["users", "john"]) // Returns "John Doe"
let jane = trie.get(["users", "jane"]) // Returns "Jane Smith"
let unknown = trie.get(["users", "unknown"]) // Returns nil

// Check if the trie is empty
let isEmpty = trie.isEmpty() // Returns false
```

### Deleting Values

The `deleting` method creates a new trie with the specified path removed:

```swift
let newTrie = trie.deleting(path: ["users", "john"])

// Original trie is unchanged
let originalJohn = trie.get(["users", "john"]) // Still returns "John Doe"

// New trie has the path deleted
let newJohn = newTrie.get(["users", "john"]) // Returns nil
let newJane = newTrie.get(["users", "jane"]) // Still returns "Jane Smith"
```

### Traversing

You can traverse to a specific path to work with a subtrie:

```swift
// Set up nested paths
trie.set(["users", "john", "profile"], value: "John's Profile")
trie.set(["users", "john", "settings"], value: "John's Settings")

// Traverse to a subtrie
if let johnTrie = trie.traverse(["users", "john"]) {
    let profile = johnTrie.get(["profile"]) // Returns "John's Profile"
    let settings = johnTrie.get(["settings"]) // Returns "John's Settings"
}
```

### Working with Different Value Types

`ArrayTrie` supports any value type:

```swift
// String values
var stringTrie = ArrayTrie<String>()
stringTrie.set(["config", "name"], value: "My App")

// Integer values
var intTrie = ArrayTrie<Int>()
intTrie.set(["stats", "users"], value: 42)
intTrie.set(["stats", "admins"], value: 7)

// Boolean values
var boolTrie = ArrayTrie<Bool>()
boolTrie.set(["features", "darkMode"], value: true)
boolTrie.set(["features", "notifications"], value: false)

// Custom types
struct User {
    let name: String
    let age: Int
}

var userTrie = ArrayTrie<User>()
userTrie.set(["users", "john"], value: User(name: "John", age: 30))
```

### Nested Tries

You can even nest tries within tries:

```swift
var rootTrie = ArrayTrie<ArrayTrie<String>>()

var configTrie = ArrayTrie<String>()
configTrie.set(["theme"], value: "Dark")
configTrie.set(["language"], value: "English")

rootTrie.set(["config"], value: configTrie)

// Later, retrieve and use the nested trie
if let retrievedConfig = rootTrie.get(["config"]) {
    let theme = retrievedConfig.get(["theme"]) // Returns "Dark"
}
```

## How It Works

`ArrayTrie` consists of two key components:

1. `ArrayTrie<Value>`: The main trie structure that stores children in a `TreeDictionary`.
2. `ArrayTrieNode<Value>`: Individual nodes within the trie that store:
   - A prefix path
   - An optional value
   - Child nodes

The implementation uses path compression techniques to optimize memory usage by sharing common prefixes.

## Performance

Operations | Time Complexity
-----------|----------------
Get        | O(k) where k is the path length
Set        | O(k) where k is the path length
Delete     | O(k) where k is the path length
Traverse   | O(k) where k is the path length

## Use Cases

### File System Paths

```swift
var fileSystem = ArrayTrie<FileData>()
fileSystem.set(["users", "john", "documents", "resume.pdf"], value: pdfData)
fileSystem.set(["users", "john", "photos", "vacation.jpg"], value: imageData)
```

### URL Routing

```swift
var router = ArrayTrie<RouteHandler>()
router.set(["api", "users"], value: listUsersHandler)
router.set(["api", "users", ":id"], value: getUserHandler)
router.set(["api", "login"], value: loginHandler)
```

### Configuration Management

```swift
var config = ArrayTrie<Any>()
config.set(["app", "name"], value: "My App")
config.set(["app", "version"], value: "1.0.0")
config.set(["database", "host"], value: "localhost")
config.set(["database", "port"], value: 5432)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
