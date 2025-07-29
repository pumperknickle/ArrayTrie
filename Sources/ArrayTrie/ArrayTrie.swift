import TrieDictionary

/**
 * ArrayTrie - A trie data structure implementation that uses arrays of strings as keys.
 * This differs from traditional tries which typically use single characters as keys.
 * Instead, this implementation uses whole strings for each segment of the path.
 */
public struct ArrayTrie<Value> {
    /// Type aliases for cleaner code
    typealias Node = ArrayTrieNode<Value>
    typealias ChildMap = TrieDictionary<ArrayTrieNode<Value>>
    
    /// Dictionary of child nodes, keyed by string
    var children: ChildMap
    
    /**
     * Creates a new ArrayTrie with the specified children map.
     * @param children The initial children to use for this trie
     */
    init(children: ChildMap) {
        self.children = children
    }
    
    /**
     * Creates an empty ArrayTrie with no children.
     */
    public init() {
        self = Self(children: [:])
    }
    
    /**
     * Checks if the trie is empty (has no children).
     * @return True if the trie has no children, false otherwise
     */
    public func isEmpty() -> Bool {
        return children.count == 0
    }
    
    /**
     * Updates all children of this trie.
     * @param children The new children map
     */
    mutating func updateChildren(_ children: ChildMap) {
        self.children = children
    }
    
    /**
     * Updates or removes a specific child node.
     * @param key The key for the child to update
     * @param node The new node value, or nil to remove the child
     */
    mutating func updateChild(_ key: String, _ node: Node?) {
        children[key] = node
    }
    
    /**
     * Creates a new trie with a modified child node.
     * @param child The key for the child to update
     * @param node The new node value, or nil to remove the child
     * @return A new trie with the specified child added, updated, or removed
     */
    func with(child: String, node: Node?) -> Self {
        var newChildren = children
        newChildren[child] = node
        return Self(children: newChildren)
    }
    
    /**
     * Traverses the trie following the specified path.
     * @param path An array of string segments forming the path to follow
     * @return A new trie representing the subtrie at the specified path, or nil if not found
     */
    public func traverse(_ path: [String]) -> Self? {
        guard let firstKey = path.first else { return self }
        guard let childNode = children[firstKey], let subtrie = childNode.traverse(ArraySlice(path)) else { return nil }
        return Self(children: subtrie)
    }
    
    /**
     * Retrieves a value from the trie at the specified path.
     * @param path An array of string segments forming the path to the value
     * @return The value at the specified path, or nil if not found
     */
    public func get(_ path: [String]) -> Value? {
        guard let firstKey = path.first else { return nil }
        guard let root = children[firstKey] else { return nil }
        return root.get(path: path)
    }
    
    /**
     * Sets a value in the trie at the specified path.
     * @param path An array of string segments forming the path to set
     * @param value The value to store at the specified path
     */
    public mutating func set(_ path: [String], value: Value) {
        guard let firstKey = path.first else { return }
        if children[firstKey] == nil {
            updateChild(firstKey, Node(prefix: path, value: value, children: [:]))
            return
        }
        children[firstKey]!.set(keys: ArraySlice(path), to: value)
    }
    
    /**
     * Creates a new trie with the specified path deleted.
     * @param path An array of string segments forming the path to delete
     * @return A new trie with the specified path removed
     */
    public func deleting(path: [String]) -> Self {
        guard let firstKey = path.first else { return self }
        guard let childNode = children[firstKey] else { return self }
        return with(child: firstKey, node: childNode.deleting(ArraySlice(path)))
    }
}

/**
 * ArrayTrieNode - A node in the ArrayTrie structure.
 * Each node contains a prefix path, an optional value, and child nodes.
 */
final class ArrayTrieNode<Value> {
    /// Type alias for the children map
    typealias ChildMap = TrieDictionary<ArrayTrieNode<Value>>
    
    /// The prefix path segments leading to this node
    var prefix: [String]!
    
    /// The value stored at this node, if any
    var value: Value?
    
    /// Dictionary of child nodes, keyed by string
    var children: ChildMap
    
    /**
     * Initializes a node with the given prefix, value, and children.
     */
    init(prefix: [String], value: Value?, children: ChildMap) {
        self.prefix = prefix
        self.value = value
        self.children = children
    }
    
    /**
     * Retrieves a child node by key.
     * @param key The key for the child to retrieve
     * @return The child node, or nil if not found
     */
    func getChild(_ key: String) -> ArrayTrieNode<Value>? {
        children[key]
    }
    
    /**
     * Updates the prefix of this node.
     * @param prefix The new prefix array
     */
    func updatePrefix(_ prefix: [String]) {
        self.prefix = prefix
    }
    
    /**
     * Updates the value stored at this node.
     * @param value The new value, or nil to remove the value
     */
    func updateValue(_ value: Value?) {
        self.value = value
    }
    
    /**
     * Updates all children of this node.
     * @param children The new children map
     */
    func updateChildren(_ children: ChildMap) {
        self.children = children
    }
    
    /**
     * Updates or removes a specific child node.
     * @param key The key for the child to update
     * @param node The new node value, or nil to remove the child
     */
    func updateChild(_ key: String, _ node: ArrayTrieNode<Value>?) {
        children[key] = node
    }
    
