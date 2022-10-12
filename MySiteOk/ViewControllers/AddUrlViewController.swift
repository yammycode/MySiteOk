//
//  AddUrlViewController.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 08.10.2022.
//

import UIKit

final class AddUrlViewController: UIViewController {

    @IBOutlet var urlTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    

    @IBAction func addButtonPressed() {
        guard let urlFromTF = urlTextField.text else { return }
        guard let url = getUrl(url: urlFromTF) else { return }
        addUrl(url: url)
    }

    private func getUrl(url: String) -> URL? {
        guard let url = URL(string: url) else {
            showAlert(with: "URL incorrect", and: "Please check url address")
            return nil
        }
        return url
    }

    private func addUrl(url: URL) {

        let site: Site
        let urlString = url.absoluteString

        if let _ = StorageManager.shared.realm.object(ofType: Link.self, forPrimaryKey: urlString) {
            showAlert(with: "Link already exist", and: "Check urls list")
            return
        }

        guard let host = url.host() else { return }

        if let existingSite = StorageManager.shared.realm.object(ofType: Site.self, forPrimaryKey: host) {
            site = existingSite
        } else {
            site = Site(host: host)
            StorageManager.shared.save(site)
        }

        let link = Link(url: urlString)

        StorageManager.shared.save(link, to: site)

    }
    
}

extension AddUrlViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension AddUrlViewController {
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default)

        alert.addAction(closeAction)
        present(alert, animated: true)
    }
}
