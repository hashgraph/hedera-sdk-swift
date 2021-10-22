import Foundation
import GRPC
import HederaProtoServices

class Channel {
  var crypto: Proto_CryptoServiceClient?
  var file: Proto_FileServiceClient?
  var contract: Proto_SmartContractServiceClient?
  var topic: Proto_ConsensusServiceClient?
  var freeze: Proto_FreezeServiceClient?
  var network: Proto_NetworkServiceClient?
  var token: Proto_TokenServiceClient?
  var client: ClientConnection?

  init(_ client: ClientConnection) {
    self.client = client
  }

  func getCrypto() -> Proto_CryptoServiceClient {
    if let crypto = crypto {
      return crypto
    }

    if let client = client {
      crypto = Proto_CryptoServiceClient(channel: client)
    }

    return crypto!
  }

  func getFile() -> Proto_FileServiceClient {
    if let file = file {
      return file
    }

    if let client = client {
      file = Proto_FileServiceClient(channel: client)
    }

    return file!
  }

  func getContract() -> Proto_SmartContractServiceClient {
    if let contract = contract {
      return contract
    }

    if let client = client {
      contract = Proto_SmartContractServiceClient(channel: client)
    }

    return contract!
  }

  func getTopic() -> Proto_ConsensusServiceClient {
    if let topic = topic {
      return topic
    }

    if let client = client {
      topic = Proto_ConsensusServiceClient(channel: client)
    }

    return topic!
  }

  func getFreeze() -> Proto_FreezeServiceClient {
    if let freeze = freeze {
      return freeze
    }

    if let client = client {
      freeze = Proto_FreezeServiceClient(channel: client)
    }

    return freeze!
  }

  func getNetwork() -> Proto_NetworkServiceClient {
    if let network = network {
      return network
    }

    if let client = client {
      network = Proto_NetworkServiceClient(channel: client)
    }

    return network!
  }

  func getToken() -> Proto_TokenServiceClient {
    if let token = token {
      return token
    }

    if let client = client {
      token = Proto_TokenServiceClient(channel: client)
    }

    return token!
  }
}
