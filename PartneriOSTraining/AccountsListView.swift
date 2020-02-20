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

struct AccountsListView: View {
  @ObservedObject var viewModel: AccountsListModel
  @EnvironmentObject var env: Env
  
  init(_ viewModel: AccountsListModel = AccountsListModel()){
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationView {
      VStack{
        Text(self.env.foo)
        Button("Update SmartStore") {
          self.env.updateSoupRecord()
        }
        List(viewModel.accounts) { dataItem in
          NavigationLink(destination: ContactsForAccountListView(account: dataItem)){
            HStack(spacing: 10) {
              VStack(alignment: .leading, spacing: 3) {
                Text(dataItem.name)
                Text(dataItem.industry).font(.subheadline).italic()
              }
            }
          }
        }
        .navigationBarTitle(Text("My Accounts"), displayMode: .inline)
        .navigationBarItems(
          leading: Button("Logout") {
            self.viewModel.accounts = []
            UserAccountManager.shared.logout()
          }
        )
      }
    }
    .onAppear{
      self.viewModel.fetchAccounts()
      self.env.insertAndQuerySmartStore()
    }
  }
}

struct AccountsList_Previews: PreviewProvider {
  static var previews: some View {
    let preview = AccountsListView(AccountsListModel(true))
    preview.viewModel.accounts = Account.generateDemoAccounts(numberOfAccounts: 15)
    return Group {
      preview.environment(\.colorScheme, .dark)
      preview.environment(\.colorScheme, .light)
    }
  }
}

