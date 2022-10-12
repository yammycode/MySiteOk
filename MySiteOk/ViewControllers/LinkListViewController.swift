//
//  LinkListViewController.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 10.10.2022.
//

import UIKit
import RealmSwift

final class LinkListViewController: UITableViewController {

    var site: Site!
    var linkList: List<Link>!

    override func viewDidLoad() {
        super.viewDidLoad()
        linkList = site.links

        let editButton = editButtonItem
        navigationItem.rightBarButtonItem = editButton
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = linkList[indexPath.row].url
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let link = linkList[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let alertMessage = "Are you sure? This action delete link, all nested checks"

            let alert = UIAlertController.createDeleteAlert(withTitle: "Delete link", andMessage: alertMessage) {
                StorageManager.shared.delete(link)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            self.present(alert, animated: true)

        }

        let editAction = UIContextualAction(style: .normal, title: "Detail") { _, _, isDone in
            //self.performSegue(withIdentifier: "goToLinkList", sender: site)
            isDone(true)
        }


        let doneAction = UIContextualAction(style: .normal, title: "Check") { _, _, isDone in
            guard let url = URL(string: link.url) else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                let check = Check()
                if let error = error as? NSError {
                    check.customErrorText = error.localizedDescription
                }
                if let response = response as? HTTPURLResponse {
                    check.statusCode = response.statusCode
                }
                DispatchQueue.main.async {
                    StorageManager.shared.save(check, to: link)
                }

            }.resume()

        }

        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
