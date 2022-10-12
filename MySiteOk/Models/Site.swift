//
//  Site.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 06.10.2022.
//

import RealmSwift
import Foundation

class Site: Object {
    @Persisted(primaryKey: true) var host = ""
    @Persisted var links = List<Link>()

    convenience init(host: String) {
        self.init()
        self.host = host
    }
}