    /**
     * Creates a new node with modified prefix and/or children.
     * @param prefix The new prefix array, or nil to keep the current prefix
     * @param children The new children map, or nil to keep the current children
     * @return A new node with the specified changes
     */
    func with(prefix: [String]?, children: ChildMap?) -> ArrayTrieNode<Value> {
        ArrayTrieNode(prefix: prefix ?? self.prefix, value: value, children: children ?? self.children)
    }
    
    /**
     * Creates a new node with a modified value.
     * @param value The new value, or nil to remove the value
     * @return A new node with the specified value
     */
    func with(value: Value?) -> ArrayTrieNode<Value> {
        ArrayTrieNode(prefix: prefix, value: value, children: children)
    }
    
    /**
     * Creates a new node with a modified child node.
     * @param child The key for the child to update
     * @param node The new node value, or nil to remove the child
     * @return A new node with the specified child added, updated, or removed
     */
    func with(child: String, node: ArrayTrieNode<Value>?) -> ArrayTrieNode<Value> {
        var newChildren = children
        newChildren[child] = node
        return with(prefix: nil, children: newChildren)
    }
    
    /**
     * Retrieves a value from the node at the specified path.
     * @param path An array of string segments forming the path to the value
     * @return The value at the specified path, or nil if not found
     */
    func get(path: [String]) -> Value? {
        return getInternal(ArraySlice(path))
    }
    
    /**
     * Internal implementation of get that uses ArraySlice for efficiency.
     * @param keys An array slice of string segments forming the path to the value
     * @return The value at the specified path, or nil if not found
     */
    func getInternal(_ keys: ArraySlice<String>) -> Value? {
        // If the keys don't start with this node's prefix, no match
        if !keys.starts(with: prefix) { return nil }
        
        // Get the remaining suffix after this node's prefix
        let suffix = keys.dropFirst(prefix.count)
        
        // If there's no suffix, return this node's value (if any)
        guard let firstValue = suffix.first else { return value }
        
        // Otherwise, look for a child node matching the first suffix element
        guard let childNode = getChild(firstValue) else { return nil }
        
        // Recursively search in the matching child node
        return childNode.getInternal(suffix)
    }
    
    /**
     * Sets a value in the node at the specified path.
     * This method handles various path matching cases and may restructure the trie.
     * @param keys An array slice of string segments forming the path to set
     * @param value The value to store at the specified path
     */
    func set(keys: ArraySlice<String>, to value: Value) {
        // Case 1: The keys start with this node's prefix
        if keys.count >= prefix.count && keys.starts(with: prefix) {
            let suffix = keys.dropFirst(prefix.count)
            
            // If there's no suffix, update this node's value
            guard let firstSuffixValue = suffix.first else {
                updateValue(value)
                return
            }
            
            // If there's no matching child, create a new one
            if children[firstSuffixValue] == nil {
                updateChild(firstSuffixValue, Self(prefix: Array(suffix), value: value, children: [:]))
                return
            }
            
            // Otherwise, recursively set in the matching child
            children[firstSuffixValue]!.set(keys: suffix, to: value)
            return
        }
        
        // Case 2: This node's prefix starts with the keys
        if prefix.count > keys.count && prefix.starts(with: keys) {
            // Split this node into two parts
            let suffix = prefix.dropFirst(keys.count)
            var newChild: ChildMap = [:]
            newChild[suffix.first!] = with(prefix: Array(suffix), children: children)
            updatePrefix(Array(keys))
            updateValue(value)
            updateChildren(newChild)
            return
        }
        
        // Case 3: The keys and this node's prefix share a common prefix
        let prefixSlice = ArraySlice(prefix)
        let parentPrefix = keys.longestCommonPrefix(prefixSlice)
        let newPrefix = keys.dropFirst(parentPrefix.count)
        let oldPrefix = prefixSlice.dropFirst(parentPrefix.count)
        
        // Create new nodes for the divergent paths
        let newNode = Self(prefix: Array(newPrefix), value: value, children: [:])
        let oldNode = with(prefix: Array(oldPrefix), children: children)
        var newChildren: ChildMap = [:]
        newChildren[newPrefix.first!] = newNode
        newChildren[oldPrefix.first!] = oldNode
        
        // Update this node to be the parent
        updatePrefix(parentPrefix)
        updateValue(nil as Value?)
        updateChildren(newChildren)
    }
    
