import Foundation

struct PeptideDatabase {
    static let all: [Peptide] = loadFromBundle()
    
    private static func loadFromBundle() -> [Peptide] {
        guard let url = Bundle.main.url(forResource: "peptides", withExtension: "csv"),
              let data = try? String(contentsOf: url, encoding: .utf8) else {
            // Fallback: if bundle resource not found, return empty
            print("⚠️ peptides.csv not found in bundle")
            return []
        }
        return parseCSVString(data)
    }
    
    static func parseCSVString(_ csv: String) -> [Peptide] {
        let rawLines = csv.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        // Skip header line
        let lines: [String]
        if let first = rawLines.first, first.contains("Peptide_Name") {
            lines = Array(rawLines.dropFirst())
        } else {
            lines = rawLines
        }
        
        var peptides: [Peptide] = []
        
        for line in lines {
            let fields = parseCSVLine(line)
            guard fields.count >= 7 else { continue }
            
            let name = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let category = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let mechanism = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let dosage = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let genderNotes = fields[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let route = fields[5].trimmingCharacters(in: .whitespacesAndNewlines)
            let status = fields[6].trimmingCharacters(in: .whitespacesAndNewlines)
            let refs = fields.count > 7 ? fields[7].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            
            guard !name.isEmpty else { continue }
            
            // Mark as Experimental if preclinical or has limited/mostly preclinical data
            let isExperimental = genderNotes.lowercased().contains("mostly preclinical") ||
                                 genderNotes.lowercased().contains("human dosing extrapolated") ||
                                 mechanism.lowercased().contains("preclinical")
            
            let finalStatus: String
            if isExperimental && status == "Investigational" {
                finalStatus = "Experimental"
            } else {
                finalStatus = status
            }
            
            peptides.append(Peptide(
                name: name,
                category: category,
                mechanism: mechanism,
                dosageRange: dosage,
                genderNotes: genderNotes,
                route: route,
                clinicalStatus: finalStatus,
                references: refs
            ))
        }
        
        return peptides
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else if char == "\r" {
                // Skip carriage returns
                continue
            } else {
                current.append(char)
            }
        }
        fields.append(current)
        return fields
    }
}
