import XCTest
@testable import DataBalanceSimulator

public class PipelineTests: XCTestCase {
    func testGivenPipelineWith0Services_whenRun_thenThrow() throws {
        XCTAssertThrowsError(
            try Pipeline(services: []),
            "Pipeline cannot run with 0 services", 
            { error in
                XCTAssertEqual(
                    error as? GenericErrors, 
                    GenericErrors.InvalidState("Pipeline cannot run with 0 services")
                )
            }
        )
    }

    func testGivenPipelineWith1Service_whenRun_thenExecute1() throws {
        let s = SimpleServiceFactory.build(withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let pipeline = try Pipeline(services: [s])

        let outputDataset = pipeline.run(on: dataset)

        DatasetUtils.assertSize(of: outputDataset, isEqualTo: 50)
    }

    func testGivenPipelineWithMultipleServices_whenRun_thenExecuteSequentially() throws {
        let s1 = SimpleServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = SimpleServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let pipeline = try Pipeline(services: [s1, s2])

        let outputDataset = pipeline.run(on: dataset)

        DatasetUtils.assertSize(of: outputDataset, isEqualTo: 25)
    }

    func testGivenPipelineWithCacheMiss_whenRun_thenExecuteAllServices() throws {
        let s1 = SimpleServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = SimpleServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let s3 = SimpleServiceFactory.build(withId: 3, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let dumbDataset = DatasetFactory.build(withDatasetSize: 1)
        let pipeline = try Pipeline(services: [s1, s2])

        let outputDataset = pipeline.run(on: dataset, withCache: [([s3], dumbDataset)])

        DatasetUtils.assertSize(of: outputDataset, isEqualTo: 25)
    }

    func testGivenPipelineWithCacheHit_whenRun_thenExecuteRemainingServices() throws {
        let s1 = SimpleServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = SimpleServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let cachedDataset = DatasetFactory.build(withDatasetSize: 10)
        let pipeline = try Pipeline(services: [s1, s2])

        let outputDataset = pipeline.run(on: dataset, withCache: [([s1], cachedDataset)])

        DatasetUtils.assertSize(of: outputDataset, isEqualTo: 5)
    }

    func testGivenPipelineWithAllCached_whenRun_thenReturnCachedDataset() throws {
        let s1 = SimpleServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = SimpleServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let cachedDataset = DatasetFactory.build(withDatasetSize: 10)
        let pipeline = try Pipeline(services: [s1, s2])

        let outputDataset = pipeline.run(on: dataset, withCache: [([s1, s2], cachedDataset)])

        DatasetUtils.assertSize(of: outputDataset, isEqualTo: 10)
    }
}