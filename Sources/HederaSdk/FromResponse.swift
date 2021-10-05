import SwiftProtobuf

protocol FromResponse {
  associatedtype ProtobufResponse
  associatedtype SdkResponse

  func mapResponse(_ response: ProtobufResponse) -> SdkResponse?
}
