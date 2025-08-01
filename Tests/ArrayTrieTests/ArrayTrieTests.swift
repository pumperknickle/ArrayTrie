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
        
        // Empty path should set the root value
        trie.set([], value: "Root")
        #expect(trie.get([]) == "Root")
    }
    
    @Test func testRootValueBasicOperations() {
        var trie = ArrayTrie<String>()
        
        // Initially empty
        #expect(trie.get([]) == nil)
        #expect(trie.isEmpty())
        
        // Set root value
        trie.set([], value: "Root Value")
        #expect(trie.get([]) == "Root Value")
        #expect(!trie.isEmpty()) // Should not be empty when root value exists
        
        // Override root value
        trie.set([], value: "New Root Value")
        #expect(trie.get([]) == "New Root Value")
        
        // Add regular path
        trie.set(["users"], value: "Users")
        #expect(trie.get([]) == "New Root Value")
        #expect(trie.get(["users"]) == "Users")
        
        // Delete root value
        let newTrie = trie.deleting(path: [])
        #expect(newTrie.get([]) == nil)
        #expect(newTrie.get(["users"]) == "Users")
    }
    
    @Test func testRootValueWithMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        // Set root values in both tries
        trie1.set([], value: "Root1")
        trie2.set([], value: "Root2")
        
        // Set some regular paths
        trie1.set(["path1"], value: "Value1")
        trie2.set(["path2"], value: "Value2")
        
        // Merge with first wins
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get([]) == "Root1")
        #expect(merged1.get(["path1"]) == "Value1")
        #expect(merged1.get(["path2"]) == "Value2")
        
        // Merge with concatenation
        let merged2 = trie1.merging(with: trie2) { a, b in "\(a)+\(b)" }
        #expect(merged2.get([]) == "Root1+Root2")
    }
    
    @Test func testRootValueMergeWithEmpty() {
        var trie1 = ArrayTrie<String>()
        let trie2 = ArrayTrie<String>()
        
        // Only one trie has root value
        trie1.set([], value: "OnlyRoot")
        trie1.set(["path"], value: "RegularValue")
        
        let merged = trie1.merging(with: trie2) { a, b in a }
        #expect(merged.get([]) == "OnlyRoot")
        #expect(merged.get(["path"]) == "RegularValue")
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
    
    // MARK: - String Path Traversal Tests
    
    @Test func testTraverseStringPath() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie - in ArrayTrie, the first level keys are what we traverse
        trie.set(["users"], value: "All Users")
        trie.set(["users-admin"], value: "Admin Users")
        trie.set(["posts"], value: "All Posts")
        
        // Traverse using string path - this should find all keys that start with "users"
        let usersSubtrie = trie.traverse(path: "users")
        
        // Verify the subtrie contains the expected structure
        #expect(usersSubtrie != nil)
        if let subtrie = usersSubtrie {
            #expect(!subtrie.isEmpty())
            let keys = subtrie.children.keys()
            #expect(keys.contains("-admin"))
        }
    }
    
    @Test func testTraverseStringPathNonExistent() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users"], value: "All Users")
        trie.set(["posts"], value: "All Posts")
        
        // Traverse using non-existent string path
        let subtrie = trie.traverse(path: "comments")
        
        // Verify the subtrie is nil
        #expect(subtrie == nil)
    }
    
    @Test func testTraverseStringPathEmpty() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["users"], value: "All Users")
        trie.set(["posts"], value: "All Posts")
        
        // Traverse using empty string path
        let subtrie = trie.traverse(path: "")
        
        // Should return the original trie structure since empty string matches all keys
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get(["users"]) == "All Users")
            #expect(subtrie.get(["posts"]) == "All Posts")
        }
    }
    
    @Test func testTraverseStringPathPartialMatch() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys that have common prefixes
        trie.set(["user"], value: "Single User")
        trie.set(["users"], value: "All Users")
        trie.set(["userdata"], value: "User Data")
        
        // Traverse using prefix that matches multiple keys
        let subtrie = trie.traverse(path: "user")
        
        // Verify the subtrie contains nodes with keys starting with "user"
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(!subtrie.isEmpty())
            // The traversed trie contains the suffix keys after removing the prefix
            let keys = subtrie.children.keys()
            #expect(keys.contains("s"))   // for "users" 
            #expect(keys.contains("data")) // for "userdata"
        }
    }
    
    @Test func testTraverseStringPathWithSpecialCharacters() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys containing special characters
        trie.set(["user@domain.com"], value: "Email User")
        trie.set(["user-name"], value: "Hyphenated User")
        trie.set(["user_id"], value: "Underscore User")
        
        // Traverse using partial string with special characters
        let subtrie = trie.traverse(path: "user")
        
        // Verify the subtrie contains the expected nodes
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(!subtrie.isEmpty())
            // Check that the suffix keys are present
            let keys = subtrie.children.keys()
            #expect(keys.contains("@domain.com"))
            #expect(keys.contains("-name"))
            #expect(keys.contains("_id"))
        }
    }
    
    @Test func testTraverseStringPathEmptyTrie() {
        let trie = ArrayTrie<String>()
        
        // Traverse empty trie
        let subtrie = trie.traverse(path: "anything")
        
        // Verify the subtrie is nil
        #expect(subtrie == nil)
    }
    
    // MARK: - GetValuesAlongPath Tests
    
    @Test func testGetValuesAlongPathBasic() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with values at different path levels
        trie.set(["u"], value: "U")
        trie.set(["us"], value: "US")
        trie.set(["use"], value: "USE")
        trie.set(["user"], value: "USER")
        trie.set(["users"], value: "USERS")
        
        // Get values along the path "user"
        let results = trie.getValuesAlongPath("user")
        
        // Extract just the values from the (trie, value) tuples
        let values = results.map { $0.1 }
        
        // getValuesAlongPath returns values from keys that are prefixes of the path
        #expect(values.contains("U"))
        #expect(values.contains("US"))
        #expect(values.contains("USE"))
        #expect(values.contains("USER"))
        // "USERS" should not be included as it's longer than the search path
        #expect(!values.contains("USERS"))
    }
    
    @Test func testGetValuesAlongPathEmpty() {
        let trie = ArrayTrie<String>()
        
        // Get values from empty trie
        let results = trie.getValuesAlongPath("anything")
        
        // Should return empty array
        #expect(results.isEmpty)
    }
    
    @Test func testGetValuesAlongPathEmptyString() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        
        // Get values along empty path
        let results = trie.getValuesAlongPath("")
        
        // Empty string returns empty array (no keys are prefixes of empty string)
        #expect(results.isEmpty)
    }
    
    @Test func testGetValuesAlongPathNoMatches() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with values that don't match the search path
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        
        // Get values along a path that doesn't exist
        let results = trie.getValuesAlongPath("orange")
        
        // Should return empty array
        #expect(results.isEmpty)
    }
    
    @Test func testGetValuesAlongPathPartialMatches() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with some matching and some non-matching keys
        trie.set(["test"], value: "TEST")
        trie.set(["testing"], value: "TESTING")
        trie.set(["best"], value: "BEST")
        trie.set(["rest"], value: "REST")
        trie.set(["te"], value: "TE")
        trie.set(["t"], value: "T")
        
        // Get values along path "test"
        let results = trie.getValuesAlongPath("test")
        let values = results.map { $0.1 }
        
        // Should return values from keys that are prefixes of "test"
        #expect(values.contains("TEST"))
        #expect(values.contains("TE"))
        #expect(values.contains("T"))
        #expect(!values.contains("TESTING")) // longer than search path
        #expect(!values.contains("BEST"))
        #expect(!values.contains("REST"))
    }
    
    @Test func testGetValuesAlongPathMultipleTypes() {
        var intTrie = ArrayTrie<Int>()
        var boolTrie = ArrayTrie<Bool>()
        
        // Set up tries with different value types
        intTrie.set(["n"], value: 1)
        intTrie.set(["nu"], value: 12)
        intTrie.set(["num"], value: 123)
        
        boolTrie.set(["t"], value: true)
        boolTrie.set(["tr"], value: false)
        boolTrie.set(["tru"], value: true)
        
        // Get values along paths
        let intResults = intTrie.getValuesAlongPath("num")
        let boolResults = boolTrie.getValuesAlongPath("tr")
        
        let intValues = intResults.map { $0.1 }
        let boolValues = boolResults.map { $0.1 }
        
        // Should return values from keys that are prefixes of the search path
        #expect(intValues.contains(1))  // "n" is prefix of "num"
        #expect(intValues.contains(12)) // "nu" is prefix of "num"  
        #expect(intValues.contains(123)) // "num" matches exactly
        
        #expect(boolValues.contains(true))  // "t" is prefix of "tr"
        #expect(boolValues.contains(false)) // "tr" matches exactly
    }
    
    // MARK: - Merge Functionality Tests
    
    @Test func testMergeEmptyTries() {
        let trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie2.set(["user"], value: "User Data")
        
        // Merge empty with non-empty
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get(["user"]) == "User Data")
        
        // Merge non-empty with empty
        let merged2 = trie2.merging(with: trie1) { a, b in a }
        #expect(merged2.get(["user"]) == "User Data")
        
        // Merge empty with empty
        let merged3 = trie1.merging(with: ArrayTrie<String>()) { a, b in a }
        #expect(merged3.isEmpty())
    }
    
    @Test func testMergeDisjointPaths() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["users", "john"], value: "John")
        trie1.set(["users", "jane"], value: "Jane")
        
        trie2.set(["admin", "bob"], value: "Bob")
        trie2.set(["config", "db"], value: "Database")
        
        let merged = trie1.merging(with: trie2) { a, b in a }
        
        // All values should be preserved
        #expect(merged.get(["users", "john"]) == "John")
        #expect(merged.get(["users", "jane"]) == "Jane")
        #expect(merged.get(["admin", "bob"]) == "Bob")
        #expect(merged.get(["config", "db"]) == "Database")
    }
    
    @Test func testMergeOverlappingPaths() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["users", "john"], value: "John1")
        trie1.set(["users", "jane"], value: "Jane1")
        
        trie2.set(["users", "john"], value: "John2")
        trie2.set(["users", "bob"], value: "Bob2")
        
        // Test "first wins" merge rule
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get(["users", "john"]) == "John1")  // first wins
        #expect(merged1.get(["users", "jane"]) == "Jane1")  // only in first
        #expect(merged1.get(["users", "bob"]) == "Bob2")    // only in second
        
        // Test "last wins" merge rule
        let merged2 = trie1.merging(with: trie2) { a, b in b }
        #expect(merged2.get(["users", "john"]) == "John2")  // second wins
        
        // Test combine merge rule
        let merged3 = trie1.merging(with: trie2) { a, b in "\(a)+\(b)" }
        #expect(merged3.get(["users", "john"]) == "John1+John2")  // combined
    }
    
    @Test func testMergePrefixRelationships() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        // Set up prefix relationship: ["user", "profile"] vs ["user", "profile", "settings"]
        trie1.set(["user", "profile"], value: "Profile")
        trie2.set(["user", "profile", "settings"], value: "Settings")
        
        let merged = trie1.merging(with: trie2) { a, b in a }
        
        #expect(merged.get(["user", "profile"]) == "Profile")
        #expect(merged.get(["user", "profile", "settings"]) == "Settings")
    }
    
    @Test func testMergeComplexScenarios() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        // Create complex nested structures
        trie1.set(["api", "v1", "users"], value: "V1Users")
        trie1.set(["api", "v1", "posts"], value: "V1Posts")
        trie1.set(["web", "login"], value: "WebLogin")
        
        trie2.set(["api", "v1", "users"], value: "V1UsersNew")  // conflict
        trie2.set(["api", "v2", "users"], value: "V2Users")    // new branch
        trie2.set(["mobile", "auth"], value: "MobileAuth")     // new root
        
        let merged = trie1.merging(with: trie2) { old, new in "\(old)|\(new)" }
        
        // Check merged values
        #expect(merged.get(["api", "v1", "users"]) == "V1Users|V1UsersNew")
        #expect(merged.get(["api", "v1", "posts"]) == "V1Posts")
        #expect(merged.get(["api", "v2", "users"]) == "V2Users")
        #expect(merged.get(["web", "login"]) == "WebLogin")
        #expect(merged.get(["mobile", "auth"]) == "MobileAuth")
        
        // Check non-existent paths
        #expect(merged.get(["api", "v3", "users"]) == nil)
    }
    
    @Test func testMergeWithDifferentTypes() {
        var intTrie1 = ArrayTrie<Int>()
        var intTrie2 = ArrayTrie<Int>()
        
        intTrie1.set(["counter", "a"], value: 5)
        intTrie1.set(["counter", "b"], value: 10)
        
        intTrie2.set(["counter", "a"], value: 3)  // conflict
        intTrie2.set(["counter", "c"], value: 7)  // new
        
        let merged = intTrie1.merging(with: intTrie2) { a, b in a + b }
        
        #expect(merged.get(["counter", "a"]) == 8)   // 5 + 3
        #expect(merged.get(["counter", "b"]) == 10)  // unchanged
        #expect(merged.get(["counter", "c"]) == 7)   // new value
    }
    
    @Test func testMergeEdgeCases() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        // Test with empty path arrays (should be ignored by ArrayTrie)
        trie1.set([""], value: "Empty1")
        trie2.set([""], value: "Empty2")
        
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get([""]) == "Empty1")
        
        // Test with single-element paths
        trie1.set(["x"], value: "X1")
        trie2.set(["x"], value: "X2")
        
        let merged2 = trie1.merging(with: trie2) { a, b in "\(a)-\(b)" }
        #expect(merged2.get(["x"]) == "X1-X2")
        
        // Test with very deep paths
        let deepPath = (0..<20).map { "level\($0)" }
        trie1.set(deepPath, value: "Deep1")
        trie2.set(deepPath, value: "Deep2")
        
        let merged3 = trie1.merging(with: trie2) { a, b in b }  // second wins
        #expect(merged3.get(deepPath) == "Deep2")
    }
    
    @Test func testMergePreservesCompression() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        // Create situations that should maintain path compression
        trie1.set(["very", "long", "path", "to", "resource"], value: "Resource1")
        trie2.set(["very", "long", "path", "to", "other"], value: "Other")
        
        let merged = trie1.merging(with: trie2) { a, b in a }
        
        // Both paths should be accessible
        #expect(merged.get(["very", "long", "path", "to", "resource"]) == "Resource1")
        #expect(merged.get(["very", "long", "path", "to", "other"]) == "Other")
        
        // Intermediate paths should not have values (testing compression)
        #expect(merged.get(["very", "long", "path"]) == nil)
        #expect(merged.get(["very", "long", "path", "to"]) == nil)
    }
    
    @Test func testMergeImmutability() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["original"], value: "Original1")
        trie2.set(["original"], value: "Original2")
        
        let merged = trie1.merging(with: trie2) { a, b in "Merged" }
        
        // Verify original tries are unchanged
        #expect(trie1.get(["original"]) == "Original1")
        #expect(trie2.get(["original"]) == "Original2")
        
        // Verify merged result
        #expect(merged.get(["original"]) == "Merged")
        
        // Modify original tries after merge
        trie1.set(["new"], value: "New1")
        trie2.set(["new"], value: "New2")
        
        // Merged trie should be unaffected
        #expect(merged.get(["new"]) == nil)
        #expect(merged.get(["original"]) == "Merged")
    }
    
    @Test func testMergePerformance() {
        var trie1 = ArrayTrie<Int>()
        var trie2 = ArrayTrie<Int>()
        
        // Create moderately large tries for performance testing
        for i in 0..<100 {
            trie1.set(["group1", "item\(i)"], value: i)
            trie2.set(["group2", "item\(i)"], value: i + 100)
        }
        
        // Add some overlapping keys
        for i in 0..<20 {
            trie2.set(["group1", "item\(i)"], value: i + 1000)
        }
        
        let merged = trie1.merging(with: trie2) { a, b in a + b }
        
        // Verify some results
        #expect(merged.get(["group1", "item0"]) == 1000)  // 0 + 1000
        #expect(merged.get(["group1", "item50"]) == 50)   // no conflict
        #expect(merged.get(["group2", "item0"]) == 100)   // only in trie2
        
        // Verify total number of accessible paths
        var count = 0
        for i in 0..<100 {
            if merged.get(["group1", "item\(i)"]) != nil { count += 1 }
            if merged.get(["group2", "item\(i)"]) != nil { count += 1 }
        }
        #expect(count == 200)  // All paths should be accessible
    }
    
    // MARK: - MergeAll Static Method Tests
    
    @Test func testMergeAllEmptyArray() {
        let result = ArrayTrie<String>.mergeAll(tries: []) { a, b in a }
        
        #expect(result.isEmpty())
        #expect(result.get(["any", "path"]) == nil)
    }
    
    @Test func testMergeAllSingleTrie() {
        var trie = ArrayTrie<String>()
        trie.set(["user", "name"], value: "John")
        trie.set(["user", "age"], value: "30")
        trie.set(["config", "debug"], value: "true")
        
        let result = ArrayTrie<String>.mergeAll(tries: [trie]) { a, b in a }
        
        #expect(result.get(["user", "name"]) == "John")
        #expect(result.get(["user", "age"]) == "30")
        #expect(result.get(["config", "debug"]) == "true")
    }
    
    @Test func testMergeAllTwoTries() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["users", "john"], value: "John1")
        trie1.set(["users", "jane"], value: "Jane1")
        
        trie2.set(["users", "bob"], value: "Bob2")
        trie2.set(["config", "mode"], value: "prod")
        
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2]) { a, b in a }
        
        #expect(result.get(["users", "john"]) == "John1")
        #expect(result.get(["users", "jane"]) == "Jane1")
        #expect(result.get(["users", "bob"]) == "Bob2")
        #expect(result.get(["config", "mode"]) == "prod")
    }
    
    @Test func testMergeAllMultipleDisjointTries() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        var trie4 = ArrayTrie<String>()
        
        trie1.set(["api", "v1"], value: "V1")
        trie2.set(["web", "login"], value: "Login")
        trie3.set(["mobile", "auth"], value: "Auth")
        trie4.set(["admin", "panel"], value: "Panel")
        
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3, trie4]) { a, b in a }
        
        #expect(result.get(["api", "v1"]) == "V1")
        #expect(result.get(["web", "login"]) == "Login")
        #expect(result.get(["mobile", "auth"]) == "Auth")
        #expect(result.get(["admin", "panel"]) == "Panel")
    }
    
    @Test func testMergeAllOverlappingPaths() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        
        trie1.set(["config", "database"], value: "mysql")
        trie1.set(["config", "port"], value: "3306")
        
        trie2.set(["config", "database"], value: "postgres")
        trie2.set(["config", "host"], value: "localhost")
        
        trie3.set(["config", "database"], value: "redis")
        trie3.set(["config", "timeout"], value: "30")
        
        // Test "first wins" merge rule
        let result1 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a }
        #expect(result1.get(["config", "database"]) == "mysql")  // first wins
        #expect(result1.get(["config", "port"]) == "3306")
        #expect(result1.get(["config", "host"]) == "localhost")
        #expect(result1.get(["config", "timeout"]) == "30")
        
        // Test "last wins" merge rule
        let result2 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in b }
        #expect(result2.get(["config", "database"]) == "redis")  // last wins
        
        // Test concatenation merge rule
        let result3 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in "\(a)|\(b)" }
        #expect(result3.get(["config", "database"]) == "mysql|postgres|redis")
    }
    
    @Test func testMergeAllComplexNested() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        
        // Create complex nested structures with different depths
        trie1.set(["api", "v1", "users", "create"], value: "POST")
        trie1.set(["api", "v1", "users", "read"], value: "GET")
        trie1.set(["api", "v1", "posts"], value: "POSTS")
        
        trie2.set(["api", "v1", "users", "update"], value: "PUT")
        trie2.set(["api", "v2", "users"], value: "V2_USERS")
        trie2.set(["web", "dashboard"], value: "DASH")
        
        trie3.set(["api", "v1", "users", "delete"], value: "DELETE")
        trie3.set(["api", "v1", "users", "create"], value: "CREATE_V3")  // conflict
        trie3.set(["mobile", "auth"], value: "MOBILE_AUTH")
        
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in "\(a)+\(b)" }
        
        // Check merged values
        #expect(result.get(["api", "v1", "users", "create"]) == "POST+CREATE_V3")
        #expect(result.get(["api", "v1", "users", "read"]) == "GET")
        #expect(result.get(["api", "v1", "users", "update"]) == "PUT")
        #expect(result.get(["api", "v1", "users", "delete"]) == "DELETE")
        #expect(result.get(["api", "v1", "posts"]) == "POSTS")
        #expect(result.get(["api", "v2", "users"]) == "V2_USERS")
        #expect(result.get(["web", "dashboard"]) == "DASH")
        #expect(result.get(["mobile", "auth"]) == "MOBILE_AUTH")
    }
    
    @Test func testMergeAllWithIntegerValues() {
        var trie1 = ArrayTrie<Int>()
        var trie2 = ArrayTrie<Int>()
        var trie3 = ArrayTrie<Int>()
        
        trie1.set(["counters", "page_views"], value: 100)
        trie1.set(["counters", "users"], value: 50)
        
        trie2.set(["counters", "page_views"], value: 200)
        trie2.set(["counters", "orders"], value: 25)
        
        trie3.set(["counters", "page_views"], value: 150)
        trie3.set(["counters", "errors"], value: 5)
        
        // Test sum merge rule
        let result = ArrayTrie<Int>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a + b }
        
        #expect(result.get(["counters", "page_views"]) == 450)  // 100 + 200 + 150
        #expect(result.get(["counters", "users"]) == 50)
        #expect(result.get(["counters", "orders"]) == 25)
        #expect(result.get(["counters", "errors"]) == 5)
    }
    
    @Test func testMergeAllOrderMatters() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        
        trie1.set(["value"], value: "A")
        trie2.set(["value"], value: "B")
        trie3.set(["value"], value: "C")
        
        // Test different orders produce different results with first-wins
        let result1 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a }
        let result2 = ArrayTrie<String>.mergeAll(tries: [trie3, trie2, trie1]) { a, b in a }
        
        #expect(result1.get(["value"]) == "A")  // first in array wins
        #expect(result2.get(["value"]) == "C")  // first in array wins
        
        // Test different orders with concatenation merge rule
        let result3 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in "\(a)-\(b)" }
        let result4 = ArrayTrie<String>.mergeAll(tries: [trie3, trie2, trie1]) { a, b in "\(a)-\(b)" }
        
        #expect(result3.get(["value"]) == "A-B-C")
        #expect(result4.get(["value"]) == "C-B-A")
    }
    
    @Test func testMergeAllPrefixRelationships() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        
        // Create prefix relationships across multiple tries
        trie1.set(["user"], value: "USER")
        trie2.set(["user", "profile"], value: "PROFILE")
        trie3.set(["user", "profile", "settings"], value: "SETTINGS")
        
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a }
        
        #expect(result.get(["user"]) == "USER")
        #expect(result.get(["user", "profile"]) == "PROFILE")
        #expect(result.get(["user", "profile", "settings"]) == "SETTINGS")
    }
    
    @Test func testMergeAllImmutability() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["original"], value: "Value1")
        trie2.set(["original"], value: "Value2")
        
        let originalTries = [trie1, trie2]
        let result = ArrayTrie<String>.mergeAll(tries: originalTries) { a, b in "Merged" }
        
        // Verify original tries are unchanged
        #expect(trie1.get(["original"]) == "Value1")
        #expect(trie2.get(["original"]) == "Value2")
        
        // Verify merged result
        #expect(result.get(["original"]) == "Merged")
        
        // Modify original tries after merge
        trie1.set(["new"], value: "New1")
        trie2.set(["new"], value: "New2")
        
        // Merged result should be unaffected
        #expect(result.get(["new"]) == nil)
        #expect(result.get(["original"]) == "Merged")
    }
    
    @Test func testMergeAllPerformance() {
        var tries: [ArrayTrie<Int>] = []
        
        // Create multiple tries with overlapping and disjoint data
        for trieIndex in 0..<10 {
            var trie = ArrayTrie<Int>()
            
            // Each trie has some unique data
            for i in 0..<20 {
                trie.set(["trie\(trieIndex)", "item\(i)"], value: trieIndex * 100 + i)
            }
            
            // Each trie also has some overlapping data
            for i in 0..<5 {
                trie.set(["shared", "item\(i)"], value: trieIndex * 10 + i)
            }
            
            tries.append(trie)
        }
        
        let result = ArrayTrie<Int>.mergeAll(tries: tries) { a, b in a + b }
        
        // Verify unique data is preserved
        for trieIndex in 0..<10 {
            for i in 0..<20 {
                let expected = trieIndex * 100 + i
                #expect(result.get(["trie\(trieIndex)", "item\(i)"]) == expected)
            }
        }
        
        // Verify shared data is correctly merged (sum of all contributions)
        for i in 0..<5 {
            var expectedSum = 0
            for trieIndex in 0..<10 {
                expectedSum += trieIndex * 10 + i
            }
            #expect(result.get(["shared", "item\(i)"]) == expectedSum)
        }
    }
    
    @Test func testMergeAllMixedEmptyTries() {
        var trie1 = ArrayTrie<String>()
        let trie2 = ArrayTrie<String>()  // empty
        var trie3 = ArrayTrie<String>()
        let trie4 = ArrayTrie<String>()  // empty
        
        trie1.set(["data"], value: "Data1")
        trie3.set(["data"], value: "Data3")
        
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3, trie4]) { a, b in "\(a)|\(b)" }
        
        #expect(result.get(["data"]) == "Data1|Data3")
    }
}
