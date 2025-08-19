//
//  SearchHistoryManager.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 19/08/25.
//

import Foundation

final class SearchHistoryManager {
    static let shared = SearchHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let searchHistoryKey = "SearchHistoryKey"
    private let maxHistoryCount = 5
    
    private init() {}
    
    func addSearchHistory(_ searchText: String) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        var history = getSearchHistoryStrings()
        
        // Remove existing entry if it exists
        history.removeAll { $0 == searchText }
        
        // Add new entry at the beginning
        history.insert(searchText, at: 0)
        
        // Maintain maximum count
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        userDefaults.set(history, forKey: searchHistoryKey)
    }
    
    func removeSearchHistory(_ searchText: String) {
        var history = getSearchHistoryStrings()
        history.removeAll { $0 == searchText }
        userDefaults.set(history, forKey: searchHistoryKey)
    }
    
    func getSearchHistory() -> [HomeSearchSearchLocationData] {
        let history = getSearchHistoryStrings()
        return history.enumerated().map { index, searchText in
            HomeSearchSearchLocationData(
                id: index + 1,
                name: searchText
            )
        }
    }
    
    func clearSearchHistory() {
        userDefaults.removeObject(forKey: searchHistoryKey)
    }
    
    private func getSearchHistoryStrings() -> [String] {
        return userDefaults.stringArray(forKey: searchHistoryKey) ?? []
    }
}
