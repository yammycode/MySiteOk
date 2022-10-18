//
//  Extension + RealmResults.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 17.10.2022.
//

import Foundation
import RealmSwift

extension Results {
  var list: List<Element> {
    reduce(.init()) { list, element in
      list.append(element)
      return list
    }
  }
}
