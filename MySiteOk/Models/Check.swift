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
}
