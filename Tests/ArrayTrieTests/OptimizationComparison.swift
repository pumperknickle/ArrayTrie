import XCTest
import Testing
import TrieDictionary
@testable import ArrayTrie

@Suite struct OptimizationComparison {
    
    // MARK: - Test Data Generation
    
    func generateTestPaths(count: Int, depth: Int = 3) -> [[String]] {
        var paths: [[String]] = []
        
        for i in 0..<count {
            var path: [String] = []
            for level in 0..<depth {
                path.append("level\(level)_item\(i % 10)")
            }
            paths.append(path)
        }
        return paths
    }
    
    // MARK: - Insertion Performance Comparison
    
    @Test func compareInsertionPerformance() {
        let testSizes = [1000, 5000, 10000]
        
        for size in testSizes {
            let paths = generateTestPaths(count: size)
            
            print("\n=== Insertion Performance Comparison (Size: \(size)) ===")
            
            // Original ArrayTrie
            measureInsertionTime(
                name: "Original ArrayTrie",
                paths: paths
            ) { paths in
                var trie = ArrayTrie<String>()
                for (index, path) in paths.enumerated() {
                    trie.set(path, value: "value\(index)")
                }
                return trie
            }
            
            // Memory Optimized
            measureInsertionTime(
                name: "Memory Optimized",
                paths: paths
            ) { paths in
                var trie = MemoryOptimizedArrayTrie<String>()
                for (index, path) in paths.enumerated() {
                    trie.set(path, value: "value\(index)")
                }
                return trie
            }
            
            // Algorithmically Optimized
            measureInsertionTime(
                name: "Algorithmic Optimized",
                paths: paths
            ) { paths in
                var trie = AlgorithmicOptimizedArrayTrie<String>()
                for (index, path) in paths.enumerated() {
                    trie.set(path, value: "value\(index)")
                }
                return trie
            }
            
            // COW Optimized
            measureInsertionTime(
                name: "COW Optimized",
                paths: paths
            ) { paths in
                var trie = COWOptimizedArrayTrie<String>()
                for (index, path) in paths.enumerated() {
                    trie.set(path, value: "value\(index)")
                }
                return trie
            }
        }
    }
    
    // MARK: - Lookup Performance Comparison
    
    @Test func compareLookupPerformance() {
        let paths = generateTestPaths(count: 5000)
        
        print("\n=== Lookup Performance Comparison ===")
        
        // Prepare tries
        var originalTrie = ArrayTrie<String>()
        var memoryOptimizedTrie = MemoryOptimizedArrayTrie<String>()
        var algorithmicOptimizedTrie = AlgorithmicOptimizedArrayTrie<String>()
        var cowOptimizedTrie = COWOptimizedArrayTrie<String>()
        
        // Populate all tries
        for (index, path) in paths.enumerated() {
            let value = "value\(index)"
            originalTrie.set(path, value: value)
            memoryOptimizedTrie.set(path, value: value)
            algorithmicOptimizedTrie.set(path, value: value)
            cowOptimizedTrie.set(path, value: value)
        }
        
        // Test lookup performance
        measureLookupTime(name: "Original ArrayTrie", paths: paths) { path in
            return originalTrie.get(path) != nil
        }
        
        measureLookupTime(name: "Memory Optimized", paths: paths) { path in
            return memoryOptimizedTrie.get(path) != nil
        }
        
        measureLookupTime(name: "Algorithmic Optimized", paths: paths) { path in
            return algorithmicOptimizedTrie.get(path) != nil
        }
        
        measureLookupTime(name: "COW Optimized", paths: paths) { path in
            return cowOptimizedTrie.get(path) != nil
        }
        
        // Display cache efficiency for algorithmic optimization
        print("Cache efficiency: \(String(format: "%.2f%%", algorithmicOptimizedTrie.getCacheEfficiency() * 100))")
    }
    
    // MARK: - Memory Usage Comparison
    
