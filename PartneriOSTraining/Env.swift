//
//  Env.swift
//  PartneriOSTraining
//
//  Created by Kevin Poorman on 2/19/20.
//  Copyright © 2020 PartneriOSTrainingOrganizationName. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import SalesforceSDKCore
import SmartStore

// swiftlint:disable:next type_name
class Env: ObservableObject {
  // Lazy properties
  lazy var sfUserObject = UserAccountManager.shared.currentUserAccount!
  lazy var customOfflineStore = SmartStore.shared(withName: "customStore", forUserAccount: self.sfUserObject)
  lazy var customSoup = customOfflineStore?.registerSoup(withName: soupName, withIndexPaths: ["foo", "id"])

  @Published var queryResults: [String:Any] = [:]
  @Published var propertyToDisplay: String = ""
  var contactId:String?

  private let soupName = "MostAwesomeSoup"
  private var iterationCounter = 0
  private var customSoupPublisher: AnyCancellable?
  private var cancellable: AnyCancellable?
  private var pipeline: AnyPublisher<Bool, Error>?

  /*
   * These methods help illustrate how to interact with SmartStore
   */
  public func insertAndQuerySmartStore() {
    guard customSoup != nil else {return}
    customOfflineStore?.clearSoup(soupName)
    let exampleDictionary = ["foo": "Bar", "id":"1"]
    customOfflineStore?.upsert(entries: [exampleDictionary], forSoupNamed: soupName)
    customSoupPublisher = self.customOfflineStore?.publisher(for: "select * from {\(soupName)}")
      .tryMap { results -> [Any] in
        let asArray = results[0] as? [Any] ?? []
        return asArray
      }
      .tryMap { records in
        let records = records[1] as? [String:Any] ?? [:]
        return records
      }
      .replaceError(with: [:])
      .assign(to: \.queryResults, on:self)
    self.propertyToDisplay = self.queryResults["foo"] as? String ?? ""
  }

  public func updateSoupRecord() {
    queryResults["foo"] = "New Value \(self.iterationCounter)"
    self.iterationCounter += 1
    do {
      try customOfflineStore?.upsert(entries: [queryResults], forSoupNamed: soupName, withExternalIdPath: "id")
    } catch {
      print("Something went wrong")
    }
    customSoupPublisher = self.customOfflineStore?.publisher(for: "select * from {\(soupName)}")
      .tryMap { results -> [Any] in
        let asArray = results[0] as? [Any] ?? []
        return asArray
      }
      .tryMap { records in
        let records = records[1] as? [String:Any] ?? [:]
        return records
      }
      .replaceError(with: [:])
      .assign(to: \.queryResults, on:self)
    self.propertyToDisplay = self.queryResults["foo"] as? String ?? ""
  }

  /*
   * Demonstrate how to sequence api calls
   */
  public func chainedApiCalls() {
    if self.cancellable != nil {
      cancellable?.cancel()
    }

    self.cancellable = RestClient.shared.createAccount()
    .print()
      .receive(on: RunLoop.main)
      .sink { accountId in
        guard let acctId = accountId else {return}
        self.cancellable = RestClient.shared.createContact(accountId: acctId)
          .receive(on: RunLoop.main)
          .assign(to: \.contactId, on: self)
    }
  }

  /*
   * Demonstrates how to make an api call to a third party (non Salesforce) service
   */
  public func dataTaskPublisherDemo() {
    let url = URL(string: "https://api.github.com/users/codefriar/repos")!
    if self.cancellable != nil {
      self.cancellable?.cancel()
    }

    self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
    .print()
      .map {$0.data}
      .decode(type: [Repository].self, decoder: JSONDecoder())
      .replaceError(with: [])
      .sink { repos in
        print("Repo Count: ", repos.count)
    }
  }
}
