//
//  AddressView.swift
//  PartneriOSTraining
//
//  Created by Kevin Poorman on 2/24/20.
//  Copyright © 2020 PartneriOSTrainingOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI

struct AddressView: View {
  var contact: Contact

  var body: some View {
    return HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 3) {
        HStack(spacing: 10) {
          Text(contact.MailingStreet ?? "")
          Text(contact.MailingCity ?? "")
          Text(contact.MailingState ?? "")
          Text(contact.MailingPostalCode ?? "")
        }
        Text("Address").font(.subheadline).italic()
      }
    }
  }
}
