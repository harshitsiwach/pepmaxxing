import Foundation
import HealthKit

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(false)
            return
        }
        
        let typesToShare: Set = [weightType]
        let typesToRead: Set = [weightType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                completion(success)
            }
        }
    }
    
    func fetchLatestWeight(completion: @escaping (Double?) -> Void) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            DispatchQueue.main.async {
                completion(weightInKg)
            }
        }
        
        healthStore.execute(query)
    }
    
    func saveWeight(weightKg: Double, completion: @escaping (Bool) -> Void) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(false)
            return
        }
        
        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weightKg)
        let sample = HKQuantitySample(type: weightType, quantity: quantity, start: Date(), end: Date())
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
