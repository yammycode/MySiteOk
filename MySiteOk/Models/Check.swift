//
//  Check.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 06.10.2022.
//
import Foundation
import RealmSwift

class Check: Object {
    @Persisted var uuid = UUID()
    @Persisted var date = Date()
    @Persisted var statusCode: Int? = nil
    @Persisted var customErrorText: String? = nil
    @Persisted(originProperty: "checks") var link: LinkingObjects<Link>

    var statusCodeDescription: String {
        if let statusCode {
            return "\(statusCode.formatted()): \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
        } else if let customErrorText {
            return customErrorText
        } else {
            return "Unknown error"
        }

    }
}
