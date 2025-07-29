import XCTest
import Testing
import TrieDictionary
@testable import ArrayTrie

@Suite struct ArrayTrieTests {
    
    // MARK: - Empty Trie Tests
    
    @Test func testEmptyTrie() {
        let trie = ArrayTrie<String>()
        #expect(trie.isEmpty())
        #expect(trie.get(["nonexistent"]) == nil)
    }
    
    // MARK: - Basic Operations Tests
    
    @Test func testSetAndGet() {
        var trie = ArrayTrie<String>()
        
        // Set a simple path
        trie.set(["users", "john"], value: "John Doe")
        
        // Verify the value can be retrieved
        #expect(trie.get(["users", "john"]) == "John Doe")
        
        // Verify non-existent paths return nil
        #expect(trie.get(["users", "jane"]) == nil)
        #expect(trie.get(["users"]) == nil)
        #expect(trie.get(["admins", "john"]) == nil)
    }
    
    @Test func testSetOverwrite() {
        var trie = ArrayTrie<String>()
        
        // Set initial value
        trie.set(["users", "john"], value: "John Doe")
        #expect(trie.get(["users", "john"]) == "John Doe")
        
        // Overwrite the value
        trie.set(["users", "john"], value: "Johnny")
        #expect(trie.get(["users", "john"]) == "Johnny")
    }
    
    @Test func testMultiplePaths() {
        var trie = ArrayTrie<String>()
        
        // Set multiple paths
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["admins", "bob"], value: "Bob Admin")
        
