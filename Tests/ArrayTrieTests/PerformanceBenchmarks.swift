import XCTest
import Testing
import TrieDictionary
@testable import ArrayTrie

@Suite struct PerformanceBenchmarks {
    
    // MARK: - Test Data Generation
    
    func generateTestPaths(count: Int, depth: Int = 3, segmentLength: Int = 8) -> [[String]] {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        var paths: [[String]] = []
        
        for i in 0..<count {
            var path: [String] = []
            for level in 0..<depth {
                let segmentSeed = i * depth + level
                let segment = String((0..<segmentLength).map { _ in 
                    alphabet.randomElement()! 
                })
                path.append("\(segment)\(segmentSeed)")
            }
            paths.append(path)
        }
        return paths
    }
    
    func generateHierarchicalPaths(breadth: Int, depth: Int) -> [[String]] {
        var paths: [[String]] = []
        
        func generateLevel(currentPath: [String], currentDepth: Int) {
            if currentDepth >= depth { return }
            
            for i in 0..<breadth {
                let newPath = currentPath + ["level\(currentDepth)_item\(i)"]
                paths.append(newPath)
                generateLevel(currentPath: newPath, currentDepth: currentDepth + 1)
            }
        }
        
        generateLevel(currentPath: [], currentDepth: 0)
        return paths
    }
    
    // MARK: - Insertion Benchmarks
    
    @Test func benchmarkInsertionPerformance() {
        let testCases = [
            (count: 100, name: "Small"),
            (count: 1000, name: "Medium"), 
            (count: 10000, name: "Large")
        ]
        
        for testCase in testCases {
            let paths = generateTestPaths(count: testCase.count)
            var trie = ArrayTrie<String>()
            
            let startTime = DispatchTime.now()
            
            for (index, path) in paths.enumerated() {
                trie.set(path, value: "value\(index)")
            }
            
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
            
            print("Insertion \(testCase.name) (\(testCase.count) items): \(String(format: "%.4f", timeElapsed))s")
            print("Average per insertion: \(String(format: "%.6f", timeElapsed / Double(testCase.count)))s")
        }
    }
    
    @Test func benchmarkHierarchicalInsertion() {
        let testCases = [
            (breadth: 5, depth: 3, name: "Shallow Wide"),
            (breadth: 3, depth: 5, name: "Deep Narrow"),
            (breadth: 10, depth: 2, name: "Very Wide Shallow")
        ]
        
        for testCase in testCases {
            let paths = generateHierarchicalPaths(breadth: testCase.breadth, depth: testCase.depth)
            var trie = ArrayTrie<String>()
            
            let startTime = DispatchTime.now()
            
            for (index, path) in paths.enumerated() {
                trie.set(path, value: "value\(index)")
            }
            
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
            
            print("Hierarchical \(testCase.name) (\(paths.count) items): \(String(format: "%.4f", timeElapsed))s")
        }
    }
    
    // MARK: - Lookup Benchmarks
    
    @Test func benchmarkLookupPerformance() {
        let paths = generateTestPaths(count: 5000)
        var trie = ArrayTrie<String>()
        
        // Populate trie
        for (index, path) in paths.enumerated() {
            trie.set(path, value: "value\(index)")
        }
        
        // Benchmark successful lookups
        let startTime = DispatchTime.now()
        
        for path in paths {
            _ = trie.get(path)
        }
        
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        
        print("Lookup Performance (5000 items): \(String(format: "%.4f", timeElapsed))s")
        print("Average per lookup: \(String(format: "%.6f", timeElapsed / Double(paths.count)))s")
        
        // Benchmark failed lookups
        let nonExistentPaths = generateTestPaths(count: 1000).map { $0 + ["nonexistent"] }
        
        let startTime2 = DispatchTime.now()
        
        for path in nonExistentPaths {
            _ = trie.get(path)
        }
        
        let timeElapsed2 = Double(DispatchTime.now().uptimeNanoseconds - startTime2.uptimeNanoseconds) / 1_000_000_000
        
        print("Failed Lookup Performance (1000 items): \(String(format: "%.4f", timeElapsed2))s")
    }
    
    // MARK: - Traversal Benchmarks
    
    @Test func benchmarkTraversalPerformance() {
        let paths = generateHierarchicalPaths(breadth: 10, depth: 4)
        var trie = ArrayTrie<String>()
        
        for (index, path) in paths.enumerated() {
            trie.set(path, value: "value\(index)")
        }
        
        // Test traversal at different depths
        let traversalPaths = [
            [],
            ["level0_item0"],
            ["level0_item0", "level1_item0"],
            ["level0_item0", "level1_item0", "level2_item0"]
        ]
        
        for traversalPath in traversalPaths {
            let startTime = DispatchTime.now()
            
            for _ in 0..<1000 {
                _ = trie.traverse(traversalPath)
            }
            
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
            
            print("Traversal depth \(traversalPath.count) (1000 ops): \(String(format: "%.4f", timeElapsed))s")
        }
    }
    
