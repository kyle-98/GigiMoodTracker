//
//  CSVImportCoordinator.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/18/25.
//


import UIKit

class CSVImportCoordinator: NSObject, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        CSVManager.importData(from: selectedURL)  // Pass the selected file URL to CSVManager
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}
