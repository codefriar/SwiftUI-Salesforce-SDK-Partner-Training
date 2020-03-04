//
//  Contact.swift
//  PartneriOSTraining
//
//  Created by Kevin Poorman on 2/23/20.
//  Copyright © 2020 PartneriOSTrainingOrganizationName. All rights reserved.
//

import Foundation
import Combine
import SalesforceSDKCore
/*
 * Data Model for Contact.
 * Note that the field names specifically match the response from Salesforce
 */

struct Contact :  Identifiable, Decodable {
  // swiftlint:disable identifier_name
  let id: UUID = UUID()
  let Id: String?
  var FirstName: String?
  var LastName: String?
  var Phone: String?
  var Email: String?
  var MailingStreet: String?
  var MailingCity: String?
  var MailingState: String?
  var MailingPostalCode: String?
  var AccountId: String?
  // swiftlint:enable identifer_name
  func asDictionary() -> [String:String] {
    return [
      "Id": self.Id ?? "",
      "AccountId": self.AccountId ?? "",
      "FirstName": self.FirstName ?? "",
      "LastName": self.LastName ?? "",
      "Phone": self.Phone ?? "",
      "Email": self.Email ?? "",
      "MailingStreet": self.MailingStreet ?? "",
      "MailingCity": self.MailingCity ?? "",
      "MailingState": self.MailingState ?? "",
      "MailingPostalCode": self.MailingPostalCode ?? ""
    ]
  }

  func formattedAddress() -> String {
    return "\(self.MailingStreet ?? "") \(self.MailingCity ?? "") \(self.MailingState ?? "")  \(self.MailingPostalCode ?? "")"
  }

  func updateSalesforce() -> AnyPublisher<Bool, Never> {
    RestClient.shared.updateContact(self)
  }
}

/*
 * This is the struct representing the full JSON response from Salesforce
 * Note that it includes the array of [Contact] objects (above)
 */

struct ContactResponse: Decodable {
  var totalSize: Int
  var done: Bool
  var records: [Contact]
}

struct SFResponse<R: Decodable>: Decodable {
  var totalSize: Int
  var done: Bool
  var records: [R]
}
