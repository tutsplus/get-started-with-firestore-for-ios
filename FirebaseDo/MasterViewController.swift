//
//  MasterViewController.swift
//  FirebaseDo
//
//  Created by Doron Katz on 6/8/17.
//  Copyright © 2017 Doron Katz. All rights reserved.
//

import UIKit
import Firebase

class MasterViewController: UITableViewController {
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private var documents: [DocumentSnapshot] = []
    public var tasks: [Task] = []
    private var listener : ListenerRegistration!
   
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("Tasks").limit(to: 50)
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.query = baseQuery()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Task in
                if let task = Task(dictionary: document.data(), id: document.documentID) {
                    return task
                } else {
                    fatalError("Unable to initialize type \(Task.self) with dictionary \(document.data())")
                }
            }
            
            self.tasks = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
}

//MARK: TableView Delegate and DataSource methods
extension MasterViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = tasks[indexPath.row]
        
        cell.textLabel!.text = item.name
        cell.textLabel!.textColor = item.done == false ? UIColor.black : UIColor.lightGray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        let item = tasks[indexPath.row]
        let collection = Firestore.firestore().collection("Tasks")

        collection.document(item.id).updateData([
            "done": !item.done,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if (editingStyle == .delete){
            let item = tasks[indexPath.row]
            _ = Firestore.firestore().collection("Tasks").document(item.id).delete()
        }

    }
}

//MARK: AddTask method
extension MasterViewController{
    @IBAction func addTask(_ sender: Any) {
        
        let alertVC : UIAlertController = UIAlertController(title: "New Task", message: "What do you want to remember?", preferredStyle: .alert)
        
        alertVC.addTextField { (UITextField) in
            
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
        
        alertVC.addAction(cancelAction)
        
        //Alert action closure
        let addAction = UIAlertAction.init(title: "Add", style: .default) { (UIAlertAction) -> Void in
            
            let textFieldReminder = (alertVC.textFields?.first)! as UITextField
            
            let db = Firestore.firestore()
            var docRef: DocumentReference? = nil
            docRef = db.collection("Tasks").addDocument(data: [
                "name": textFieldReminder.text ?? "empty task",
                "done": false
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(docRef!.documentID)")
                }
            }
            
        }
    
        alertVC.addAction(addAction)
        present(alertVC, animated: true, completion: nil)
        
    }
}
