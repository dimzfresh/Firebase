//
//  TasksViewController.swift
//  toDoFirebase
//
//  Created by Dimz on 15.05.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import UIKit 
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User!
    var ref: FIRDatabaseReference?
    var tasks = [Task]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = FIRAuth.auth()?.currentUser else { return }
        user = User(user: currentUser)
        ref = FIRDatabase.database().reference(withPath: "users").child(user.uid).child("tasks")
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ref?.observe(.value, with: { [weak self] (snapshot) in
            
            var _tasks = [Task]()
            
            for item in snapshot.children {
                
                let task = Task(snapshot: item as! FIRDataSnapshot)
                
                _tasks.append(task)
            }
            
            self?.tasks = _tasks
            
            self?.tableView.reloadData()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ref?.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        let isCompleted = task.completed
        toggleCompletion(cell, isCompleted: isCompleted)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
        
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
       alertController.addTextField()
        let save = UIAlertAction(title: "save", style: .default) { _ in
            
        guard let textField = alertController.textFields?.first, textField.text != "" else { return }
            
        let task = Task(title: textField.text!, userId: self.user.uid)
            
        let taskRef = self.ref?.child(task.title.lowercased())
        taskRef?.setValue(task.convertToDictionary())
            
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let task = self.tasks[indexPath.row]
            //task.ref?.removeValue()
            ref?.child(task.title).removeValue()
            
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let task = self.tasks[indexPath.row]
        let isCompleted = !task.completed
        
        toggleCompletion(cell, isCompleted: isCompleted)
        
        task.ref?.updateChildValues(["completed" : isCompleted])
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            print(error.localizedDescription)
            return
        }
        
       dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
