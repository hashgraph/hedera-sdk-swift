// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: token_airdrop.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

///*
/// # Token Airdrop
/// Messages used to implement a transaction to "airdrop" tokens.<br/>
/// An "airdrop" is a distribution of tokens from a funding account
/// to one or more recipient accounts, ideally with no action required
/// by the recipient account(s).
///
/// ### Keywords
/// The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
/// "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
/// document are to be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119).

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

///*
/// Airdrop one or more tokens to one or more accounts.
///
/// ### Effects
/// This distributes tokens from the balance of one or more sending account(s) to the balance
/// of one or more recipient accounts. Accounts MAY receive the tokens in one of four ways.
///
///  - An account already associated to the token to be distributed SHALL receive the
///    airdropped tokens immediately to the recipient account balance.<br/>
///    The fee for this transfer SHALL include the transfer, the airdrop fee, and any custom fees.
///  - An account with available automatic association slots SHALL be automatically
///    associated to the token, and SHALL immediately receive the airdropped tokens to the
///    recipient account balance.<br/>
///    The fee for this transfer SHALL include the transfer, the association, the cost to renew
///    that association once, the airdrop fee, and any custom fees.
///  - An account with "receiver signature required" set SHALL have a "Pending Airdrop" created
///    and must claim that airdrop with a `claimAirdrop` transaction.<br/>
///    The fee for this transfer SHALL include the transfer, the association, the cost to renew
///    that association once, the airdrop fee, and any custom fees. If the pending airdrop is not
///    claimed immediately, the `sender` SHALL pay the cost to renew the token association, and
///    the cost to maintain the pending airdrop, until the pending airdrop is claimed or cancelled.
///  - An account with no available automatic association slots SHALL have a "Pending Airdrop"
///    created and must claim that airdrop with a `claimAirdrop` transaction.<br/>
///    The fee for this transfer SHALL include the transfer, the association, the cost to renew
///    that association once, the airdrop fee, and any custom fees. If the pending airdrop is not
///    claimed immediately, the `sender` SHALL pay the cost to renew the token association, and
///    the cost to maintain the pending airdrop, until the pending airdrop is claimed or cancelled.
///
/// If an airdrop would create a pending airdrop for a fungible/common token, and a pending airdrop
/// for the same sender, receiver, and token already exists, the existing pending airdrop
/// SHALL be updated to add the new amount to the existing airdrop, rather than creating a new
/// pending airdrop.
///
/// Any airdrop that completes immediately SHALL be irreversible. Any airdrop that results in a
/// "Pending Airdrop" MAY be canceled via a `cancelAirdrop` transaction.
///
/// All transfer fees (including custom fees and royalties), as well as the rent cost for the
/// first auto-renewal period for any automatic-association slot occupied by the airdropped
/// tokens, SHALL be charged to the account paying for this transaction.
///
/// ### Record Stream Effects
/// - Each successful transfer SHALL be recorded in `token_transfer_list` for the transaction record.
/// - Each successful transfer that consumes an automatic association slot SHALL populate the
///   `automatic_association` field for the record.
/// - Each pending transfer _created_ SHALL be added to the `pending_airdrops` field for the record.
/// - Each pending transfer _updated_ SHALL be added to the `pending_airdrops` field for the record.
public struct Proto_TokenAirdropTransactionBody: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A list of token transfers representing one or more airdrops.
  /// The sender for each transfer MUST have sufficient balance to complete the transfers.
  ///
  /// All token transfers MUST successfully transfer tokens or create a pending airdrop
  /// for this transaction to succeed.
  /// This list MUST contain between 1 and 10 transfers, inclusive.
  ///
  /// Note that each transfer of fungible/common tokens requires both a debit and
  /// a credit, so each _fungible_ token transfer MUST have _balanced_ entries in the
  /// TokenTransferList for that transfer.
  public var tokenTransfers: [Proto_TokenTransferList] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_TokenAirdropTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TokenAirdropTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "token_transfers"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.tokenTransfers) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.tokenTransfers.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.tokenTransfers, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TokenAirdropTransactionBody, rhs: Proto_TokenAirdropTransactionBody) -> Bool {
    if lhs.tokenTransfers != rhs.tokenTransfers {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
