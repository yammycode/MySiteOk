//
//  Extension + UIAlertController.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 10.10.2022.
//

import Foundation
import UIKit

extension UIAlertController {
    static func createDeleteAlert(withTitle title: String,
                                  andMessage message: String,
                                  completion: @escaping () -> Void) ->UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {_ in
            completion()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        return alert

    }
}