    /**
     * Creates a new node with a value set at the specified path.
     * Similar to set(), but creates a new node instead of modifying the existing one.
     * @param keys An array slice of string segments forming the path to set
     * @param value The value to store at the specified path
     * @return A new node with the value set at the specified path
     */
    func setting(keys: ArraySlice<String>, to value: Value) -> ArrayTrieNode<Value> {
        // Similar logic to set(), but returning new nodes instead of modifying
        
        // Case 1: The keys start with this node's prefix
        if keys.count >= prefix.count && keys.starts(with: prefix) {
            let suffix = keys.dropFirst(prefix.count)
            
            // If there's no suffix, update this node's value
            guard let firstSuffixValue = suffix.first else { return with(value: value) }
            
            // If there's no matching child, create a new one
            guard let childNode = children[firstSuffixValue] else {
                return with(child: firstSuffixValue, node: Self(prefix: Array(suffix), value: value, children: [:]))
            }
            
            // Otherwise, recursively set in the matching child
            return with(child: firstSuffixValue, node: childNode.setting(keys: suffix, to: value))
        }
        
        // Case 2: This node's prefix starts with the keys
        if prefix.count > keys.count && prefix.starts(with: keys) {
            // Split this node into two parts
            let suffix = prefix.dropFirst(keys.count)
            var newChild: ChildMap = [:]
            newChild[suffix.first!] = with(prefix: Array(suffix), children: children)
            return Self(prefix: Array(keys), value: value, children: newChild)
        }
        
        // Case 3: The keys and this node's prefix share a common prefix
        let prefixSlice = ArraySlice(prefix)
        let parentPrefix = keys.longestCommonPrefix(prefixSlice)
        let newPrefix = keys.dropFirst(parentPrefix.count)
        let oldPrefix = prefixSlice.dropFirst(parentPrefix.count)
        
        // Create new nodes for the divergent paths
        let newNode = Self(prefix: Array(newPrefix), value: value, children: [:])
        let oldNode = with(prefix: Array(oldPrefix), children: children)
        var newChildren: ChildMap = [:]
        newChildren[newPrefix.first!] = newNode
        newChildren[oldPrefix.first!] = oldNode
        
        // Create a new parent node
        return Self(prefix: parentPrefix, value: nil as Value?, children: newChildren)
    }
    
    /**
     * Traverses the node following the specified path.
     * @param path An array slice of string segments forming the path to follow
     * @return A map of children at the specified path, or nil if not found
     */
    func traverse(_ path: ArraySlice<String>) -> ChildMap? {
        // If the path is a prefix of this node's prefix
        if prefix.starts(with: path) {
            let suffix = prefix.dropFirst(path.count)
            guard let firstSuffix = suffix.first else { return children }
            var newChild: ChildMap = [:]
            newChild[firstSuffix] = Self(prefix: Array(suffix), value: value, children: children)
            return newChild
        }
        
        // If this node's prefix is not a prefix of the path
        if !path.starts(with: prefix) { return nil }
        
        // Get the remaining suffix after this node's prefix
        let suffix = path.dropFirst(prefix.count)
        guard let firstSuffix = suffix.first else { return children }
        
        // Look for a child node matching the first suffix element
        guard let child = children[firstSuffix] else { return nil }
        
        // Recursively traverse in the matching child node
        return child.traverse(suffix)
    }
    
    /**
     * Creates a new node with this node's value removed.
     * If this node has exactly one child, it merges with that child.
     * @return A new node with the value removed, or nil if the node should be deleted
     */
    func deleting() -> ArrayTrieNode<Value>? {
        // If this node has no children, delete it
        if children.isEmpty { return nil }
        
        // If this node has multiple children, just remove its value
        if children.count > 1 { return with(value: nil as Value?) }
        
        // If this node has exactly one child, merge with it
        let onlyChild = children.values().first!
        return Self(prefix: prefix + onlyChild.prefix, value: onlyChild.value, children: onlyChild.children)
    }
    
    /**
     * Creates a new node with the specified path deleted.
     * @param path An array slice of string segments forming the path to delete
     * @return A new node with the specified path removed, or nil if this node should be deleted
     */
    func deleting(_ path: ArraySlice<String>) -> ArrayTrieNode<Value>? {
        // If the path doesn't start with this node's prefix, nothing to delete
        if !path.starts(with: prefix) { return self }
        
        // Get the remaining suffix after this node's prefix
        let suffix = path.dropFirst(prefix.count)
        
        // If there's no suffix, delete this node
        guard let firstValue = suffix.first else { return deleting() }
        
        // Look for a child node matching the first suffix element
        guard let child = getChild(firstValue) else { return self }
        
        // Recursively delete in the matching child node
        guard let childResult = child.deleting(suffix) else {
            // Child was deleted, handle this node accordingly
            if value != nil || children.count > 2 {
                // This node has a value or multiple children, just remove the deleted child
                return with(child: firstValue, node: nil)
            }
            
            // This node has exactly one remaining child, merge with it
            let remainingChildren = children.values().filter { $0.prefix.first! != firstValue }
            let childNode = remainingChildren.first!
            return Self(prefix: prefix + childNode.prefix, value: childNode.value, children: childNode.children)
        }
        
        // Child was updated, update this node accordingly
        return with(child: firstValue, node: childResult)
    }
}

/**
 * Extension to ArraySlice for finding the longest common prefix with another ArraySlice.
 */
extension ArraySlice where Element: Equatable {
    /**
     * Finds the longest common prefix between this ArraySlice and another.
     * @param other The other ArraySlice to compare with
     * @return An array containing the longest common prefix elements
     */
    public func longestCommonPrefix(_ other: Self) -> Array<Element> {
        zip(self, other).prefix { $0 == $1 }.map(\.0)
    }
}
