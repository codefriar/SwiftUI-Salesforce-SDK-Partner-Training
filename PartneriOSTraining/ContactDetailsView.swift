/*
 Copyright (c) 2019-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import SwiftUI
import Combine
import SalesforceSDKCore
import CodeScanner
import MapKit

struct ContactDetailView: View {
  @Binding var contact: Contact
  @Environment(\.editMode) var mode
  @EnvironmentObject var env: Env
  @State var updateCancellable: AnyCancellable?
  @State private var showingImagePicker = false
  @State private var images = [UIImage]()
  @State private var attachmentCancellable: AnyCancellable?
  @State private var showToast: Bool = false
  @State var mapView: MKMapView = MKMapView()

  var body: some View {
    VStack(alignment: .center, spacing: 20) {
      HStack {
        Button("Add Photo") {
          self.showingImagePicker = true
        }.padding()
      }
      .sheet(isPresented: $showingImagePicker) {
        PhotosAndImagePickerView(selectedImages: self.$images)
          .onDisappear {
            if !self.images.isEmpty {
              let dataArray = self.images.map { img in
                return img.resizeByQuarter().pngData()!
              }
              if let id = self.contact.Id {
                self.attachmentCancellable = RestClient.shared.attach(files: dataArray, toRecord: id, fileType: ".png")
                  .receive(on: RunLoop.main)
                  .sink { _ in
                    self.showToast = true
                }
              }
            }
        }
      }
      MapView(mapView: $mapView, address: contact.formattedAddress(), contactName: contact.FirstName ?? "No Name Given")
        .frame(width: nil, height: 250.0, alignment: .center)

      if self.mode?.wrappedValue == .inactive {
        List {
          FieldView(label: "First Name", value: contact.FirstName)
          FieldView(label: "Last Name", value: contact.LastName)
          FieldView(label: "Email", value: contact.Email)
          FieldView(label: "Phone Number", value: contact.Phone)
          AddressView(contact: contact)
        }
      } else {
        ContactEditView(contact: $contact)
          .onDisappear {
            self.updateCancellable = self.contact.updateSalesforce()
              .receive(on: RunLoop.main)
              .sink { result in
                print(result)
            }
        }
      }
    }
    .toast(isShowing: self.$showToast, text: Text("Files Uploaded"))
    .navigationBarItems(trailing: EditButton())
  }
}

struct ContactDetailView_Previews: PreviewProvider {
  @State static var contact = Contact(
    Id: "123456",
    FirstName: "Astro",
    LastName: "Nomical",
    Phone: "9198675309",
    Email: "Astro.Nomical@gmail.com",
    MailingStreet: "123 Sessame St",
    MailingCity: "Sunny Days",
    MailingState: "NJ",
    MailingPostalCode: "12345"
  )

  static var previews: some View {
    ContactDetailView(contact: $contact)
  }
}
