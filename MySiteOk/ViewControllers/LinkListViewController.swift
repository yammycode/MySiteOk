//
//  LinkListViewController.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 10.10.2022.
//

import UIKit
import RealmSwift
import SafariServices

final class LinkListViewController: UITableViewController {

    var site: Site!
    var linkList: List<Link>!

    override func viewDidLoad() {
        super.viewDidLoad()
        linkList = site.links

        let editButton = editButtonItem
        navigationItem.rightBarButtonItem = editButton
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let checkListVC = segue.destination as? CheckListViewController,
              let link = sender as? Link
        else { return }
        checkListVC.link = link
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionsAlert(for: getLink(by: indexPath))
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}


// MARK: - Some helpers
extension LinkListViewController {
    /// Get link by row index from siteList
    private func getLink(by indexPath: IndexPath) -> Link {
        linkList[indexPath.row]
    }

    /// Get link table index path by site object
    private func getIndexPath(for link: Link) -> IndexPath? {
        guard let linkIndex = linkList.firstIndex(of: link) else { return nil }
        return IndexPath(row: linkIndex, section: 0)
    }
}

// MARK: - Actions alert extension
extension LinkListViewController {
    private func showActionsAlert(for link: Link) {

        let alert = UIAlertController(title: site.host, message: nil, preferredStyle: .actionSheet)

        let goToChecListAction = UIAlertAction(title: "Go to check list", style: .default) {_ in
            self.goToCheckList(link)
        }

        let showWebAction = UIAlertAction(title: "Open url in browser", style: .default) {_ in
            self.openWeb(link)
        }

        let deleteAction = UIAlertAction(title: "Delete link", style: .destructive) {_ in
            self.showDeleteAlert(for: link)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(goToChecListAction)
        alert.addAction(showWebAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    /// Show delete confirm modal
    private func showDeleteAlert(for link: Link) {
        let alertMessage = "Are you sure? This action delete site inside app, all related links and checks"

        let alert = UIAlertController.createDeleteAlert(withTitle: "Delete \(link.url)?", andMessage: alertMessage) {
            self.delete(link: link) {
                //                guard let indexPath = self.getIndexPath(for: link) else { return }
                //                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        self.present(alert, animated: true)
    }
}

// MARK: - Actions
extension LinkListViewController {
    /// Link delete action
    private func delete(link: Link, completion: () -> ()) {
        StorageManager.shared.delete(link)
        completion()
    }

    /// Open link in safari browser
    private func openWeb(_ link: Link) {
        guard let url = URL(string: link.url) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    private func goToCheckList(_ link: Link) {
        performSegue(withIdentifier: "goToLinkDetail", sender: link)
    }


}
