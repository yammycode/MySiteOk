//
//  Link.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 06.10.2022.
//

import Foundation
import RealmSwift

class Link: Object {
    @Persisted(primaryKey: true) var url = ""
    @Persisted var checks = List<Check>()

    convenience init(url: String) {
        self.init()
        self.url = url
    }
}