    // MARK: - Deletion Benchmarks
    
    @Test func benchmarkDeletionPerformance() {
        let paths = generateTestPaths(count: 2000)
        var trie = ArrayTrie<String>()
        
        // Populate trie
        for (index, path) in paths.enumerated() {
            trie.set(path, value: "value\(index)")
        }
        
        // Benchmark deletions (immutable operations)
        let pathsToDelete = Array(paths.prefix(1000))
        
        let startTime = DispatchTime.now()
        
        for path in pathsToDelete {
            trie = trie.deleting(path: path)
        }
        
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        
        print("Deletion Performance (1000 items): \(String(format: "%.4f", timeElapsed))s")
        print("Average per deletion: \(String(format: "%.6f", timeElapsed / Double(pathsToDelete.count)))s")
    }
    
    // MARK: - Memory Usage Benchmarks
    
    @Test func benchmarkMemoryUsage() {
        let paths = generateTestPaths(count: 10000)
        var trie = ArrayTrie<String>()
        
        // Measure memory before population
        let memoryBefore = getMemoryUsage()
        
        for (index, path) in paths.enumerated() {
            trie.set(path, value: "value\(index)")
        }
        
        let memoryAfter = getMemoryUsage()
        let memoryUsed = memoryAfter - memoryBefore
        
        print("Memory Usage (10,000 items): \(memoryUsed) KB")
        print("Memory per item: \(String(format: "%.2f", Double(memoryUsed) / Double(paths.count))) KB")
    }
    
    // MARK: - Path Length Impact Benchmarks
    
    @Test func benchmarkPathLengthImpact() {
        let pathLengths = [1, 3, 5, 10, 20]
        
        for pathLength in pathLengths {
            let paths = generateTestPaths(count: 1000, depth: pathLength)
            var trie = ArrayTrie<String>()
            
            // Insertion time
            let insertStartTime = DispatchTime.now()
            
            for (index, path) in paths.enumerated() {
                trie.set(path, value: "value\(index)")
            }
            
            let insertTimeElapsed = Double(DispatchTime.now().uptimeNanoseconds - insertStartTime.uptimeNanoseconds) / 1_000_000_000
            
            // Lookup time
            let lookupStartTime = DispatchTime.now()
            
            for path in paths {
                _ = trie.get(path)
            }
            
            let lookupTimeElapsed = Double(DispatchTime.now().uptimeNanoseconds - lookupStartTime.uptimeNanoseconds) / 1_000_000_000
            
            print("Path length \(pathLength) - Insert: \(String(format: "%.4f", insertTimeElapsed))s, Lookup: \(String(format: "%.4f", lookupTimeElapsed))s")
        }
    }
    
    // MARK: - Common Prefix Benchmark
    
    @Test func benchmarkCommonPrefixPerformance() {
        // Create paths with lots of common prefixes to stress prefix handling
        var paths: [[String]] = []
        let commonPrefixes = ["api", "v1", "users"]
        
        for i in 0..<5000 {
            let specificPath = commonPrefixes + ["user\(i)", "profile"]
            paths.append(specificPath)
        }
        
        var trie = ArrayTrie<String>()
        
        let startTime = DispatchTime.now()
        
        for (index, path) in paths.enumerated() {
            trie.set(path, value: "value\(index)")
        }
        
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        
        print("Common Prefix Insertion (5000 items): \(String(format: "%.4f", timeElapsed))s")
        
        // Test traversal performance with common prefixes
        let traversalStartTime = DispatchTime.now()
        
        for _ in 0..<1000 {
            _ = trie.traverse(["api", "v1"])
        }
        
        let traversalTimeElapsed = Double(DispatchTime.now().uptimeNanoseconds - traversalStartTime.uptimeNanoseconds) / 1_000_000_000
        
        print("Common Prefix Traversal (1000 ops): \(String(format: "%.4f", traversalTimeElapsed))s")
    }
    
    // MARK: - String Path Traversal Benchmark
    
    @Test func benchmarkStringTraversalPerformance() {
        var trie = ArrayTrie<String>()
        
        // Create keys with common string prefixes
        let prefixBases = ["user", "admin", "guest", "api", "data"]
        
        for base in prefixBases {
            for i in 0..<1000 {
                trie.set(["\(base)\(i)"], value: "value_\(base)_\(i)")
            }
        }
        
        // Benchmark string traversal
        for prefix in prefixBases {
            let startTime = DispatchTime.now()
            
            for _ in 0..<100 {
                _ = trie.traverse(path: prefix)
            }
            
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
            
            print("String traversal '\(prefix)' (100 ops): \(String(format: "%.4f", timeElapsed))s")
        }
    }
    
    // MARK: - Utility Functions
    
    private func getMemoryUsage() -> Int {
        // Simplified memory tracking for demo purposes
        // In production, you might use proper memory profiling tools
        return 1000 // Placeholder value
    }
}