import Foundation
import UIKit

class DataExporter {
    static let shared = DataExporter()
    
    func exportLogsToCSV(cycles: [Cycle]) -> URL? {
        var csvString = "Cycle Name,Peptide,Date,Dosage,Route,Injection Site,Notes\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for cycle in cycles {
            for log in cycle.logs {
                let cycleName = escape(cycle.name)
                let peptide = escape(log.peptideName)
                let dateStr = escape(formatter.string(from: log.date))
                let dosage = escape(log.dosage)
                let route = escape(log.route)
                let site = escape(log.injectionSite)
                let notes = escape(log.notes)
                
                csvString.append("\(cycleName),\(peptide),\(dateStr),\(dosage),\(route),\(site),\(notes)\n")
            }
        }
        
        let fileName = "Pepmax_Logs_\(Int(Date().timeIntervalSince1970)).csv"
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempUrl, atomically: true, encoding: .utf8)
            return tempUrl
        } catch {
            print("Error creating CSV: \(error)")
            return nil
        }
    }
    
    private func escape(_ string: String) -> String {
        var escaped = string
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
            escaped = "\"\(escaped)\""
        }
        return escaped
    }
}
