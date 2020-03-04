//
//  RestClient.swift
//  PartneriOSTraining
//
//  Created by Kevin Poorman on 2/20/20.
//  Copyright © 2020 PartneriOSTrainingOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import Combine

extension RestClient {
  static let apiVersion = "v48.0"

  /*
   * These typealias' make it easier to reason about what's what in our pipelines
   */
  typealias JSONKeyValuePairs = [String:Any]
  typealias SalesforceRecord = [String:Any]
  typealias SalesforceRecords = [SalesforceRecord]

  func records<Record: Decodable>(forRequest request:RestRequest ) -> AnyPublisher<[Record], Never> {
    return RestClient.shared.publisher(for: request)
      .tryMap({ (response) -> Data in
        response.asData()
      })
      .decode(type: SFResponse<Record>.self, decoder: JSONDecoder())
      .map({ (record) -> [Record] in
        record.records
      })
      .catch({ _ in
        Just([Record]())
      })
      .eraseToAnyPublisher()
  }

  func records<Record: Decodable>(forQuery query:String) -> AnyPublisher<[Record], Never> {
    let request = RestClient.shared.request(forQuery: query, apiVersion: RestClient.apiVersion)
    return self.records(forRequest: request)
  }

  func updateContact(_ contact: Contact) -> AnyPublisher<Bool, Never> {
    return self.updateRecord(withObjectType: "Contact", fields: contact.asDictionary())
  }

  func attach(file: Data, toRecord id: String, withFilename filename: String) -> AnyPublisher<Bool, Never> {
    let attachmentRequest = self.requestForCreatingAttachment(from: file, withFileName: filename, relatingToId: id)
    return self.publisher(for: attachmentRequest)
      .map { $0.urlResponse as! HTTPURLResponse } // swiftlint:disable:this force_cast
      .map { $0.statusCode == 201 }
      .mapError { dump($0) }
      .replaceError(with: false)
      .eraseToAnyPublisher()
  }

  func attach(files: [Data], toRecord id: String, fileType: String) -> AnyPublisher<Bool, Never> {
    let compositeRequestBuilder = CompositeRequestBuilder().setAllOrNone(false)
    for file in files {
      let filename = UUID().uuidString + fileType
      compositeRequestBuilder.add(
        self.requestForCreatingAttachment(from: file, withFileName: filename, relatingToId: id),
        referenceId: UUID().uuidString
      )
    }
    let compositeRequest = compositeRequestBuilder.buildCompositeRequest(RestClient.apiVersion)
    return self.publisher(for: compositeRequest)
      .map { $0.subResponses }
      .map { return $0.map { subResponse in return subResponse.httpStatusCode} }
      .removeDuplicates()
      .map { $0[0] == 201 }
      .replaceError(with: false)
      .eraseToAnyPublisher()
  }

  func createAccount() -> AnyPublisher<String?, Never> {
    let request = self.requestForCreate(withObjectType: "Account", fields: ["name":"testAccount"], apiVersion: RestClient.apiVersion)
    return createReturningId(request: request)
  }

  func createContact(accountId: String) -> AnyPublisher<String?, Never> {
    let request = self.requestForCreate(withObjectType: "Contact",
                                        fields: ["LastName": "Testing", "AccountId": accountId],
                                        apiVersion: RestClient.apiVersion)
    return createReturningId(request: request)
  }

  func createContact(contact: Contact) -> AnyPublisher<String?, Never> {
    let fields = contact.asDictionary()
    let fieldsMinusId = fields.filter { $0.key != "Id" }
    let request = self.requestForCreate(withObjectType: "Contact", fields: fieldsMinusId, apiVersion: RestClient.apiVersion)
    return createReturningId(request: request)
  }

  private func createReturningId(request: RestRequest) -> AnyPublisher<String?, Never> {
    return self.publisher(for: request)
      .tryMap { try $0.asJson() as? RestClient.JSONKeyValuePairs ?? [:]}
      .tryMap { keyValuePairs in
        guard let id = keyValuePairs["id"] as? String else {return ""}
        return id
    }
      //.map { $0["id"] as! String?}
      .replaceError(with: "")
      .eraseToAnyPublisher()
  }

  private func updateRecord(withObjectType objType: String, fields: [String:Any]) -> AnyPublisher<Bool, Never> {
    let id = fields["Id"] as! String // swiftlint:disable:this force_cast
    let fieldsMinusId = fields.filter { $0.key != "Id" }
    let request = self.requestForUpdate(withObjectType: objType, objectId: id, fields: fieldsMinusId, apiVersion: RestClient.apiVersion)
    return self.publisher(for: request)
      .map { $0.urlResponse as! HTTPURLResponse } // swiftlint:disable:this force_cast
      .map { $0.statusCode == 204 }
      .mapError { dump($0) }
      .replaceError(with: false)
      .eraseToAnyPublisher()
  }

  private func requestForCreatingAttachment(
    from data:Data, withFileName fileName: String, relatingToId id: String
  ) -> RestRequest {
    let record = ["VersionData": data.base64EncodedString(options: .lineLength64Characters),
                  "Title": fileName,
                  "PathOnClient": fileName,
                  "FirstPublishLocationId": id
    ]
    return self.requestForCreate(withObjectType: "ContentVersion", fields: record, apiVersion: RestClient.apiVersion)
  }

  func fetchRecords<Record: Decodable>(ofModelType: Record.Type, forRequest request: RestRequest,
                       _ completionBlock: @escaping (Result<[Record], RestClientError>) -> Void) {
    guard request.isQueryRequest else { return }
    RestClient.shared.send(request: request) { result in
      switch result {
        case .success(let response):
          do {
              let decoder = JSONDecoder()
            let wrapper = try decoder.decode(SFResponse<Record>.self, from: response.asData())
            completionBlock(.success(wrapper.records))
          } catch {
            completionBlock(.success([Record]()))
        }
        case .failure(let err):
          completionBlock(.failure(err))
      }
    }
  }

  func fetchRecords<Record: Decodable>(ofModelType: Record.Type,
                                       forQuery query: String,
                                       withApiVersion version: String? = SFRestDefaultAPIVersion,
                                       _ completionBlock: @escaping (Result<[Record], RestClientError>) -> Void) {
    let request = RestClient.shared.request(forQuery: query, apiVersion: version)
    guard request.isQueryRequest else { return }
    return self.fetchRecords(ofModelType: ofModelType, forRequest: request, completionBlock)
  }

}

extension RestRequest {

  /// Calculated property to determine if this request is a data retrieval request with a SOQL query.
  /// All such queries will return a JSON decodable QueryResponseWrapper.
  /// Implied contract is that all requests matching both properties here will be decodable via QueryResponseWrapper<Record>
  public var isQueryRequest: Bool {
    get {
      return self.method == .GET && self.path.lowercased().hasSuffix("query")
    }
  }

}