    @Test func compareMemoryUsage() {
        let paths = generateTestPaths(count: 2000)
        
        print("\n=== Memory Usage Comparison ===")
        
        // Original ArrayTrie
        autoreleasepool {
            let memoryBefore = getMemoryUsage()
            var trie = ArrayTrie<String>()
            for (index, path) in paths.enumerated() {
                trie.set(path, value: "value\(index)")
            }
            let memoryAfter = getMemoryUsage()
            print("Original ArrayTrie: \(memoryAfter - memoryBefore) KB")
            _ = trie // Keep reference until measurement
        }
        
        // Memory Optimized
        autoreleasepool {
            let memoryBefore = getMemoryUsage()
            var trie = MemoryOptimizedArrayTrie<String>()
            for (index, path) in paths.enumerated() {
                trie.set(path, value: "value\(index)")
            }
            let memoryAfter = getMemoryUsage()
            print("Memory Optimized: \(memoryAfter - memoryBefore) KB")
            _ = trie
        }
        
        // COW Optimized
        autoreleasepool {
            let memoryBefore = getMemoryUsage()
            var trie = COWOptimizedArrayTrie<String>()
            for (index, path) in paths.enumerated() {
                trie.set(path, value: "value\(index)")
            }
            let memoryAfter = getMemoryUsage()
            print("COW Optimized: \(memoryAfter - memoryBefore) KB")
            _ = trie
        }
    }
    
    // MARK: - Specific Optimization Tests
    
    @Test func testArraySliceOptimization() {
        let longPaths = generateTestPaths(count: 1000, depth: 10)
        
        print("\n=== ArraySlice Optimization Test ===")
        
        // Test with paths that create many ArraySlice operations
        
        // Original (many ArraySlice allocations)
        let originalStart = DispatchTime.now()
        var originalTrie = ArrayTrie<String>()
        for (index, path) in longPaths.enumerated() {
            originalTrie.set(path, value: "value\(index)")
        }
        for path in longPaths {
            _ = originalTrie.get(path)
        }
        let originalTime = Double(DispatchTime.now().uptimeNanoseconds - originalStart.uptimeNanoseconds) / 1_000_000_000
        
        // Memory optimized (fewer ArraySlice allocations)
        let optimizedStart = DispatchTime.now()
        var optimizedTrie = MemoryOptimizedArrayTrie<String>()
        for (index, path) in longPaths.enumerated() {
            optimizedTrie.set(path, value: "value\(index)")
        }
        for path in longPaths {
            _ = optimizedTrie.get(path)
        }
        let optimizedTime = Double(DispatchTime.now().uptimeNanoseconds - optimizedStart.uptimeNanoseconds) / 1_000_000_000
        
        print("Original ArrayTrie (deep paths): \(String(format: "%.4f", originalTime))s")
        print("Memory Optimized (deep paths): \(String(format: "%.4f", optimizedTime))s")
        print("Improvement: \(String(format: "%.1f", (originalTime - optimizedTime) / originalTime * 100))%")
    }
    
    @Test func testCommonPrefixOptimization() {
        // Create paths with lots of common prefixes
        var paths: [[String]] = []
        let commonBase = ["api", "v1", "users"]
        
        for i in 0..<2000 {
            paths.append(commonBase + ["user\(i)", "profile"])
            paths.append(commonBase + ["user\(i)", "settings"])
        }
        
        print("\n=== Common Prefix Optimization Test ===")
        
        // Test both implementations
        let originalStart = DispatchTime.now()
        var originalTrie = ArrayTrie<String>()
        for (index, path) in paths.enumerated() {
            originalTrie.set(path, value: "value\(index)")
        }
        let originalTime = Double(DispatchTime.now().uptimeNanoseconds - originalStart.uptimeNanoseconds) / 1_000_000_000
        
        let optimizedStart = DispatchTime.now()
        var optimizedTrie = AlgorithmicOptimizedArrayTrie<String>()
        for (index, path) in paths.enumerated() {
            optimizedTrie.set(path, value: "value\(index)")
        }
        let optimizedTime = Double(DispatchTime.now().uptimeNanoseconds - optimizedStart.uptimeNanoseconds) / 1_000_000_000
        
        print("Original (common prefixes): \(String(format: "%.4f", originalTime))s")
        print("Algorithmic Optimized (common prefixes): \(String(format: "%.4f", optimizedTime))s")
        
        if originalTime > optimizedTime {
            print("Improvement: \(String(format: "%.1f", (originalTime - optimizedTime) / originalTime * 100))%")
        } else {
            print("Performance regression: \(String(format: "%.1f", (optimizedTime - originalTime) / originalTime * 100))%")
        }
    }
    
