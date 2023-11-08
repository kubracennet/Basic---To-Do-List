//
//  ViewController.swift
//  Basic - To Do List
//
//  Created by Kübra Cennet Yavaşoğlu on 6.11.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }
    
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Uyarı",
                     message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            self.data.removeAll()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addBarButtonItem(_ sender: Any) {
        presentAddAlert()
    }
    
    
 /*       let alertController = UIAlertController(title: "Yeni Eleman Ekle",
                                                message: nil,
                                                preferredStyle: .alert)
        
        let defaultButton = UIAlertAction(title: "Ekle",
                                          style: .default) { _ in
            let text = alertController.textFields?.first?.text
            if text  != "" {
                self.data.append((text)!)
                self.tableView.reloadData()
            } else {
                self.presentWarningAlert()
            }
            
        }
        
        let cancelButton = UIAlertAction(title: "Vazgeç", style: .cancel)
        
        alertController.addTextField()
        
        alertController.addAction(defaultButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
   */
        
    func presentAddAlert() {
        presentAlert(title: "Yeni Eleman Ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailabe: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text  != "" {
               // self.data.append((text)!) Core data bağlantısını yatıktan sonra stringi append etmeye çalışmıyorum artık bu yüzden bu kodu kaldırırım.
                //kayıt işlemini yapacağım. öncelikle veri tabanıma ulaşmalıyım veri tabanıma ulaşıp oraya bilgiyi kaydedeceğim.
                let appDelegate = UIApplication.shared.delegate as? AppDelegate // appdelegate uygulamadan bazı bilgiler alıyorum.
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        })
        
    }
    func presentWarningAlert() {
        presentAlert(title: "Uyarı!",
                     message: "Liste elemanı boş olamaz.",
                     cancelButtonTitle: "Tamam")
        
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?, isTextFieldAvailabe: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)

        }

        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvailabe {
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
    func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchrequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
       data = try! managedObjectContext!.fetch(fetchrequest)
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell",
                                                 for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        //attribute adını ne koyduysam onu yazdım. Value tipini bilmediği için hata verir ben de cast işlemi yaparım as? string diyerek.
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
            
            //self.data.remove(at: indexPath.row)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal,
                                              title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Elemanı Düzenle",
                         message: nil,
                         defaultButtonTitle: "Düzenle",
                         cancelButtonTitle: "Vazgeç",
                         isTextFieldAvailabe: true,
                         defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text  != "" {
                    //self.data[indexPath.row] = text! edit işlemi yapmama gerek yok bu yüzden kaldırırm farklı şekilde yapacağım bunuarrayin kendisini değil veri tabanını editleyeceğiz.
                   
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
            
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return config
        
    }
}
