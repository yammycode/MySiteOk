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
    @Persisted(originProperty: "links") var site: LinkingObjects<Site>

    convenience init(url: String) {
        self.init()
        self.url = url
    }
}
