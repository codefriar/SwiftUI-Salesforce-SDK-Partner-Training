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
import SalesforceSDKCore
import Combine

/*
 * ViewModel for the ContactsForAccounts Scene.
 */
class ContactsForAccountModel: ObservableObject {
  @Published var contacts: [Contact] = []
  var contactsForCancellable: AnyCancellable?

  var account: Account?

  func fetchContactsForAccount() {
    guard let acct = self.account else {return}
    
    // swiftlint:disable:next line_length
    let request = RestClient.shared.request(forQuery: "SELECT id, firstName, lastName, phone, email, mailingStreet, mailingCity, mailingState, mailingPostalCode, AccountId FROM Contact WHERE AccountID = '\(acct.id)'", apiVersion: nil)
    
    /*
     * What follows is two different methods for achieving the same goal -
     *  run a soql query, and generate Contact objects from the returned results
     *  I hope this api will be available in the next release of the SDK. Failing
     *  that, you can always take it from the RestClient extension included here.
     *
     * I'm including this here, so that you can compare and contrast, and ensure you
     * understand what's happening with the Combine side of things
     */
    
    // MARK: Swift 5, with Combine
    contactsForCancellable = RestClient.shared.records(forRequest: request)
      .receive(on: RunLoop.main)
      .assign(to: \.contacts, on: self)
    

    // MARK: Swift 4, without Combine
    /*
    RestClient.shared.fetchRecords(ofModelType: Contact.self, forRequest: request) { result in
      switch result {
        case .success(let records):
          DispatchQueue.main.async {
            self.contacts = records
          }
        case .failure(let error):
          print(error)
      }
    }
    */


  }
}
