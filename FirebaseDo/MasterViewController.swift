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
        
        let collection = Firestore.firestore().collection("Tasks")
        
        let item = tasks[indexPath.row]
        
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
    // [1]
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // [2]
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if (editingStyle == .delete){
//            let item = remindersList[indexPath.row]
//            try! self.realm.write({
//                self.realm.delete(item)
//            })
//
//            tableView.deleteRows(at:[indexPath], with: .automatic)
//
//        }
//
//    }
}
