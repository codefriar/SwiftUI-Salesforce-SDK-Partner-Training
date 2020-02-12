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

import Combine
import SmartStore
import MobileSync

/**
 Model object for a single Account
 */
struct Account: Hashable, Identifiable, Decodable {
  let id: String
  let name: String
  let industry: String
  
  static func generateDemoAccounts(numberOfAccounts: Int) -> [Account] {
    var accounts = [Account]()
    for idx in 1...numberOfAccounts{
      accounts.append(
        Account(id: "PRE1234\(idx)", name: "Demo Account - \(idx)", industry: "Industry - \(idx)")
      )
    }
    return accounts
  }
}

/**
 ViewModel for Account List
 */
class AccountsListModel: ObservableObject {
  
  @Published var accounts: [Account] = []
  
  var fetchAccountsCancellable: AnyCancellable?
  var store: SmartStore?
  var syncManager: SyncManager?
  var preview: Bool?
  
  init(_ preview: Bool = false) {
    if !preview {
      self.preview = preview
      store = SmartStore.shared(withName: SmartStore.defaultStoreName)
      syncManager = SyncManager.sharedInstance(store: store!)
    }
  }
  
  func fetchAccounts(){
    _ = syncManager?.publisher(for: "syncDownAccounts")
      .receive(on: RunLoop.main)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in
        self.loadFromSmartStore()
      })
    
    self.loadFromSmartStore()
  }
  
  private func loadFromSmartStore(){
    fetchAccountsCancellable = self.store?.publisher(for: "select {Account:Name}, {Account:Phone}, {Account:Industry}, {Account:Id} from {Account}")
      .receive(on: RunLoop.main)
      .tryMap{
        $0.map { (row) -> Account in
          let r = row as! [String?]
          return Account(id: r[3] ?? "", name: r[0] ?? "", industry: r[2] ?? "Unknown Industry" )
        }
    }
    .catch { error -> Just<[Account]> in
      print(error)
      return Just([Account]())
    }
    .assign(to: \AccountsListModel.accounts, on:self)
  }
  
}
