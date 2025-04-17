//
//  Task.swift
//

import UIKit

// The Task model
struct Task: Codable {
    
    // The task's title
    var title: String
    
    // An optional note
    var note: String?
    
    // The due date by which the task should be completed
    var dueDate: Date
    
    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {
        didSet {
            if isComplete {
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }
    
    // The date the task was completed
    private(set) var completedDate: Date?
    
    // The date the task was created
    private(set) var createdDate: Date = Date()
    
    // An id (Universal Unique Identifier) used to identify a task.
    private(set) var id: String = UUID().uuidString
    
    // Initialize a new task
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }
}

// MARK: - Task + UserDefaults
extension Task {
    
    // Key for storing tasks in UserDefaults
    private static let tasksKey = "tasks"
    
    /// Save an array of tasks to UserDefaults
    static func save(_ tasks: [Task]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    /// Retrieve an array of saved tasks from UserDefaults
    static func getTasks() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }
    
    /// Add or update the current task in UserDefaults
    func save() {
        var allTasks = Task.getTasks()
        
        if let index = allTasks.firstIndex(where: { $0.id == self.id }) {
            allTasks[index] = self
        } else {
            allTasks.append(self)
        }
        
        Task.save(allTasks)
    }
    
    /// Delete the current task from UserDefaults
    func delete() {
        var allTasks = Task.getTasks()
        allTasks.removeAll { $0.id == self.id }
        Task.save(allTasks)
    }
}


