import CryptoSwift
import PythonKit
import Foundation
import Logging

class BaseService: Equatable, CustomStringConvertible {
    var id: Int

    let experimentSeed: Int

    let filteringSeed: [UInt8]

    let filterLowerBound: Double

    let filterUpperBound: Double

    let logger: Logger

    init(id: Int,
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double
    ) {
        self.id = id
        self.experimentSeed = experimentSeed
        let generatorSeed = id * experimentSeed
        var randomGenerator = MTGenerator(seed: UInt32(generatorSeed))
        self.filteringSeed = Double.random(in: 0...1, using: &randomGenerator).bytes
        self.filterLowerBound = filterLowerBound
        self.filterUpperBound = filterUpperBound
        self.logger = Logger.createWithLevelFromEnv(fileName: #file)
    }

    func run(on dataframe: PythonObject, withContext context: Context) -> PythonObject {
        assertionFailure("This method should be never called on the base class")
        return dataframe
    }

    public func finalFilteringPercent(from context: Context) -> Double {
        let servicesLineageSeed = context.accumulatedFilteringSeed + self.filteringSeed

        return generatePercent(usingHashFrom: servicesLineageSeed)
    }

    private func generatePercent(usingHashFrom x: [UInt8]) -> Double {
        let percent = Double(x.crc32()) / pow(2, 32)
        let normalizedPercent = percent.normalize(
            min: 0, 
            max: 1, 
            from: self.filterLowerBound, 
            to: self.filterUpperBound
        )
        return normalizedPercent
    }

    static func == (lhs: BaseService, rhs: BaseService) -> Bool {
        return lhs.id == rhs.id
    }

    var description: String {
        get {
            return "S" + String(format: "%02d", id)
        }
    }
}

struct Context {
    var previouslyChosenServices: [BaseService]
    var accumulatedFilteringSeed: [UInt8]
}

class RowFilterService: BaseService {
    override init(id: Int,
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double
    ) {
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            filterLowerBound: filterLowerBound, 
            filterUpperBound: filterUpperBound
        )

        logger.log(withDescription: " Creating Service \(id)", withProps: [
            "filteringSeed" : "\(filteringSeed)"
        ])
    }

    override var description: String {
        get {
            return "RF" + super.description
        }
    }

    /// Run the service and filter rows using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe
    override public func run(on dataframe: PythonObject, withContext context: Context) -> PythonObject {
        return dataframe.sample(
            frac: self.finalFilteringPercent(from: context),
            random_state: self.experimentSeed
        )
    }
}

class ColumnFilterService: BaseService {
    /// Run the service and filter columns using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe
    override public func run(on dataframe: PythonObject, withContext context: Context) -> PythonObject {
        return dataframe
    }

    override var description: String {
        get {
            return "CF" + super.description
        }
    }
}