        // Verify all values can be retrieved
        #expect(trie.get(["users", "john"]) == "John Doe")
        #expect(trie.get(["users", "jane"]) == "Jane Smith")
        #expect(trie.get(["admins", "bob"]) == "Bob Admin")
    }
    
    @Test func testEmptyPath() {
        var trie = ArrayTrie<String>()
        
        // Empty path should do nothing
        trie.set([], value: "Root")
        #expect(trie.get([]) == nil)
    }
    
    // MARK: - Deletion Tests
    
    @Test func testDeletion() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        
        // Delete a path
        let newTrie = trie.deleting(path: ["users", "john"])
        
        // Original trie should be unchanged
        #expect(trie.get(["users", "john"]) == "John Doe")
        #expect(trie.get(["users", "jane"]) == "Jane Smith")
        
        // New trie should have the path deleted
        #expect(newTrie.get(["users", "john"]) == nil)
        #expect(newTrie.get(["users", "jane"]) == "Jane Smith")
    }
    
    @Test func testDeletionNonExistent() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john"], value: "John Doe")
        
        // Delete a non-existent path
        let newTrie = trie.deleting(path: ["users", "jane"])
        
        // Trie should be unchanged
        #expect(newTrie.get(["users", "john"]) == "John Doe")
    }
    
    @Test func testDeletionEmptyPath() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john"], value: "John Doe")
        
        // Delete with empty path
        let newTrie = trie.deleting(path: [])
        
        // Trie should be unchanged
        #expect(newTrie.get(["users", "john"]) == "John Doe")
    }
    
    // MARK: - Traversal Tests
    
    @Test func testTraversal() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john", "profile"], value: "John's Profile")
        trie.set(["users", "john", "settings"], value: "John's Settings")
        trie.set(["users", "jane", "profile"], value: "Jane's Profile")
        
        // Traverse to a subtrie
        let subtrie = trie.traverse(["users", "john"])
        
        // Verify the subtrie contains the expected values
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get(["profile"]) == "John's Profile")
            #expect(subtrie.get(["settings"]) == "John's Settings")
            #expect(subtrie.get(["nonexistent"]) == nil)
        }
    }
    
    @Test func testTraversalNonExistent() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john"], value: "John Doe")
        
        // Traverse to a non-existent path
        let subtrie = trie.traverse(["users", "jane"])
        
        // Verify the subtrie is nil
        #expect(subtrie == nil)
    }
    
    @Test func testTraversalPath() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john"], value: "John Doe")
        
        // Traverse to a non-existent path
        let subtrie = trie.traverse(["users", "john"])
        
        // Verify the subtrie is nil
        #expect(subtrie!.isEmpty())
    }
    
    @Test func testTraversalEmptyPath() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users", "john"], value: "John Doe")
        
        // Traverse with empty path
        let subtrie = trie.traverse([])
        
        // Verify the subtrie is the same as the original trie
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get(["users", "john"]) == "John Doe")
        }
    }
    
    // MARK: - Complex Scenarios Tests
    
    @Test func testPrefixSplitting() {
        var trie = ArrayTrie<String>()
        
        // Set up paths with common prefixes
        trie.set(["users", "john", "profile"], value: "John's Profile")
        trie.set(["users", "john", "settings"], value: "John's Settings")
        trie.set(["users", "jane"], value: "Jane Smith")
        
        // Add a path that requires splitting an existing prefix
        trie.set(["users"], value: "All Users")
        
        // Verify all values are correctly stored
        #expect(trie.get(["users"]) == "All Users")
        #expect(trie.get(["users", "john", "profile"]) == "John's Profile")
        #expect(trie.get(["users", "john", "settings"]) == "John's Settings")
        #expect(trie.get(["users", "jane"]) == "Jane Smith")
    }
    
    @Test func testCommonPrefixHandling() {
        var trie = ArrayTrie<String>()
        
        // Set a path
        trie.set(["users", "john", "profile"], value: "John's Profile")
        
        // Add a path with partial common prefix
        trie.set(["users", "johnathan"], value: "Johnathan's Data")
        
        // Verify both values are correctly stored
        #expect(trie.get(["users", "john", "profile"]) == "John's Profile")
        #expect(trie.get(["users", "johnathan"]) == "Johnathan's Data")
    }
    
    @Test func testDifferentValueTypes() {
        var stringTrie = ArrayTrie<String>()
        var intTrie = ArrayTrie<Int>()
        var boolTrie = ArrayTrie<Bool>()
        
        // Test with different value types
        stringTrie.set(["test"], value: "String Value")
        intTrie.set(["test"], value: 42)
        boolTrie.set(["test"], value: true)
        
        // Verify the values
        #expect(stringTrie.get(["test"]) == "String Value")
        #expect(intTrie.get(["test"]) == 42)
        #expect(boolTrie.get(["test"]) == true)
    }
    
    @Test func testNestedArrayTrieHandling() {
        var trie = ArrayTrie<ArrayTrie<String>>()
        
        // Create a nested trie
        var nestedTrie = ArrayTrie<String>()
        nestedTrie.set(["nested", "path"], value: "Nested Value")
        
        // Store the nested trie
        trie.set(["parent"], value: nestedTrie)
        
        // Retrieve the nested trie
        let retrievedTrie = trie.get(["parent"])
        #expect(retrievedTrie != nil)
        
        // Verify the nested value
        #expect(retrievedTrie?.get(["nested", "path"]) == "Nested Value")
    }
    
    // MARK: - Edge Cases
    
    @Test func testEmptyChildren() {
        let emptyMap = TrieDictionary<ArrayTrieNode<String>>()
        let trie = ArrayTrie<String>(children: emptyMap)
        
        #expect(trie.isEmpty())
        #expect(trie.get(["any", "path"]) == nil)
    }
    
    @Test func testLongPathHandling() {
        var trie = ArrayTrie<String>()
        
        // Create a very long path
        let longPath = (0..<1000).map { "segment\($0)" }
        trie.set(longPath, value: "Deep Value")
        
        // Verify it can be retrieved
        #expect(trie.get(longPath) == "Deep Value")
    }
    
    // MARK: - ArraySlice Extension Tests
    
    @Test func testLongestCommonPrefix() {
        let array1: ArraySlice = ["a", "b", "c", "d", "e"][...]
        let array2: ArraySlice = ["a", "b", "x", "y", "z"][...]
        
        let commonPrefix = array1.longestCommonPrefix(array2)
        
        #expect(commonPrefix == ["a", "b"])
    }
    
    @Test func testLongestCommonPrefixEmpty() {
        let array1: ArraySlice = ["a", "b", "c"][...]
        let array2: ArraySlice<String> = [][...]
        
        let commonPrefix = array1.longestCommonPrefix(array2)
        
        #expect(commonPrefix == [])
    }
    
    @Test func testLongestCommonPrefixNoMatch() {
        let array1: ArraySlice = ["a", "b", "c"][...]
        let array2: ArraySlice = ["x", "y", "z"][...]
        
        let commonPrefix = array1.longestCommonPrefix(array2)
        
        #expect(commonPrefix == [])
    }
    
    @Test func testLongestCommonPrefixFullMatch() {
        let array1: ArraySlice = ["a", "b", "c"][...]
        let array2: ArraySlice = ["a", "b", "c"][...]
        
        let commonPrefix = array1.longestCommonPrefix(array2)
        
        #expect(commonPrefix == ["a", "b", "c"])
    }
}
