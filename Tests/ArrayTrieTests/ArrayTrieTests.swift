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
    
    @Test func testGetValuesOfKeysThatDontStartWith() {
        var trie = ArrayTrie<String>()
        
        // Set up test data
        trie.set(["apple", "red"], value: "Red Apple")
        trie.set(["apple", "green"], value: "Green Apple")
        trie.set(["banana", "yellow"], value: "Yellow Banana")
        trie.set(["cherry", "red"], value: "Red Cherry")
        trie.set(["apricot", "orange"], value: "Orange Apricot")
        
        // Test with key "apple" - should get banana, cherry, apricot values
        let notApple = trie.getValuesOfKeysThatDontStartWith(key: "apple")
        #expect(Set(notApple) == Set(["Yellow Banana", "Red Cherry", "Orange Apricot"]))
        
        // Test with key "b" - should get apple, cherry, apricot values
        let notB = trie.getValuesOfKeysThatDontStartWith(key: "b")
        #expect(Set(notB) == Set(["Red Apple", "Green Apple", "Red Cherry", "Orange Apricot"]))
        
        // Test with key "cherry" - should get apple, banana, apricot values
        let notCherry = trie.getValuesOfKeysThatDontStartWith(key: "cherry")
        #expect(Set(notCherry) == Set(["Red Apple", "Green Apple", "Yellow Banana", "Orange Apricot"]))
        
        // Test with empty key - should return empty array
        let emptyKey = trie.getValuesOfKeysThatDontStartWith(key: "")
        #expect(emptyKey.isEmpty)
        
        // Test with non-existent prefix - should return all values
        let nonExistent = trie.getValuesOfKeysThatDontStartWith(key: "zebra")
        #expect(Set(nonExistent) == Set(["Red Apple", "Green Apple", "Yellow Banana", "Red Cherry", "Orange Apricot"]))
    }
    
    @Test func testGetValuesOfKeysThatDontStartWithEdgeCases() {
        var trie = ArrayTrie<String>()
        
        // Set up test data with exact matches and prefix scenarios
        trie.set(["app"], value: "App Value")
        trie.set(["apple"], value: "Apple Value") 
        trie.set(["application"], value: "Application Value")
        trie.set(["apply"], value: "Apply Value")
        trie.set(["appy"], value: "Appy Value")
        trie.set(["banana"], value: "Banana Value")
        trie.set(["band"], value: "Band Value")
        trie.set(["cat"], value: "Cat Value")
        
        // Test exact match - "app" should NOT exclude "apple", "application", "apply"
        // because they don't start with "app" as a key, they start with different characters
        let exactMatch = trie.getValuesOfKeysThatDontStartWith(key: "app")
        #expect(Set(exactMatch) == Set(["Banana Value", "Band Value", "Cat Value"]))
        
        // Test prefix that matches multiple keys - "appl" should exclude "apple" and "application" 
        let prefixMatch = trie.getValuesOfKeysThatDontStartWith(key: "appl")
        #expect(Set(prefixMatch) == Set(["App Value", "Banana Value", "Band Value", "Cat Value", "Appy Value"]))
        
        // Test single character - "a" should exclude all "a*" keys
        let singleChar = trie.getValuesOfKeysThatDontStartWith(key: "a")
        #expect(Set(singleChar) == Set(["Banana Value", "Band Value", "Cat Value"]))
        
        // Test longer key than any stored - should return all values
        let longerKey = trie.getValuesOfKeysThatDontStartWith(key: "applications")
        #expect(Set(longerKey) == Set(["App Value", "Apple Value", "Application Value", "Apply Value", "Banana Value", "Band Value", "Cat Value", "Appy Value"]))
    }
    
    @Test func testGetValuesOfKeysThatDontStartWithWithRootValues() {
        var trie = ArrayTrie<String>()
        
        // Add root value and child values
        trie.set([], value: "Root Value")
        trie.set(["a"], value: "A Value")
        trie.set(["ab"], value: "AB Value") 
        trie.set(["b"], value: "B Value")
        trie.set(["c"], value: "C Value")
        
        // Test with "a" - should get b, c values and root value (only initial root not returned)
        let notA = trie.getValuesOfKeysThatDontStartWith(key: "a")
        #expect(Set(notA) == Set(["Root Value", "B Value", "C Value"]))
        
        // Test with "ab" - should get everything except ab value, including root value
        let notAB = trie.getValuesOfKeysThatDontStartWith(key: "ab")
        #expect(Set(notAB) == Set(["Root Value", "A Value", "B Value", "C Value"]))
    }
    
    @Test func testGetValuesOfKeysThatDontStartWithNestedPaths() {
        var trie = ArrayTrie<String>()
        
        // Create nested structure where intermediate nodes have values
        trie.set(["api"], value: "API Root")
        trie.set(["api", "v1"], value: "API V1")
        trie.set(["api", "v1", "users"], value: "API V1 Users")
        trie.set(["api", "v2"], value: "API V2")
        trie.set(["web"], value: "Web Root")
        trie.set(["web", "admin"], value: "Web Admin")
        
        // Test with "api" - should exclude all api paths
        let notAPI = trie.getValuesOfKeysThatDontStartWith(key: "api")
        #expect(Set(notAPI) == Set(["Web Root", "Web Admin"]))
        
        // Test with "web" - should exclude all web paths  
        let notWeb = trie.getValuesOfKeysThatDontStartWith(key: "web")
        #expect(Set(notWeb) == Set(["API Root", "API V1", "API V1 Users", "API V2"]))
        
        // Test with partial match "ap" - should exclude api paths
        let notAP = trie.getValuesOfKeysThatDontStartWith(key: "ap")
        #expect(Set(notAP) == Set(["Web Root", "Web Admin"]))
        
        // Test with non-matching prefix - should return all
        let notXYZ = trie.getValuesOfKeysThatDontStartWith(key: "xyz")
        #expect(Set(notXYZ) == Set(["API Root", "API V1", "API V1 Users", "API V2", "Web Root", "Web Admin"]))
    }
    
    @Test func testGetValuesOfKeysThatDontStartWithEmptyTrie() {
        let trie = ArrayTrie<String>()
        
        // Empty trie should return empty array for any key
        let result = trie.getValuesOfKeysThatDontStartWith(key: "anything")
        #expect(result.isEmpty)
        
        let emptyResult = trie.getValuesOfKeysThatDontStartWith(key: "")
        #expect(emptyResult.isEmpty)
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
    
    @Test func testEmptyStringInPath() {
        var trie = ArrayTrie<String>()
        
        // Empty string path should set the root value
        trie.set([""], value: "Root")
        #expect(trie.get([""]) == "Root")
        
        
        trie.set(["hello", ""], value: "Root")
        #expect(trie.get(["hello", ""]) == "Root")
        
        #expect(trie.traverse(["hello"])?.get([""]) == "Root")
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
        
        // Traverse to the path that has a value
        let subtrie = trie.traverse(["users", "john"])
        
        // Verify the subtrie has the value as rootValue and no children
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get([]) == "John Doe")  // rootValue should be the traversed value
            #expect(subtrie.children.isEmpty)       // no children beyond this path
        }
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
    
    // MARK: - Additional String Path Traversal Tests
    
    @Test func testTraverseStringPathEmptyString() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with various keys
        trie.set([""], value: "Empty Key")
        trie.set(["a"], value: "A")
        trie.set(["ab"], value: "AB")
        
        // Traverse with empty string
        let subtrie = trie.traverse(path: "")
        
        // Empty string should return the original trie since all keys start with empty prefix
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(result.get([""]) == "Empty Key")
            #expect(result.get(["a"]) == "A")
            #expect(result.get(["ab"]) == "AB")
        }
    }
    
    @Test func testTraverseStringPathSingleCharacter() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["a"], value: "Just A")
        trie.set(["apple"], value: "Apple")
        trie.set(["application"], value: "Application")
        trie.set(["banana"], value: "Banana")
        
        // Traverse with single character
        let subtrie = trie.traverse(path: "a")
        
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(!result.isEmpty())
            // Should contain keys that start with "a" with "a" prefix removed
            let keys = result.children.keys()
            #expect(keys.contains("")) // for "a"
            #expect(keys.contains("pple")) // for "apple"
            #expect(keys.contains("pplication")) // for "application"
            #expect(!keys.contains("banana")) // doesn't start with "a"
        }
    }
    
    @Test func testTraverseStringPathComplexPrefixes() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with complex prefix relationships
        trie.set(["prefix"], value: "Prefix")
        trie.set(["prefixed"], value: "Prefixed")
        trie.set(["prefixing"], value: "Prefixing")
        trie.set(["pre"], value: "Pre")
        trie.set(["prepare"], value: "Prepare")
        trie.set(["other"], value: "Other")
        
        // Traverse with "prefix"
        let subtrie = trie.traverse(path: "prefix")
        
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(!result.isEmpty())
            let keys = result.children.keys()
            #expect(keys.contains("")) // for exact "prefix" match
            #expect(keys.contains("ed")) // for "prefixed"
            #expect(keys.contains("ing")) // for "prefixing"
            #expect(!keys.contains("pre")) // doesn't start with "prefix"
            #expect(!keys.contains("prepare")) // doesn't start with "prefix"
        }
    }
    
    @Test func testTraverseStringPathNoCommonPrefix() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys that don't share the search prefix
        trie.set(["banana"], value: "Banana")
        trie.set(["cherry"], value: "Cherry")
        trie.set(["date"], value: "Date")
        
        // Traverse with prefix that doesn't exist
        let subtrie = trie.traverse(path: "apple")
        
        // Should return nil since no keys start with "apple"
        #expect(subtrie == nil)
    }
    
    @Test func testTraverseStringPathCaseSensitive() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with case variations
        trie.set(["Apple"], value: "Capital A")
        trie.set(["apple"], value: "Lowercase a")
        trie.set(["APPLE"], value: "All Caps")
        
        // Traverse with lowercase
        let lowerSubtrie = trie.traverse(path: "apple")
        #expect(lowerSubtrie != nil)
        if let result = lowerSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // exact match for "apple"
            #expect(!keys.contains("Apple")) // case sensitive
        }
        
        // Traverse with uppercase
        let upperSubtrie = trie.traverse(path: "Apple")
        #expect(upperSubtrie != nil)
        if let result = upperSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // exact match for "Apple"
        }
    }
    
    @Test func testTraverseStringPathNumbers() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with numeric prefixes
        trie.set(["123"], value: "One Two Three")
        trie.set(["1234"], value: "One Two Three Four")
        trie.set(["12"], value: "One Two")
        trie.set(["456"], value: "Four Five Six")
        
        // Traverse with numeric prefix
        let subtrie = trie.traverse(path: "123")
        
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // for "123"
            #expect(keys.contains("4")) // for "1234"
            #expect(!keys.contains("12")) // doesn't start with "123"
        }
    }
    
    @Test func testTraverseStringPathUnicode() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with Unicode characters
        trie.set(["café"], value: "Coffee")
        trie.set(["cafés"], value: "Coffees")
        trie.set(["naïve"], value: "Naive")
        trie.set(["🙂happy"], value: "Happy")
        trie.set(["🙂sad"], value: "Sad")
        
        // Traverse with Unicode prefix
        let cafeSubtrie = trie.traverse(path: "café")
        #expect(cafeSubtrie != nil)
        if let result = cafeSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // for "café"
            #expect(keys.contains("s")) // for "cafés"
        }
        
        // Traverse with emoji prefix
        let emojiSubtrie = trie.traverse(path: "🙂")
        #expect(emojiSubtrie != nil)
        if let result = emojiSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("happy"))
            #expect(keys.contains("sad"))
        }
    }
    
    @Test func testTraverseStringPathSpecialCharacters() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with special characters
        trie.set(["@user"], value: "User Mention")
        trie.set(["@admin"], value: "Admin Mention")
        trie.set(["#tag"], value: "Hashtag")
        trie.set(["$variable"], value: "Variable")
        trie.set(["file.txt"], value: "Text File")
        trie.set(["file.pdf"], value: "PDF File")
        
        // Traverse with @ prefix
        let mentionSubtrie = trie.traverse(path: "@")
        #expect(mentionSubtrie != nil)
        if let result = mentionSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("user"))
            #expect(keys.contains("admin"))
        }
        
        // Traverse with file prefix
        let fileSubtrie = trie.traverse(path: "file")
        #expect(fileSubtrie != nil)
        if let result = fileSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(".txt"))
            #expect(keys.contains(".pdf"))
        }
    }
    
    @Test func testTraverseStringPathDeepNesting() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with deeply nested structure
        trie.set(["api", "v1", "users"], value: "V1 Users")
        trie.set(["api", "v2", "users"], value: "V2 Users")
        trie.set(["application"], value: "App")
        trie.set(["app"], value: "Short App")
        
        // Traverse with "app" - should match both "app" and "application"
        let appSubtrie = trie.traverse(path: "app")
        #expect(appSubtrie != nil)
        if let result = appSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // for "app"
            #expect(keys.contains("lication")) // for "application"
        }
        
        // Traverse with "api" - should only match the "api" key
        let apiSubtrie = trie.traverse(path: "api")
        let resultTrie = apiSubtrie!.traverse([""])
        #expect(apiSubtrie != nil)
        if let result = apiSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // we should have an entry for the exact match
            #expect(!keys.contains("app"))// shouldn't contain unrelated keys
            #expect(resultTrie!.get(["v1", "users"]) == "V1 Users")
            #expect(resultTrie!.get(["v2", "users"]) == "V2 Users")
        }
    }
    
    @Test func testGetValuesAlongPathsResultingTries() {
        var trie = ArrayTrie<String>()
        
        trie.set(["test"], value: "test")
        trie.set(["te"], value: "te")
        trie.set(["tes"], value: "tes")
        trie.set(["test", "foo"], value: "test,foo")
        trie.set(["test", "fo"], value: "test,fo")
        trie.set(["te", "foe"], value: "te,foe")
        trie.set(["tes", "far"], value: "tes,far")
        
        let pathValuesAndTries = trie.getValuesAlongPath("test")
        let values = pathValuesAndTries.map  { $0.1 }
        #expect(values.contains("test"))
        #expect(values.contains("te"))
        #expect(values.contains("tes"))
        for pathValueAndTrie in pathValuesAndTries {
            if pathValueAndTrie.1 == "test" {
                #expect(pathValueAndTrie.0.get(["foo"]) == "test,foo")
                #expect(pathValueAndTrie.0.get(["fo"]) == "test,fo")
            }
            if pathValueAndTrie.1 == "te" {
                #expect(pathValueAndTrie.0.get(["foe"]) == "te,foe")
            }
            if pathValueAndTrie.1 == "tes" {
                #expect(pathValueAndTrie.0.get(["far"]) == "tes,far")
            }
        }
    }
    
    @Test func testTraverseStringPathExactMatchVsPrefix() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie
        trie.set(["test"], value: "Test Exact")
        trie.set(["testing"], value: "Testing")
        trie.set(["tester"], value: "Tester")
        trie.set(["te"], value: "Te")
        
        // Traverse with exact match
        let testSubtrie = trie.traverse(path: "test")
        #expect(testSubtrie != nil)
        if let result = testSubtrie {
            // Should get exact match and longer matches starting with "test"
            let keys = result.children.keys()
            #expect(keys.contains("")) // for "test"
            #expect(keys.contains("ing")) // for "testing"
            #expect(keys.contains("er")) // for "tester"
            #expect(!keys.contains("te")) // "te" doesn't start with "test"
        }
        
        // Traverse with prefix that's shorter than some keys
        let teSubtrie = trie.traverse(path: "te")
        #expect(teSubtrie != nil)
        if let result = teSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // for "te"
            #expect(keys.contains("st")) // for "test"
            #expect(keys.contains("sting")) // for "testing"
            #expect(keys.contains("ster")) // for "tester"
        }
    }
    
    @Test func testTraverseStringPathWithRootValue() {
        var trie = ArrayTrie<String>()
        
        // Set root value
        trie.set([], value: "Root Value")
        
        // Set regular values
        trie.set(["test"], value: "Test")
        trie.set(["temp"], value: "Temp")
        
        // Traverse should work correctly
        let testSubtrie = trie.traverse(path: "te")
        #expect(testSubtrie != nil)
        if let result = testSubtrie {
            // The traverse(path: String) method doesn't preserve original root values
            // It only sets root value if there's an empty string match in the traversed result
            #expect(result.get([]) == nil) // No root value expected for this traversal
            // Should contain the filtered keys
            let keys = result.children.keys()
            #expect(keys.contains("st"))
            #expect(keys.contains("mp"))
        }
        
        // Test with empty string traversal which should preserve structure
        let emptySubtrie = trie.traverse(path: "")
        #expect(emptySubtrie != nil)
        if let result = emptySubtrie {
            // Empty string traversal should include all keys including empty string key for root
            #expect(result.get(["test"]) == "Test")
            #expect(result.get(["temp"]) == "Temp")
        }
    }
    
    @Test func testTraverseStringPathAfterOperations() {
        var trie = ArrayTrie<String>()
        
        // Set up initial data
        trie.set(["apple"], value: "Apple")
        trie.set(["application"], value: "Application")
        trie.set(["banana"], value: "Banana")
        
        // Traverse and verify
        var subtrie = trie.traverse(path: "app")
        #expect(subtrie != nil)
        
        // Delete a key and traverse again
        trie = trie.deleting(path: ["apple"])
        subtrie = trie.traverse(path: "app")
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(!keys.contains("le")) // "apple" was deleted
            #expect(keys.contains("lication")) // "application" should remain
        }
        
        // Add new key and traverse again
        trie.set(["approach"], value: "Approach")
        subtrie = trie.traverse(path: "app")
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(keys.contains("lication"))
            #expect(keys.contains("roach")) // new key should be included
        }
    }
    
    @Test func testTraverseStringPathPerformance() {
        var trie = ArrayTrie<String>()
        
        // Add many keys with common prefix
        for i in 0..<1000 {
            trie.set(["prefix\(i)"], value: "Value \(i)")
        }
        
        // Add keys with different prefixes
        for i in 0..<100 {
            trie.set(["other\(i)"], value: "Other \(i)")
        }
        
        // Traverse with common prefix
        let subtrie = trie.traverse(path: "prefix")
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(!result.isEmpty())
            // Should contain all 1000 keys starting with "prefix"
            let keys = result.children.keys()
            #expect(keys.count >= 1000) // at least the numbered suffixes
        }
        
        // Traverse with less common prefix
        let otherSubtrie = trie.traverse(path: "other")
        #expect(otherSubtrie != nil)
        if let result = otherSubtrie {
            let keys = result.children.keys()
            #expect(keys.count >= 100) // at least the numbered suffixes
        }
    }
    
    @Test func testTraverseStringPathEdgeCases() {
        var trie = ArrayTrie<String>()
        
        // Set up edge cases
        trie.set([" "], value: "Space")
        trie.set(["\t"], value: "Tab")
        trie.set(["\n"], value: "Newline")
        trie.set(["normal"], value: "Normal")
        
        // Traverse with space
        let spaceSubtrie = trie.traverse(path: " ")
        #expect(spaceSubtrie != nil)
        
        // Traverse with tab
        let tabSubtrie = trie.traverse(path: "\t")
        #expect(tabSubtrie != nil)
        
        // Traverse with newline
        let newlineSubtrie = trie.traverse(path: "\n")
        #expect(newlineSubtrie != nil)
        
        // All should return valid subtries
        #expect(spaceSubtrie?.get([""]) == "Space")
        #expect(tabSubtrie?.get([""]) == "Tab")
        #expect(newlineSubtrie?.get([""]) == "Newline")
    }
    
    @Test func testTraverseStringPathLongPrefix() {
        var trie = ArrayTrie<String>()
        
        // Set up with very long common prefix
        let longPrefix = String(repeating: "a", count: 100)
        trie.set([longPrefix], value: "Long A's")
        trie.set([longPrefix + "b"], value: "Long A's + B")
        trie.set([longPrefix + "c"], value: "Long A's + C")
        trie.set(["different"], value: "Different")
        
        // Traverse with the long prefix
        let subtrie = trie.traverse(path: longPrefix)
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(keys.contains("")) // exact match
            #expect(keys.contains("b")) // suffix for longPrefix + "b"
            #expect(keys.contains("c")) // suffix for longPrefix + "c"
            #expect(!keys.contains("different")) // unrelated key
        }
    }
    
    // MARK: - String Path Traversal Values and Contents Tests
    
    @Test func testTraverseStringPathGetValues() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with various paths and values
        trie.set(["user"], value: "User Root")
        trie.set(["users"], value: "Users Plural")
        trie.set(["user_profile"], value: "User Profile")
        trie.set(["user_settings"], value: "User Settings")
        trie.set(["username"], value: "Username")
        trie.set(["admin"], value: "Admin")
        
        // Traverse with "user"
        let userSubtrie = trie.traverse(path: "user")
        #expect(userSubtrie != nil)
        
        if let result = userSubtrie {
            // Test getting values using the remaining suffixes
            #expect(result.get([""]) == "User Root")  // exact match for "user"
            #expect(result.get(["s"]) == "Users Plural")  // for "users"
            #expect(result.get(["_profile"]) == "User Profile")  // for "user_profile"
            #expect(result.get(["_settings"]) == "User Settings")  // for "user_settings"
            #expect(result.get(["name"]) == "Username")  // for "username"
            
            // Non-existent paths should return nil
            #expect(result.get(["admin"]) == nil)  // "admin" doesn't start with "user"
            #expect(result.get(["xyz"]) == nil)  // doesn't exist
        }
    }
    
    @Test func testTraverseStringPathVerifyContents() {
        var trie = ArrayTrie<String>()
        
        // Set up hierarchical structure
        trie.set(["api", "v1", "users"], value: "V1 Users")
        trie.set(["api", "v2", "users"], value: "V2 Users")
        trie.set(["api", "v1", "posts"], value: "V1 Posts")
        trie.set(["app"], value: "Application")
        trie.set(["apple"], value: "Fruit")
        trie.set(["application"], value: "Full App")
        
        // Traverse with "app"
        let appSubtrie = trie.traverse(path: "app")
        #expect(appSubtrie != nil)
        
        if let result = appSubtrie {
            // Verify the structure contains expected keys
            let childKeys = result.children.keys()
            #expect(childKeys.contains(""))  // for "app"
            #expect(childKeys.contains("le"))  // for "apple"  
            #expect(childKeys.contains("lication"))  // for "application"
            
            // Verify we can get the correct values
            #expect(result.get([""]) == "Application")
            #expect(result.get(["le"]) == "Fruit")
            #expect(result.get(["lication"]) == "Full App")
            
            // Verify API paths are not included (don't start with "app")
            #expect(result.get(["api", "v1", "users"]) == nil)
            #expect(!result.isEmpty())
        }
        
        // Traverse with "api" and verify hierarchical structure is preserved
        let apiSubtrie = trie.traverse(path: "api")
        #expect(apiSubtrie != nil)
        
        if let result = apiSubtrie {
            // The traversed trie should contain the original hierarchical structure
            // but without the "api" prefix
            let childKeys = result.children.keys()
            #expect(childKeys.contains(""))  // There should be an exact match path
            
            // However, the original API structure should be accessible through some means
            // Since the path was "api", we should be able to access the nested structure
            #expect(!result.isEmpty())
        }
    }
    
    @Test func testTraverseStringPathComplexValueRetrieval() {
        var trie = ArrayTrie<String>()
        
        // Set up complex nested structure with overlapping prefixes
        trie.set(["test"], value: "Test Base")
        trie.set(["testing"], value: "Testing Activity")  
        trie.set(["tester"], value: "Person Who Tests")
        trie.set(["test_case"], value: "Test Case")
        trie.set(["test_suite"], value: "Test Suite")
        trie.set(["template"], value: "Template")
        trie.set(["temporary"], value: "Temporary")
        trie.set(["ten"], value: "Number Ten")
        
        // Traverse with "test"
        let testSubtrie = trie.traverse(path: "test")
        #expect(testSubtrie != nil)
        
        if let result = testSubtrie {
            // Verify all "test*" values are accessible
            #expect(result.get([""]) == "Test Base")
            #expect(result.get(["ing"]) == "Testing Activity")
            #expect(result.get(["er"]) == "Person Who Tests")
            #expect(result.get(["_case"]) == "Test Case")
            #expect(result.get(["_suite"]) == "Test Suite")
            
            // Verify non-"test*" values are not accessible
            #expect(result.get(["template"]) == nil)
            #expect(result.get(["temporary"]) == nil)
            #expect(result.get(["ten"]) == nil)
            
            // Verify the structure
            let keys = result.children.keys()
            #expect(keys.contains(""))  // for "test"
            #expect(keys.contains("ing"))  // for "testing"
            #expect(keys.contains("er"))  // for "tester" 
            #expect(keys.contains("_case"))  // for "test_case"
            #expect(keys.contains("_suite"))  // for "test_suite"
            #expect(!keys.contains("template"))  // shouldn't be there
        }
        
        // Traverse with "te" to get broader set
        let teSubtrie = trie.traverse(path: "te")
        #expect(teSubtrie != nil)
        
        if let result = teSubtrie {
            // Should include all "te*" values
            #expect(result.get(["st"]) == "Test Base")
            #expect(result.get(["sting"]) == "Testing Activity")
            #expect(result.get(["ster"]) == "Person Who Tests")
            #expect(result.get(["mplate"]) == "Template")
            #expect(result.get(["mporary"]) == "Temporary")
            #expect(result.get(["n"]) == "Number Ten")
            
            let keys = result.children.keys()
            #expect(keys.contains("st"))  // for "test"
            #expect(keys.contains("mplate"))  // for "template"
            #expect(keys.contains("n"))  // for "ten"
        }
    }
    
    @Test func testTraverseStringPathOperationsOnResult() {
        var trie = ArrayTrie<String>()
        
        // Set up initial structure
        trie.set(["prefix_a"], value: "A")
        trie.set(["prefix_b"], value: "B")
        trie.set(["prefix_c"], value: "C")
        trie.set(["other"], value: "Other")
        
        // Traverse to get subtrie
        let subtrie = trie.traverse(path: "prefix")
        #expect(subtrie != nil)
        
        if var result = subtrie {
            // Test that we can perform operations on the traversed trie
            #expect(result.get(["_a"]) == "A")
            #expect(result.get(["_b"]) == "B")
            #expect(result.get(["_c"]) == "C")
            #expect(result.get(["other"]) == nil)  // not in this subtrie
            
            // Test that we can modify the traversed trie
            result.set(["_d"], value: "D")
            #expect(result.get(["_d"]) == "D")
            
            // Verify the modification doesn't affect the original trie
            #expect(trie.get(["prefix_d"]) == nil)  // original unchanged
            #expect(trie.get(["prefix_a"]) == "A")  // original still has this
            
            // Test deletion on the traversed trie
            let deletedResult = result.deleting(path: ["_a"])
            #expect(deletedResult.get(["_a"]) == nil)
            #expect(deletedResult.get(["_b"]) == "B")  // others remain
            
            // Original trie should be unchanged
            #expect(trie.get(["prefix_a"]) == "A")
            
            // Test isEmpty on traversed trie
            #expect(!result.isEmpty())
            
            // Create an empty traversed trie
            let emptySubtrie = trie.traverse(path: "nonexistent")
            #expect(emptySubtrie == nil)
        }
    }
    
    @Test func testTraverseStringPathNestedTraversals() {
        var trie = ArrayTrie<String>()
        
        // Set up simpler structure for clearer testing
        trie.set(["prefix_group1_item1"], value: "Group1 Item1")
        trie.set(["prefix_group1_item2"], value: "Group1 Item2")
        trie.set(["prefix_group2_item1"], value: "Group2 Item1")
        trie.set(["prefix_other"], value: "Other")
        trie.set(["different"], value: "Different")
        
        // First traversal: narrow down to "prefix"
        let prefixTrie = trie.traverse(path: "prefix")
        #expect(prefixTrie != nil)
        
        if let pTrie = prefixTrie {
            // Should contain all "prefix*" entries with prefix removed
            #expect(pTrie.get(["_group1_item1"]) == "Group1 Item1")
            #expect(pTrie.get(["_group1_item2"]) == "Group1 Item2")
            #expect(pTrie.get(["_group2_item1"]) == "Group2 Item1")
            #expect(pTrie.get(["_other"]) == "Other")
            
            // Should not contain non-prefix entries
            #expect(pTrie.get(["different"]) == nil)
            
            // Now traverse within the traversed trie to narrow to "group1"
            let group1Trie = pTrie.traverse(path: "_group1")
            #expect(group1Trie != nil)
            
            if let g1Trie = group1Trie {
                // This should only contain "group1" related entries
                #expect(g1Trie.get(["_item1"]) == "Group1 Item1")
                #expect(g1Trie.get(["_item2"]) == "Group1 Item2")
                
                // Should not contain group2 or other items
                #expect(g1Trie.get(["_group2_item1"]) == nil)
                #expect(g1Trie.get(["_other"]) == nil)
                
                // Test further nested traversal to get just items
                let itemTrie = g1Trie.traverse(path: "_item")
                #expect(itemTrie != nil)
                
                if let iTrie = itemTrie {
                    #expect(iTrie.get(["1"]) == "Group1 Item1")
                    #expect(iTrie.get(["2"]) == "Group1 Item2")
                }
            }
            
            // Test parallel traversal for group2
            let group2Trie = pTrie.traverse(path: "_group2")
            #expect(group2Trie != nil)
            
            if let g2Trie = group2Trie {
                #expect(g2Trie.get(["_item1"]) == "Group2 Item1")
                // Should not contain group1 items
                #expect(g2Trie.get(["_group1_item1"]) == nil)
            }
        }
    }
    
    @Test func testTraverseStringPathWithDifferentValueTypes() {
        var intTrie = ArrayTrie<Int>()
        var arrayTrie = ArrayTrie<[String]>()
        
        // Set up integer trie
        intTrie.set(["count_1"], value: 1)
        intTrie.set(["count_10"], value: 10)
        intTrie.set(["count_100"], value: 100)
        intTrie.set(["total"], value: 111)
        
        // Traverse integer trie
        let countTrie = intTrie.traverse(path: "count")
        #expect(countTrie != nil)
        
        if let result = countTrie {
            #expect(result.get(["_1"]) == 1)
            #expect(result.get(["_10"]) == 10)
            #expect(result.get(["_100"]) == 100)
            #expect(result.get(["total"]) == nil)  // doesn't start with "count"
            
            // Verify we can perform arithmetic operations
            let sum = (result.get(["_1"]) ?? 0) + (result.get(["_10"]) ?? 0) + (result.get(["_100"]) ?? 0)
            #expect(sum == 111)
        }
        
        // Set up array trie
        arrayTrie.set(["tags_red"], value: ["red", "color", "primary"])
        arrayTrie.set(["tags_blue"], value: ["blue", "color", "primary"])
        arrayTrie.set(["tags_green"], value: ["green", "color", "secondary"])
        arrayTrie.set(["categories"], value: ["misc"])
        
        // Traverse array trie
        let tagsTrie = arrayTrie.traverse(path: "tags")
        #expect(tagsTrie != nil)
        
        if let result = tagsTrie {
            #expect(result.get(["_red"]) == ["red", "color", "primary"])
            #expect(result.get(["_blue"]) == ["blue", "color", "primary"])
            #expect(result.get(["_green"]) == ["green", "color", "secondary"])
            #expect(result.get(["categories"]) == nil)
            
            // Verify array operations work
            let redTags = result.get(["_red"]) ?? []
            #expect(redTags.count == 3)
            #expect(redTags.contains("red"))
            #expect(redTags.contains("color"))
        }
    }
    
    @Test func testTraverseStringPathEmptyAndExactMatches() {
        var trie = ArrayTrie<String>()
        
        // Set up with empty string and exact matches
        trie.set([""], value: "Empty Root")
        trie.set(["search"], value: "Search Exact")
        trie.set(["search_query"], value: "Search Query")
        trie.set(["search_results"], value: "Search Results")
        
        // Traverse with empty string
        let emptyTraversal = trie.traverse(path: "")
        #expect(emptyTraversal != nil)
        
        if let result = emptyTraversal {
            // Empty string traversal should return everything
            #expect(result.get([""]) == "Empty Root")
            #expect(result.get(["search"]) == "Search Exact")
            #expect(result.get(["search_query"]) == "Search Query")
            #expect(result.get(["search_results"]) == "Search Results")
        }
        
        // Traverse with exact match
        let searchTraversal = trie.traverse(path: "search")
        #expect(searchTraversal != nil)
        
        if let result = searchTraversal {
            // Should get exact match and extensions
            #expect(result.get([""]) == "Search Exact")
            #expect(result.get(["_query"]) == "Search Query")
            #expect(result.get(["_results"]) == "Search Results")
            
            // Should not get the empty root or unrelated entries
            #expect(result.get(["empty"]) == nil)
            
            // Verify keys structure
            let keys = result.children.keys()
            #expect(keys.contains(""))  // exact match
            #expect(keys.contains("_query"))
            #expect(keys.contains("_results"))
            #expect(keys.count == 3)
        }
    }
    
    @Test func testTraverseStringPathStructuralIntegrity() {
        var trie = ArrayTrie<String>()
        
        // Set up complex overlapping structure
        trie.set(["a"], value: "A")
        trie.set(["ab"], value: "AB") 
        trie.set(["abc"], value: "ABC")
        trie.set(["abcd"], value: "ABCD")
        trie.set(["ab_test"], value: "AB Test")
        trie.set(["ac"], value: "AC")
        trie.set(["b"], value: "B")
        
        // Test traversal at different levels
        let aTraversal = trie.traverse(path: "a")
        #expect(aTraversal != nil)
        
        if let aResult = aTraversal {
            // Verify complete "a*" structure
            #expect(aResult.get([""]) == "A")
            #expect(aResult.get(["b"]) == "AB")
            #expect(aResult.get(["bc"]) == "ABC")
            #expect(aResult.get(["bcd"]) == "ABCD")
            #expect(aResult.get(["b_test"]) == "AB Test")
            #expect(aResult.get(["c"]) == "AC")
            
            // Should not contain "b"
            #expect(aResult.get(["B"]) == nil)
            
            // Verify structure is properly nested
            let keys = aResult.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("b"))
            #expect(keys.contains("c"))
            #expect(!keys.contains("B"))  // case sensitive
            
            // Test further traversal
            let abTraversal = aResult.traverse(path: "b")
            #expect(abTraversal != nil)
            
            if let abResult = abTraversal {
                #expect(abResult.get([""]) == "AB")
                #expect(abResult.get(["c"]) == "ABC")
                #expect(abResult.get(["cd"]) == "ABCD")
                #expect(abResult.get(["_test"]) == "AB Test")
                
                // Should not contain "ac" branch
                #expect(abResult.get(["c"]) == "ABC")  // this is "abc"
                #expect(abResult.get(["AC"]) == nil)   // this would be from original "ac"
            }
        }
    }
    
    @Test func testTraverseStringPathMemoryAndReferences() {
        var trie = ArrayTrie<String>()
        
        // Set up reference data
        let largeString = String(repeating: "data", count: 1000)
        trie.set(["large_data_1"], value: largeString + "_1")
        trie.set(["large_data_2"], value: largeString + "_2") 
        trie.set(["small"], value: "small")
        
        // Traverse to get subtrie
        let largeTraversal = trie.traverse(path: "large")
        #expect(largeTraversal != nil)
        
        if let result = largeTraversal {
            // Verify the large data is accessible
            #expect(result.get(["_data_1"]) == largeString + "_1")
            #expect(result.get(["_data_2"]) == largeString + "_2")
            #expect(result.get(["small"]) == nil)
            
            // Verify the traversed trie is independent
            var mutableResult = result
            mutableResult.set(["_data_3"], value: largeString + "_3")
            
            // New value should be in the traversed trie
            #expect(mutableResult.get(["_data_3"]) == largeString + "_3")
            
            // But not in the original trie
            #expect(trie.get(["large_data_3"]) == nil)
            
            // Original values should still be accessible in original trie
            #expect(trie.get(["large_data_1"]) == largeString + "_1")
            #expect(trie.get(["small"]) == "small")
        }
    }
    
    @Test func testTraverseStringPathCompleteValueValidation() {
        var trie = ArrayTrie<String>()
        
        // Create comprehensive test data
        let testData = [
            ("user", "User"),
            ("user_admin", "User Admin"),
            ("user_guest", "User Guest"),
            ("users", "Multiple Users"),
            ("username", "Username Field"),
            ("utility", "Utility Function"),
            ("utils", "Utilities"),
            ("completely_different", "Different")
        ]
        
        for (path, value) in testData {
            trie.set([path], value: value)
        }
        
        // Traverse with "user"
        let userTraversal = trie.traverse(path: "user")
        #expect(userTraversal != nil)
        
        if let result = userTraversal {
            // Test every expected value
            #expect(result.get([""]) == "User")
            #expect(result.get(["_admin"]) == "User Admin")
            #expect(result.get(["_guest"]) == "User Guest")
            #expect(result.get(["s"]) == "Multiple Users")
            #expect(result.get(["name"]) == "Username Field")
            
            // Test values that should NOT be there
            #expect(result.get(["utility"]) == nil)
            #expect(result.get(["utils"]) == nil)
            #expect(result.get(["completely_different"]) == nil)
            
            // Verify complete structure
            let allKeys = result.children.keys()
            let expectedKeys = ["", "_admin", "_guest", "s", "name"]
            #expect(allKeys.count == expectedKeys.count)
            
            for key in expectedKeys {
                #expect(allKeys.contains(key), "Expected key '\(key)' not found")
            }
            
            // Test that we can traverse the traversed result further
            let userAdminTraversal = result.traverse(path: "_")
            #expect(userAdminTraversal != nil)
            
            if let adminResult = userAdminTraversal {
                #expect(adminResult.get(["admin"]) == "User Admin")
                #expect(adminResult.get(["guest"]) == "User Guest")
                #expect(adminResult.get(["s"]) == nil)  // "_s" doesn't exist
            }
        }
        
        // Test broader traversal
        let uTraversal = trie.traverse(path: "u")
        #expect(uTraversal != nil)
        
        if let result = uTraversal {
            // Should contain all "u*" entries
            #expect(result.get(["ser"]) == "User")
            #expect(result.get(["tility"]) == "Utility Function")
            #expect(result.get(["tils"]) == "Utilities")
            #expect(result.get(["sers"]) == "Multiple Users")
            
            // Should not contain non-"u*" entries
            #expect(result.get(["completely_different"]) == nil)
        }
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
    
    // MARK: - GetValuesOneLevelDeep Tests
    
    @Test func testGetValuesOneLevelDeepEmpty() {
        let trie = ArrayTrie<String>()
        
        let values = trie.getValuesOneLevelDeep()
        
        #expect(values.isEmpty)
    }
    
    @Test func testGetValuesOneLevelDeepSingleLevel() {
        var trie = ArrayTrie<String>()
        
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        trie.set(["guest"], value: "Guest Data")
        
        let values = trie.getValuesOneLevelDeep()
        
        #expect(values.count == 3)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(values.contains("Guest Data"))
    }
    
    @Test func testGetValuesOneLevelDeepWithDeepPaths() {
        var trie = ArrayTrie<String>()
        
        // Single level paths
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        
        // Multi-level paths should be excluded
        trie.set(["user", "profile"], value: "Profile Data")
        trie.set(["user", "settings"], value: "Settings Data")
        trie.set(["admin", "permissions"], value: "Permissions Data")
        
        let values = trie.getValuesOneLevelDeep()
        
        // Should only return values from single-level paths
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(!values.contains("Profile Data"))
        #expect(!values.contains("Settings Data"))
        #expect(!values.contains("Permissions Data"))
    }
    
    @Test func testGetValuesOneLevelDeepWithNilValues() {
        var trie = ArrayTrie<String>()
        
        // Set some values
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        
        // Create paths without values (intermediate nodes)
        trie.set(["user", "profile"], value: "Profile Data")
        trie.set(["guest", "info"], value: "Guest Info")
        
        let values = trie.getValuesOneLevelDeep()
        
        // Should only include nodes with values at single level
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(!values.contains("Profile Data"))
        #expect(!values.contains("Guest Info"))
    }
    
    @Test func testGetValuesOneLevelDeepMixedTypes() {
        var intTrie = ArrayTrie<Int>()
        var boolTrie = ArrayTrie<Bool>()
        
        intTrie.set(["count"], value: 42)
        intTrie.set(["total"], value: 100)
        intTrie.set(["deep", "value"], value: 999)
        
        boolTrie.set(["enabled"], value: true)
        boolTrie.set(["disabled"], value: false)
        boolTrie.set(["nested", "flag"], value: true)
        
        let intValues = intTrie.getValuesOneLevelDeep()
        let boolValues = boolTrie.getValuesOneLevelDeep()
        
        #expect(intValues.count == 2)
        #expect(intValues.contains(42))
        #expect(intValues.contains(100))
        #expect(!intValues.contains(999))
        
        #expect(boolValues.count == 2)
        #expect(boolValues.contains(true))
        #expect(boolValues.contains(false))
    }
    
    @Test func testGetValuesOneLevelDeepAfterDeletion() {
        var trie = ArrayTrie<String>()
        
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        trie.set(["guest"], value: "Guest Data")
        
        var values = trie.getValuesOneLevelDeep()
        #expect(values.count == 3)
        
        // Delete one path
        trie = trie.deleting(path: ["admin"])
        values = trie.getValuesOneLevelDeep()
        
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Guest Data"))
        #expect(!values.contains("Admin Data"))
    }
    
    @Test func testGetValuesOneLevelDeepWithRootValue() {
        var trie = ArrayTrie<String>()
        
        // Set root value
        trie.set([], value: "Root Value")
        
        // Set single level values
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        
        let values = trie.getValuesOneLevelDeep()
        
        // Root value should not be included in one-level-deep results
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(!values.contains("Root Value"))
    }
    
    @Test func testGetValuesOneLevelDeepEmptyStrings() {
        var trie = ArrayTrie<String>()
        
        trie.set([""], value: "Empty String Value")
        trie.set(["user"], value: "User Data")
        trie.set(["", "nested"], value: "Nested Under Empty")
        
        let values = trie.getValuesOneLevelDeep()
        
        #expect(values.count == 2)
        #expect(values.contains("Empty String Value"))
        #expect(values.contains("User Data"))
        #expect(!values.contains("Nested Under Empty"))
    }
    
    @Test func testGetValuesOneLevelDeepAfterMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["user"], value: "User1")
        trie1.set(["admin"], value: "Admin1")
        
        trie2.set(["user"], value: "User2")
        trie2.set(["guest"], value: "Guest2")
        
        let merged = trie1.merging(with: trie2) { a, b in "\(a)+\(b)" }
        let values = merged.getValuesOneLevelDeep()
        
        #expect(values.count == 3)
        #expect(values.contains("User1+User2"))
        #expect(values.contains("Admin1"))
        #expect(values.contains("Guest2"))
    }
    
    @Test func testGetValuesOneLevelDeepPerformance() {
        var trie = ArrayTrie<Int>()
        
        // Add many single-level values
        for i in 0..<1000 {
            trie.set(["item\(i)"], value: i)
        }
        
        // Add some multi-level values
        for i in 0..<100 {
            trie.set(["deep", "item\(i)"], value: i + 10000)
        }
        
        let values = trie.getValuesOneLevelDeep()
        
        // Should only contain single-level values
        #expect(values.count == 1000)
        for i in 0..<1000 {
            #expect(values.contains(i))
        }
        
        // Should not contain multi-level values
        for i in 0..<100 {
            #expect(!values.contains(i + 10000))
        }
    }
    
    @Test func testGetValuesOneLevelDeepOrder() {
        var trie = ArrayTrie<String>()
        
        trie.set(["zebra"], value: "Z")
        trie.set(["apple"], value: "A")
        trie.set(["banana"], value: "B")
        
        let values = trie.getValuesOneLevelDeep()
        
        // Values should be present regardless of insertion order
        #expect(values.count == 3)
        #expect(values.contains("Z"))
        #expect(values.contains("A"))
        #expect(values.contains("B"))
    }
    
    // MARK: - TraverseChild Tests
    
    @Test func testTraverseChildBasic() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys starting with different characters
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["apricot"], value: "APRICOT")
        
        // Traverse child with 'a'
        let result = trie.traverseChild("a")
        
        #expect(result != nil)
        if let subtrie = result {
            // Should find keys starting with 'a' in the children
            #expect(!subtrie.isEmpty())
            // The subtrie should maintain the root value (if any) and have filtered children
            let keys = subtrie.children.keys()
            #expect(!keys.isEmpty)
        }
    }
    
    @Test func testTraverseChildNonExistent() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys not starting with 'z'
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        
        // Traverse child with character not in trie
        let result = trie.traverseChild("z")
        
        #expect(result == nil)
    }
    
    @Test func testTraverseChildEmptyTrie() {
        let trie = ArrayTrie<String>()
        
        // Traverse empty trie
        let result = trie.traverseChild("a")
        
        #expect(result == nil)
    }
    
    @Test func testTraverseChildSingleCharacterKeys() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with single character keys
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        trie.set(["c"], value: "C")
        
        let resultA = trie.traverseChild("a")
        let resultB = trie.traverseChild("b")
        
        #expect(resultA != nil)
        #expect(resultB != nil)
        
        if let subtrieA = resultA {
            #expect(!subtrieA.isEmpty())
        }
        
        if let subtrieB = resultB {
            #expect(!subtrieB.isEmpty())
        }
    }
    
    @Test func testTraverseChildPreservesRootValue() {
        var trie = ArrayTrie<String>()
        
        // Set root value
        trie.set([], value: "ROOT")
        
        // Set up the trie with keys
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        
        let result = trie.traverseChild("a")
        
        #expect(result != nil)
        if let subtrie = result {
            // Root value should be preserved
            #expect(subtrie.get([]) == "ROOT")
        }
    }
    
    @Test func testTraverseChildMultiplePrefixes() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with multiple keys starting with same character
        trie.set(["test"], value: "TEST")
        trie.set(["team"], value: "TEAM")
        trie.set(["tea"], value: "TEA")
        trie.set(["tree"], value: "TREE")
        
        let result = trie.traverseChild("t")
        
        #expect(result != nil)
        if let subtrie = result {
            #expect(!subtrie.isEmpty())
            // Should have filtered children for keys starting with 't'
            let keys = subtrie.children.keys()
            #expect(!keys.isEmpty)
        }
    }
    
    @Test func testTraverseChildSpecialCharacters() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with special characters
        trie.set(["@mention"], value: "MENTION")
        trie.set(["#hashtag"], value: "HASHTAG")
        trie.set(["$dollar"], value: "DOLLAR")
        
        let mentionResult = trie.traverseChild("@")
        let hashResult = trie.traverseChild("#")
        let dollarResult = trie.traverseChild("$")
        
        #expect(mentionResult != nil)
        #expect(hashResult != nil)
        #expect(dollarResult != nil)
    }
    
    @Test func testTraverseChildAfterMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["apple"], value: "APPLE1")
        trie1.set(["banana"], value: "BANANA1")
        
        trie2.set(["apricot"], value: "APRICOT2")
        trie2.set(["cherry"], value: "CHERRY2")
        
        let merged = trie1.merging(with: trie2) { a, b in a }
        let result = merged.traverseChild("a")
        
        #expect(result != nil)
        if let subtrie = result {
            #expect(!subtrie.isEmpty())
        }
    }
    
    @Test func testTraverseChildMultipleTypes() {
        var intTrie = ArrayTrie<Int>()
        var stringTrie = ArrayTrie<String>()
        
        intTrie.set(["number"], value: 42)
        intTrie.set(["negative"], value: -1)
        
        stringTrie.set(["name"], value: "John")
        stringTrie.set(["null"], value: "NULL")
        
        let intResult = intTrie.traverseChild("n")
        let stringResult = stringTrie.traverseChild("n")
        
        #expect(intResult != nil)
        #expect(stringResult != nil)
    }
    
    // MARK: - GetAllChildCharacters Tests
    
    @Test func testGetAllChildCharactersBasic() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys starting with different characters
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["cherry"], value: "CHERRY")
        trie.set(["apricot"], value: "APRICOT")
        
        let characters = trie.getAllChildCharacters()
        
        #expect(characters.count >= 3) // at least a, b, c
        #expect(characters.contains("a"))
        #expect(characters.contains("b"))
        #expect(characters.contains("c"))
    }
    
    @Test func testGetAllChildCharactersEmpty() {
        let trie = ArrayTrie<String>()
        
        let characters = trie.getAllChildCharacters()
        
        #expect(characters.isEmpty)
    }
    
    @Test func testGetAllChildCharactersSingleKey() {
        var trie = ArrayTrie<String>()
        
        trie.set(["test"], value: "TEST")
        
        let characters = trie.getAllChildCharacters()
        
        #expect(characters.count >= 1)
        #expect(characters.contains("t"))
    }
    
    @Test func testGetAllChildCharactersSpecialCharacters() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with special characters
        trie.set(["@mention"], value: "MENTION")
        trie.set(["#hashtag"], value: "HASHTAG")
        trie.set(["$dollar"], value: "DOLLAR")
        trie.set(["123number"], value: "NUMBER")
        
        let characters = trie.getAllChildCharacters()
        
        #expect(characters.contains("@"))
        #expect(characters.contains("#"))
        #expect(characters.contains("$"))
        #expect(characters.contains("1"))
    }
    
    @Test func testGetAllChildCharactersUnicode() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with Unicode characters
        trie.set(["café"], value: "CAFE")
        trie.set(["naïve"], value: "NAIVE")
        trie.set(["résumé"], value: "RESUME")
        trie.set(["🙂emoji"], value: "EMOJI")
        
        let characters = trie.getAllChildCharacters()
        
        #expect(characters.contains("c"))
        #expect(characters.contains("n"))
        #expect(characters.contains("r"))
        #expect(characters.contains("🙂"))
    }
    
    @Test func testGetAllChildCharactersDuplicates() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with keys that start with same character
        trie.set(["apple"], value: "APPLE")
        trie.set(["apricot"], value: "APRICOT")
        trie.set(["avocado"], value: "AVOCADO")
        
        let characters = trie.getAllChildCharacters()
        
        // Should not contain duplicates
        let uniqueCharacters = Array(Set(characters))
        #expect(characters.count == uniqueCharacters.count)
        
        #expect(characters.contains("a"))
    }
    
    @Test func testGetAllChildCharactersAfterDeletion() {
        var trie = ArrayTrie<String>()
        
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["cherry"], value: "CHERRY")
        
        var characters = trie.getAllChildCharacters()
        let originalCount = characters.count
        #expect(characters.contains("b"))
        
        // Delete banana
        trie = trie.deleting(path: ["banana"])
        characters = trie.getAllChildCharacters()
        
        // Should have fewer characters if 'b' was only from banana
        #expect(characters.count <= originalCount)
        
        // Should still contain 'a' and 'c'
        #expect(characters.contains("a"))
        #expect(characters.contains("c"))
    }
    
    @Test func testGetAllChildCharactersAfterMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        
        trie1.set(["apple"], value: "APPLE")
        trie1.set(["banana"], value: "BANANA")
        
        trie2.set(["cherry"], value: "CHERRY")
        trie2.set(["date"], value: "DATE")
        
        let merged = trie1.merging(with: trie2) { a, b in a }
        let characters = merged.getAllChildCharacters()
        
        #expect(characters.contains("a"))
        #expect(characters.contains("b"))
        #expect(characters.contains("c"))
        #expect(characters.contains("d"))
    }
    
    @Test func testGetAllChildCharactersEmptyStringKeys() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with empty string key and regular keys
        trie.set([""], value: "EMPTY")
        trie.set(["test"], value: "TEST")
        
        let characters = trie.getAllChildCharacters()
        
        #expect(characters.contains("t"))
        // Empty string should contribute its first character, but it's empty
        // So we shouldn't see any additional character from the empty string key
    }
    
    @Test func testGetAllChildCharactersPerformance() {
        var trie = ArrayTrie<Int>()
        
        // Add many keys with different starting characters
        for i in 0..<1000 {
            let key = "key\(i % 26)_\(i)"
            trie.set([key], value: i)
        }
        
        let characters = trie.getAllChildCharacters()
        
        // Should contain 'k' (from "key...")
        #expect(characters.contains("k"))
        
        // Should not have too many duplicates
        let uniqueCharacters = Array(Set(characters))
        #expect(characters.count == uniqueCharacters.count)
    }
    
    @Test func testGetAllChildCharactersOrder() {
        var trie = ArrayTrie<String>()
        
        // Insert in specific order
        trie.set(["zebra"], value: "Z")
        trie.set(["apple"], value: "A")
        trie.set(["banana"], value: "B")
        
        let characters = trie.getAllChildCharacters()
        
        // Should contain all characters regardless of insertion order
        #expect(characters.contains("z"))
        #expect(characters.contains("a"))
        #expect(characters.contains("b"))
    }
    
    @Test func testGetAllChildCharactersMultipleTypes() {
        var stringTrie = ArrayTrie<String>()
        var intTrie = ArrayTrie<Int>()
        
        stringTrie.set(["string"], value: "STRING")
        stringTrie.set(["text"], value: "TEXT")
        
        intTrie.set(["number"], value: 42)
        intTrie.set(["negative"], value: -1)
        
        let stringChars = stringTrie.getAllChildCharacters()
        let intChars = intTrie.getAllChildCharacters()
        
        #expect(stringChars.contains("s"))
        #expect(stringChars.contains("t"))
        
        #expect(intChars.contains("n"))
    }
    
    @Test func testGetAllChildCharactersConsistency() {
        var trie = ArrayTrie<String>()
        
        trie.set(["test"], value: "TEST")
        trie.set(["temp"], value: "TEMP")
        trie.set(["tree"], value: "TREE")
        
        let characters1 = trie.getAllChildCharacters()
        let characters2 = trie.getAllChildCharacters()
        
        // Should be consistent across calls
        #expect(characters1.count == characters2.count)
        #expect(Set(characters1) == Set(characters2))
    }
    
    // MARK: - GetAllChildKeys Tests
    
    @Test func testGetAllChildKeysBasic() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with different keys
        trie.set(["users"], value: "USERS")
        trie.set(["admins"], value: "ADMINS")
        trie.set(["guests"], value: "GUESTS")
        
        let keys = trie.getAllChildKeys()
        
        #expect(keys.count == 3)
        #expect(keys.contains("users"))
        #expect(keys.contains("admins"))
        #expect(keys.contains("guests"))
    }
    
    @Test func testGetAllChildKeysEmpty() {
        let trie = ArrayTrie<String>()
        
        let keys = trie.getAllChildKeys()
        
        #expect(keys.isEmpty)
    }
    
    @Test func testGetAllChildKeysSingleKey() {
        var trie = ArrayTrie<String>()
        
        trie.set(["onlykey"], value: "VALUE")
        
        let keys = trie.getAllChildKeys()
        
        #expect(keys.count == 1)
        #expect(keys.contains("onlykey"))
    }
    
    @Test func testGetAllChildKeysWithEmptyString() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with empty string key and regular keys
        trie.set([""], value: "EMPTY")
        trie.set(["test"], value: "TEST")
        
        let keys = trie.getAllChildKeys()
        
        #expect(keys.count == 2)
        #expect(keys.contains(""))
        #expect(keys.contains("test"))
    }
    
    @Test func testGetAllChildKeysAfterDeletion() {
        var trie = ArrayTrie<String>()
        
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["cherry"], value: "CHERRY")
        
        var keys = trie.getAllChildKeys()
        #expect(keys.count == 3)
        #expect(keys.contains("banana"))
        
        // Delete banana
        trie = trie.deleting(path: ["banana"])
        
        keys = trie.getAllChildKeys()
        #expect(keys.count == 2)
        #expect(!keys.contains("banana"))
        #expect(keys.contains("apple"))
        #expect(keys.contains("cherry"))
    }
    
    @Test func testGetAllChildKeysWithNestedPaths() {
        var trie = ArrayTrie<String>()
        
        // Set up the trie with nested paths
        trie.set(["users", "john"], value: "JOHN")
        trie.set(["users", "jane"], value: "JANE")
        trie.set(["admins", "bob"], value: "BOB")
        
        // Root level should have users and admins
        let rootKeys = trie.getAllChildKeys()
        #expect(rootKeys.count == 2)
        #expect(rootKeys.contains("users"))
        #expect(rootKeys.contains("admins"))
        
        // Traverse to users subtrie and check its keys
        let usersSubtrie = trie.traverse(["users"])
        #expect(usersSubtrie != nil)
        if let usersSubtrie = usersSubtrie {
            let userKeys = usersSubtrie.getAllChildKeys()
            #expect(userKeys.count == 2)
            #expect(userKeys.contains("john"))
            #expect(userKeys.contains("jane"))
        }
    }
    
    @Test func testGetAllChildKeysConsistency() {
        var trie = ArrayTrie<String>()
        
        trie.set(["test"], value: "TEST")
        trie.set(["temp"], value: "TEMP")
        trie.set(["tree"], value: "TREE")
        
        let keys1 = trie.getAllChildKeys()
        let keys2 = trie.getAllChildKeys()
        
        // Should be consistent across calls
        #expect(keys1.count == keys2.count)
        #expect(Set(keys1) == Set(keys2))
    }
    
    // MARK: - getAllValues Tests
    
    @Test func testGetAllValuesEmpty() {
        let trie = ArrayTrie<String>()
        let values = trie.getAllValues()
        #expect(values.isEmpty)
    }
    
    @Test func testGetAllValuesRootOnly() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "root")
        
        let values = trie.getAllValues()
        #expect(values.count == 1)
        #expect(values[0] == "root")
    }
    
    @Test func testGetAllValuesSinglePath() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        
        let values = trie.getAllValues()
        #expect(values.count == 1)
        #expect(values[0] == "John Doe")
    }
    
    @Test func testGetAllValuesMultiplePaths() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["admins", "alice"], value: "Alice Admin")
        
        let values = trie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 3)
        #expect(valueSet == Set(["John Doe", "Jane Smith", "Alice Admin"]))
    }
    
    @Test func testGetAllValuesWithRootAndChildren() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "root")
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        
        let values = trie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 3)
        #expect(valueSet == Set(["root", "John Doe", "Jane Smith"]))
    }
    
    @Test func testGetAllValuesNestedPaths() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["a", "b"], value: "AB")
        trie.set(["a", "b", "c"], value: "ABC")
        trie.set(["a", "x"], value: "AX")
        
        let values = trie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 4)
        #expect(valueSet == Set(["A", "AB", "ABC", "AX"]))
    }
    
    @Test func testGetAllValuesAfterDeletion() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["admins", "alice"], value: "Alice Admin")
        
        // Delete one path
        trie = trie.deleting(path: ["users", "john"])
        
        let values = trie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 2)
        #expect(valueSet == Set(["Jane Smith", "Alice Admin"]))
    }
    
    @Test func testGetAllValuesAfterMerging() {
        var trie1 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John")
        trie1.set(["users", "jane"], value: "Jane")
        
        var trie2 = ArrayTrie<String>()
        trie2.set(["users", "bob"], value: "Bob")
        trie2.set(["admins", "alice"], value: "Alice")
        
        let mergedTrie = trie1.merging(with: trie2) { first, second in
            return first + "-" + second
        }
        
        let values = mergedTrie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 4)
        #expect(valueSet == Set(["John", "Jane", "Bob", "Alice"]))
    }
    
    @Test func testGetAllValuesWithConflictMerging() {
        var trie1 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John1")
        
        var trie2 = ArrayTrie<String>()
        trie2.set(["users", "john"], value: "John2")
        
        let mergedTrie = trie1.merging(with: trie2) { first, second in
            return first + "-" + second
        }
        
        let values = mergedTrie.getAllValues()
        
        #expect(values.count == 1)
        #expect(values[0] == "John1-John2")
    }
    
    @Test func testGetAllValuesWithDifferentTypes() {
        var trie = ArrayTrie<Int>()
        trie.set(["numbers", "one"], value: 1)
        trie.set(["numbers", "two"], value: 2)
        trie.set(["numbers", "three"], value: 3)
        
        let values = trie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 3)
        #expect(valueSet == Set([1, 2, 3]))
    }
    
    @Test func testGetAllValuesEmptyStringsInPath() {
        var trie = ArrayTrie<String>()
        trie.set(["", "empty"], value: "EmptyPrefix")
        trie.set(["empty", ""], value: "EmptySuffix")
        trie.set(["normal", "path"], value: "Normal")
        
        let values = trie.getAllValues()
        let valueSet = Set(values)
        
        #expect(values.count == 3)
        #expect(valueSet == Set(["EmptyPrefix", "EmptySuffix", "Normal"]))
    }
    
    @Test func testGetAllValuesPerformanceLargeTrie() {
        var trie = ArrayTrie<String>()
        
        // Create a large trie with 1000 values
        for i in 0..<1000 {
            trie.set(["level1", "level2", "item\(i)"], value: "Value\(i)")
        }
        
        let values = trie.getAllValues()
        
        #expect(values.count == 1000)
        
        // Verify all values are unique
        let valueSet = Set(values)
        #expect(valueSet.count == 1000)
        
        // Verify some sample values exist
        #expect(valueSet.contains("Value0"))
        #expect(valueSet.contains("Value500"))
        #expect(valueSet.contains("Value999"))
    }
    
    @Test func testGetAllValuesConsistency() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        trie.set(["c"], value: "C")
        
        // Multiple calls should return consistent results
        let values1 = trie.getAllValues()
        let values2 = trie.getAllValues()
        
        #expect(Set(values1) == Set(values2))
        #expect(values1.count == values2.count)
    }
    
    @Test func testGetAllValuesImmutability() {
        var originalTrie = ArrayTrie<String>()
        originalTrie.set(["test"], value: "Original")
        
        let originalValues = originalTrie.getAllValues()
        
        // Modify the trie
        originalTrie.set(["new"], value: "New")
        
        // Original values should not be affected
        #expect(originalValues.count == 1)
        #expect(originalValues[0] == "Original")
        
        // New values should include both
        let newValues = originalTrie.getAllValues()
        #expect(newValues.count == 2)
        #expect(Set(newValues) == Set(["Original", "New"]))
    }
    
}
