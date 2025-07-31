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
        let values = trie.getValuesAlongPath("user")
        
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
        let values = trie.getValuesAlongPath("anything")
        
        // Should return empty array
        #expect(values.isEmpty)
    }
    
    @Test func testGetValuesAlongPathEmptyString() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        
        // Get values along empty path
        let values = trie.getValuesAlongPath("")
        
        // Empty string returns empty array (no keys are prefixes of empty string)
        #expect(values.isEmpty)
    }
    
    @Test func testGetValuesAlongPathNoMatches() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with values that don't match the search path
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        
        // Get values along a path that doesn't exist
        let values = trie.getValuesAlongPath("orange")
        
        // Should return empty array
        #expect(values.isEmpty)
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
        let values = trie.getValuesAlongPath("test")
        
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
        let intValues = intTrie.getValuesAlongPath("num")
        let boolValues = boolTrie.getValuesAlongPath("tr")
        
        // Should return values from keys that are prefixes of the search path
        #expect(intValues.contains(1))  // "n" is prefix of "num"
        #expect(intValues.contains(12)) // "nu" is prefix of "num"  
        #expect(intValues.contains(123)) // "num" matches exactly
        
        #expect(boolValues.contains(true))  // "t" is prefix of "tr"
        #expect(boolValues.contains(false)) // "tr" matches exactly
    }
    
    @Test func testGetValuesAlongPathSpecialCharacters() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys containing special characters
        trie.set(["user@"], value: "USER_AT")
        trie.set(["user@domain"], value: "USER_AT_DOMAIN")
        trie.set(["user-"], value: "USER_DASH")
        trie.set(["user_"], value: "USER_UNDERSCORE")
        trie.set(["user"], value: "USER")
        trie.set(["use"], value: "USE")
        trie.set(["u"], value: "U")
        
        // Get values along path with special characters
        let values = trie.getValuesAlongPath("user@")
        
        // Should return values from keys that are prefixes of "user@"
        #expect(values.contains("USER_AT")) // exact match
        #expect(values.contains("USER"))    // prefix
        #expect(values.contains("USE"))     // prefix
        #expect(values.contains("U"))       // prefix
        #expect(!values.contains("USER_AT_DOMAIN")) // longer than search path
        #expect(!values.contains("USER_DASH"))      // not a prefix
        #expect(!values.contains("USER_UNDERSCORE")) // not a prefix
    }
    
    @Test func testGetValuesAlongPathCaseSensitive() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with case-sensitive keys
        trie.set(["User"], value: "CAPITAL_USER")
        trie.set(["user"], value: "LOWERCASE_USER")
        trie.set(["USER"], value: "UPPER_USER")
        
        // Get values along lowercase path
        let lowerValues = trie.getValuesAlongPath("user")
        
        // Should only match exact case
        #expect(lowerValues.contains("LOWERCASE_USER"))
        #expect(!lowerValues.contains("CAPITAL_USER"))
        #expect(!lowerValues.contains("UPPER_USER"))
        
        // Get values along uppercase path
        let upperValues = trie.getValuesAlongPath("USER")
        
        // Should only match exact case
        #expect(upperValues.contains("UPPER_USER"))
        #expect(!upperValues.contains("LOWERCASE_USER"))
        #expect(!upperValues.contains("CAPITAL_USER"))
    }
    
    @Test func testGetValuesAlongPathLongString() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with progressively longer keys
        let baseKey = "verylongkeyname"
        for i in 1...baseKey.count {
            let key = String(baseKey.prefix(i))
            trie.set([key], value: "VALUE_\(i)")
        }
        
        // Get values along the full path
        let values = trie.getValuesAlongPath(baseKey)
        
        // Should return all values along the path
        #expect(values.count == baseKey.count)
        for i in 1...baseKey.count {
            #expect(values.contains("VALUE_\(i)"))
        }
    }
    
    @Test func testGetValuesAlongPathComplexStructure() {
        var trie = ArrayTrie<String>()
        
        // Set up a complex trie structure
        trie.set(["a"], value: "A")
        trie.set(["ab"], value: "AB")
        trie.set(["abc"], value: "ABC")
        trie.set(["abcd"], value: "ABCD")
        trie.set(["ax"], value: "AX")
        trie.set(["ay"], value: "AY")
        trie.set(["b"], value: "B")
        trie.set(["bc"], value: "BC")
        
        // Get values along path "abc"
        let abcValues = trie.getValuesAlongPath("abc")
        
        // Should return values from keys that are prefixes of "abc"
        #expect(abcValues.contains("A"))   // "a" is prefix of "abc"
        #expect(abcValues.contains("AB"))  // "ab" is prefix of "abc"
        #expect(abcValues.contains("ABC")) // "abc" matches exactly
        #expect(!abcValues.contains("ABCD")) // longer than search path
        #expect(!abcValues.contains("AX"))   // not a prefix
        #expect(!abcValues.contains("AY"))   // not a prefix
        #expect(!abcValues.contains("B"))    // not a prefix
        #expect(!abcValues.contains("BC"))   // not a prefix
        
        // Get values along path "a"
        let aValues = trie.getValuesAlongPath("a")
        
        // Should return only values where the key is a prefix of "a"
        #expect(aValues.contains("A"))       // "a" matches exactly
        #expect(!aValues.contains("AB"))     // longer than search path
        #expect(!aValues.contains("ABC"))    // longer than search path
        #expect(!aValues.contains("ABCD"))   // longer than search path
        #expect(!aValues.contains("AX"))     // longer than search path
        #expect(!aValues.contains("AY"))     // longer than search path
        #expect(!aValues.contains("B"))      // not a prefix
        #expect(!aValues.contains("BC"))     // not a prefix
    }
}
