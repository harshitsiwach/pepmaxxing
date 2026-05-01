import Foundation

class SteroidDatabase {
    static let shared = SteroidDatabase()
    
    private(set) var steroids: [Steroid] = []
    
    private init() {
        loadSteroids()
    }
    
    private func loadSteroids() {
        guard let url = Bundle.main.url(forResource: "steroids", withExtension: "csv") else {
            print("Error: Could not find steroids.csv in bundle.")
            return
        }
        
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            self.steroids = parseCSV(data: data)
            print("Successfully loaded \(self.steroids.count) steroids")
        } catch {
            print("Error loading steroids CSV: \(error)")
        }
    }
    
    private func parseCSV(data: String) -> [Steroid] {
        var parsedSteroids: [Steroid] = []
        
        let lines = data.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }
        
        let dataLines = lines.dropFirst()
        
        for line in dataLines {
            let components = parseCSVLine(line)
            if components.count >= 13 {
                let steroid = Steroid(
                    name: components[0],
                    steroidClass: components[1],
                    mechanism: components[2],
                    clinicalEffects: components[3],
                    dosageMen: components[4],
                    dosageWomen: components[5],
                    genderNotes: components[6],
                    route: components[7],
                    clinicalStatus: components[8],
                    pharmacokinetics: components[9],
                    adverseEffects: components[10],
                    monitoringParameters: components[11],
                    references: components[12]
                )
                parsedSteroids.append(steroid)
            }
        }
        
        return parsedSteroids
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        result.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
        
        return result.map { $0.replacingOccurrences(of: "\"\"", with: "\"") }
    }
}