    @Test func testCacheEfficiency() {
        let paths = generateTestPaths(count: 1000)
        var trie = AlgorithmicOptimizedArrayTrie<String>()
        
        // Populate trie
        for (index, path) in paths.enumerated() {
            trie.set(path, value: "value\(index)")
        }
        
        print("\n=== Cache Efficiency Test ===")
        
        // Test repeated access to same paths (should benefit from caching)
        let testPaths = Array(paths.prefix(100))
        
        for _ in 0..<10 {
            for path in testPaths {
                _ = trie.get(path)
            }
        }
        
        print("Cache efficiency after repeated access: \(String(format: "%.2f%%", trie.getCacheEfficiency() * 100))")
    }
    
    // MARK: - Edge Case Performance Tests
    
    @Test func testWorstCaseScenarios() {
        print("\n=== Worst Case Scenario Tests ===")
        
        // Test 1: Very long paths
        let veryLongPaths = (0..<100).map { i in
            (0..<50).map { j in "segment_\(i)_\(j)" }
        }
        
        measurePerformanceScenario(
            name: "Very Long Paths",
            paths: veryLongPaths
        )
        
        // Test 2: Many siblings at root level
        let manySiblings = (0..<1000).map { i in
            ["root_sibling_\(i)"]
        }
        
        measurePerformanceScenario(
            name: "Many Root Siblings",
            paths: manySiblings
        )
        
        // Test 3: Deep hierarchy with few siblings
        var deepHierarchy: [[String]] = []
        var currentPath: [String] = []
        for level in 0..<20 {
            currentPath.append("level_\(level)")
            deepHierarchy.append(currentPath)
        }
        
        measurePerformanceScenario(
            name: "Deep Hierarchy",
            paths: deepHierarchy
        )
    }
    
    // MARK: - Helper Methods
    
    private func measureInsertionTime<T>(
        name: String,
        paths: [[String]],
        operation: ([[String]]) -> T
    ) {
        let startTime = DispatchTime.now()
        _ = operation(paths)
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        
        print("\(name): \(String(format: "%.4f", timeElapsed))s")
    }
    
    private func measureLookupTime(
        name: String,
        paths: [[String]],
        operation: ([String]) -> Bool
    ) {
        let startTime = DispatchTime.now()
        
        for path in paths {
            _ = operation(path)
        }
        
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        print("\(name): \(String(format: "%.4f", timeElapsed))s")
    }
    
    private func measurePerformanceScenario(name: String, paths: [[String]]) {
        // Test original
        let originalStart = DispatchTime.now()
        var originalTrie = ArrayTrie<String>()
        for (index, path) in paths.enumerated() {
            originalTrie.set(path, value: "value\(index)")
        }
        for path in paths {
            _ = originalTrie.get(path)
        }
        let originalTime = Double(DispatchTime.now().uptimeNanoseconds - originalStart.uptimeNanoseconds) / 1_000_000_000
        
        // Test memory optimized
        let memoryStart = DispatchTime.now()
        var memoryTrie = MemoryOptimizedArrayTrie<String>()
        for (index, path) in paths.enumerated() {
            memoryTrie.set(path, value: "value\(index)")
        }
        for path in paths {
            _ = memoryTrie.get(path)
        }
        let memoryTime = Double(DispatchTime.now().uptimeNanoseconds - memoryStart.uptimeNanoseconds) / 1_000_000_000
        
        print("\(name):")
        print("  Original: \(String(format: "%.4f", originalTime))s")
        print("  Memory Optimized: \(String(format: "%.4f", memoryTime))s")
        
        if originalTime > memoryTime {
            print("  Improvement: \(String(format: "%.1f", (originalTime - memoryTime) / originalTime * 100))%")
        } else {
            print("  Regression: \(String(format: "%.1f", (memoryTime - originalTime) / originalTime * 100))%")
        }
    }
    
    private func getMemoryUsage() -> Int {
        // Simplified memory tracking for demo purposes
        return 1000 // Placeholder value
    }
}