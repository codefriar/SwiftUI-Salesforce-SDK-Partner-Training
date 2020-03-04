//
//  FieldView.swift
//  PartneriOSTraining
//
//  Created by Kevin Poorman on 2/24/20.
//  Copyright © 2020 PartneriOSTrainingOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI

struct FieldView: View {
  var label: String
  var value: String?

  var body: some View {
    return HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 3) {
        Text(value ?? "None listed")
        Text(label).font(.subheadline).italic()
      }
    }
  }
}
