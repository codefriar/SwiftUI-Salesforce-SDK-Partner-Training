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

struct ContactsForAccountListView: View {
  @ObservedObject var viewModel = ContactsForAccountModel()
  @State private var isShowingScanner = false
  @State private var cancellable: AnyCancellable?

  var account: Account

  var body: some View {
    VStack(alignment: .center, spacing: 20) {
      HStack {
        Button("ScanQR Code") {
          self.isShowingScanner = true
        }.padding()
      }
      List(self.viewModel.contacts.indices, id: \.self) { index in
        NavigationLink(destination: ContactDetailView(contact: self.$viewModel.contacts[index])) {
          HStack {
            Text(self.viewModel.contacts[index].FirstName ?? "No First Name")
            Text(self.viewModel.contacts[index].LastName ?? "No Last Name")
          }
        }
      }
    }
    .navigationBarTitle(Text("Contacts for \(account.name)"))
    .onAppear {
      self.viewModel.account = self.account
      self.viewModel.fetchContactsForAccount()
    }
    .sheet(isPresented: $isShowingScanner) {
      CodeScannerView(codeTypes: [.qr, .code128, .upce, .code128, .aztec], simulatedData: "Kevin Poorman\nkjp@Codefriar.com", completion: self.handleScan)
    }
  }

  func handleScan(result: Result<String, CodeScannerView.ScanError>) {
    self.isShowingScanner = false
    switch result {
    case .success(let code):
      let details = code.components(separatedBy: "\n")
      guard details.count == 2 else { return }
      let name = details[0]
      let split = name.split(separator: " ")
      let firstName = String(split[0])
      let lastName = String(split[1])
      if let accountId = self.viewModel.account?.id {
        let contact = Contact(
          Id: nil,
          FirstName: firstName,
          LastName: lastName,
          Email: details[1],
          AccountId: accountId
        )
        cancellable = RestClient.shared.createContact(contact: contact)
          .receive(on: RunLoop.main)
          .sink { _ in
            self.viewModel.contacts = [Contact]()
            self.viewModel.fetchContactsForAccount()
        }
      }
    case .failure(let error):
      print("Scanning failed", error)
    }
  }
}

struct ContactsForAccountListView_previews: PreviewProvider {
  static var previews: some View {
    ContactsForAccountListView(account: Account(
      id: "12345",
      name:"Test Account",
      industry: "Stuff"
    ))
  }
}
