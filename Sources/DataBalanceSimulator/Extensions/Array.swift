import Algorithms

extension Array where Element: BinaryFloatingPoint {
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}

extension Array where Element: Equatable {
    /// Returns whether self is a prefix subarray of `arr`. 
    /// Example: [1, 2].isPrefix([1, 2, 3]) -> true
    /// - Parameter arr: the array where the prefix could appear
    /// - Returns: true if is prefix, false otherwise
    func isPrefix(of arr: Self) -> Bool {
        if self.count > arr.count {
            return false
        }

        return self.elementsEqual(arr.prefix(self.count))
    }
}

extension Array where Element: RandomAccessCollection, Element.Index == Int {
    func cartesianProduct() -> [[Element.Element]] {
        if self.isEmpty {
            // type mismatch if returns self
            return []
        }

        // Algorithms does not provide a `product` with ariety > 2, so
        // we need to compose the `product` calls
        return self.dropFirst().reduce(self[0].map { [$0] }) { result, array in
            Algorithms.product(result, array).map { (resultElement, arrayElement) in
                resultElement + [arrayElement]
            }
        }
    }
}