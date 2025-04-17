//
//  TaskListViewController.swift
//

import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide top cell separator
        tableView.tableHeaderView = UIView()

        // Setup delegates
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTasks()
    }

    @IBAction func didTapNewTaskButton(_ sender: Any) {
        performSegue(withIdentifier: "ComposeSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeSegue",
           let composeNav = segue.destination as? UINavigationController,
           let composeVC = composeNav.topViewController as? TaskComposeViewController {

            // If we're editing an existing task, pass it
            composeVC.taskToEdit = sender as? Task

            // Closure to handle task creation/edit
            composeVC.onComposeTask = { [weak self] task in
                task.save()
                self?.refreshTasks()
            }
        }
    }

    // MARK: - Refresh & Sort

    private func refreshTasks() {
        var loadedTasks = Task.getTasks()

        loadedTasks.sort { lhs, rhs in
            if lhs.isComplete && rhs.isComplete {
                return lhs.completedDate! < rhs.completedDate!
            } else if !lhs.isComplete && !rhs.isComplete {
                return lhs.createdDate < rhs.createdDate
            } else {
                return !lhs.isComplete && rhs.isComplete
            }
        }

        self.tasks = loadedTasks
        emptyStateLabel.isHidden = !tasks.isEmpty
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

// MARK: - Table View Data Source

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]

        cell.configure(with: task) { [weak self] updatedTask in
            updatedTask.save()
            self?.refreshTasks()
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks.remove(at: indexPath.row)
            task.delete()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Table View Delegate

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        performSegue(withIdentifier: "ComposeSegue", sender: task)
    }
}


