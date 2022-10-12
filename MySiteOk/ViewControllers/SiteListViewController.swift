//
//  SiteListViewController.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 07.10.2022.
//

import UIKit
import RealmSwift

final class SiteListViewController: UITableViewController {

    var siteList: Results<Site>!

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()

        siteList = StorageManager.shared.realm.objects(Site.self)

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )

        navigationItem.rightBarButtonItem = addButton
        let editButton = editButtonItem
        navigationItem.leftBarButtonItem = editButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "My sites"
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = siteList[indexPath.row].host
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let site = getSite(by: indexPath)

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.showDeleteAlert(for: site)
        }

        let editAction = UIContextualAction(style: .normal, title: "Detail") { _, _, isDone in
            self.goToDetail(site: site)
            isDone(true)
        }

        let doneAction = UIContextualAction(style: .normal, title: "Check") { _, _, isDone in
            self.check(site: site)
            isDone(true)
        }

        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionsAlert(for: getSite(by: indexPath))
    }


     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if let linksVC = segue.destination as? LinkListViewController,
            let site = sender as? Site {
             linksVC.site = site
         }
     }

    @objc private func addButtonPressed() {
        performSegue(withIdentifier: "goToAddUrl", sender: nil)
    }
}

// MARK: - Some helpers
extension SiteListViewController {
    /// Get site by row index from siteList
    private func getSite(by indexPath: IndexPath) -> Site {
        siteList[indexPath.row]
    }

    /// Get site table index path by site object
    private func getIndexPath(for site: Site) -> IndexPath? {
        guard let siteIndex = siteList.firstIndex(of: site) else { return nil }
        return IndexPath(row: siteIndex, section: 0)
    }
}

// MARK: - Actions alert extension
extension SiteListViewController {
    private func showActionsAlert(for site: Site) {

        let alert = UIAlertController(title: site.host, message: nil, preferredStyle: .actionSheet)

        let detailAction = UIAlertAction(title: "Show detail", style: .default) {_ in
            self.goToDetail(site: site)
        }

        let checkAction = UIAlertAction(title: "Check all site links", style: .default) {_ in
            self.check(site: site)
        }

        let deleteAction = UIAlertAction(title: "Delete site", style: .destructive) {_ in
            self.showDeleteAlert(for: site)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(checkAction)
        alert.addAction(detailAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    /// Show delete confirm modal
    private func showDeleteAlert(for site: Site) {
        let alertMessage = "Are you sure? This action delete site inside app, all related links and checks"

        let alert = UIAlertController.createDeleteAlert(withTitle: "Delete \(site.host)?", andMessage: alertMessage) {
            self.delete(site: site) {
                guard let indexPath = self.getIndexPath(for: site) else { return }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        self.present(alert, animated: true)
    }

}

// MARK: - Actions
extension SiteListViewController {
    /// Site delete action
    private func delete(site: Site, completion: () -> ()) {
        StorageManager.shared.delete(site)
        completion()
    }

    /// Action for go to site detail page with links
    private func goToDetail(site: Site) {
        performSegue(withIdentifier: "goToLinkList", sender: site)
    }

    /// Action for check all related links for site
    private func check(site: Site) {
        print("check site")
    }
    
}
