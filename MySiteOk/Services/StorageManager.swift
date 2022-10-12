//
//  StorageManager.swift
//  MySiteOk
//
//  Created by Anton Saltykov on 07.10.2022.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()

    let realm = try! Realm()

    private init() {}

    // MARK: - Site Actions
    func save(_ site: Site) {
        write {
            realm.add(site)
        }
    }

    func delete(_ site: Site) {
        write {
            realm.delete(site.links)
            realm.delete(site)
        }
    }

    // MARK: - Link Actions
    func save(_ link: Link, to site: Site) {
        write {
            site.links.append(link)
        }
    }

    func delete(_ link: Link) {
        write {
            realm.delete(link)
        }
    }

    // MARK: - Check Actions
    func save(_ check: Check, to link: Link) {
        write {
            link.checks.append(check)
        }
    }

    // MARK: - Common write action
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
