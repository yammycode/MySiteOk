//
//  HistoryViewController.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 15.10.2022.
//

import UIKit
import RealmSwift

enum CountFilter {
    case all
    case last
    case errorLast
    case threeLast
}

final class HistoryViewController: UITableViewController {

    var linkDBList: Results<Link>!
    var linkList: [Link] = []
    var countFilterValue: CountFilter = .all


    override func viewDidLoad() {
        super.viewDidLoad()

        linkDBList = StorageManager.shared.realm.objects(Link.self)
        setLinkList()

        let filterBarButton = getFilterBarButton()
        self.navigationItem.rightBarButtonItems = [filterBarButton]

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return linkList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        linkList[section].url
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkList[section].checks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyChecklCell", for: indexPath)
        let check = linkList[indexPath.section].checks[indexPath.row]

        // TODO: убрать дубль
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium

        var content = cell.defaultContentConfiguration()

        content.text = check.statusCodeDescription
        content.secondaryText = dateFormatter.string(from: check.date)
        cell.contentConfiguration = content

        return cell
    }


    private func getFilterBarButton() -> UIBarButtonItem {
        let toggleOfCountHandler: (_ action: UIAction) -> () = { action in
            switch action.identifier.rawValue {
            case "all":
                self.countFilterValue = .all
            case "last":
                self.countFilterValue = .last
            case "3_last":
                self.countFilterValue = .threeLast
            default:
                break
            }
            self.setLinkList()
            self.tableView.reloadData()
        }

        let toggleErrorHandler: (_ action: UIAction) -> () = { _ in
            self.countFilterValue = .errorLast
            self.setLinkErrorList()
            self.tableView.reloadData()
        }


        let actions = [
            UIAction(title: "All checks",
                     identifier: UIAction.Identifier("all"),
                     handler: toggleOfCountHandler),

            UIAction(title: "Only last check",
                     identifier: UIAction.Identifier("last"),
                     handler: toggleOfCountHandler),

            UIAction(title: "Only last error check",
                     identifier: UIAction.Identifier("error_last"),
                     handler: toggleErrorHandler),

            UIAction(title: "3 last checks",
                     identifier: UIAction.Identifier("3_last"),
                     handler: toggleOfCountHandler)
        ]

        let menu = UIMenu(title: "Count of last checks",  children: actions)

        return UIBarButtonItem(title: "", image: UIImage(systemName: "slider.horizontal.3"), menu: menu)
    }

}


// MARK: - Filter data extension
extension HistoryViewController {
    private func setLinkList() {
        linkList = []
        linkDBList.forEach { link in
            let checks = link.checks.sorted(byKeyPath: "date", ascending: false)
            let link = Link(url: link.url)

            for (index, check) in checks.list.enumerated() {
                link.checks.append(check)
                if countFilterValue == .last && index == 0 { break }
                if countFilterValue == .threeLast && index == 2 { break }
            }
            linkList.append(link)
        }
    }

    private func setLinkErrorList() {
        linkList = []
        linkDBList.forEach { link in
            let checks = link.checks.sorted(byKeyPath: "date", ascending: false)
            if let check = checks.first, isError(check) {
                let link = Link(url: link.url)
                link.checks.append(check)
                linkList.append(link)
            }
        }
    }

    private func isError(_ check: Check) -> Bool {
        guard let statusCode = check.statusCode else { return true }
        return statusCode < 200 || statusCode > 299
    }
}
