import Foundation
import HederaProtoServices

enum EntityIdError: Error, Equatable {
  case wrongChecksum(String)
  case invalidFormat(String)
  case errNetworkNameMissing(String)
}

struct ParseAddressResult {
  var status: Int32 = 0
  var num1: UInt64 = 0
  var num2: UInt64 = 0
  var num3: UInt64 = 0
  var correctChecksum: String = ""
  var givenChecksum: String = ""
  var noChecksumFormat: String = ""
  var withChecksumFormat: String = ""

  init() {}
}

struct EntityId {
  let shard: UInt64
  let realm: UInt64
  let num: UInt64
  var checksum: String?

  init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64) {
    self.shard = shard
    self.realm = realm
    self.num = num
  }

  /// Create an EntityId with shard and realm set to 0.
  init(_ num: UInt64) {
    shard = 0
    realm = 0
    self.num = num
  }

  init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64, checksum: String) {
    self.shard = shard
    self.realm = realm
    self.num = num
    self.checksum = checksum
  }

  init(_ proto: Proto_AccountID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.accountNum)
  }

  init(_ proto: Proto_ContractID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.contractNum)
  }

  init(_ proto: Proto_FileID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.fileNum)
  }

  init(_ proto: Proto_TokenID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.tokenNum)
  }

  static func checkChecksum(_ ledgerId: String, _ addr: String) -> String {
    var answer = String()
    var d = [Int32]()
    var s0: UInt64 = 0
    var s1: UInt64 = 0
    var s: UInt64 = 0
    var sh: UInt64 = 0
    var c: UInt64 = 0
    let p3: UInt64 = 26 * 26 * 26
    let p5: UInt64 = 26 * 26 * 26 * 26 * 26
    let asciiA: UInt64 = 97
    let m: UInt64 = 1_000_003
    let w = UInt64(31)

    let id = ledgerId + "000000000000"
    let idBuf: [UInt8] = Array(id.utf8)
    let addrBuf: [UInt8] = Array(addr.utf8)
    var h = [Int32]()

    for index in stride(from: 0, to: idBuf.count, by: 2) {
      var processed = Int32(String(bytes: idBuf[index...index + 1], encoding: .utf8)!, radix: 16)!
      h.append(processed)
      if (index + 3) == idBuf.count {
        processed = Int32(
          String(bytes: idBuf[index...idBuf.count - 1], encoding: .utf8)!, radix: 16)!
        h.append(processed)
        break
      }
    }

    for index in addrBuf {
      let chr = Character(UnicodeScalar(index))
      d.append((chr == Character(".")) ? Int32(10) : Int32(String(chr))!)
    }

    for index in 0..<d.count {
      s = (w * s + UInt64(d[index])) % p3
      if index % 2 == 0 {
        s0 = (s0 + UInt64(d[index])) % 11
      } else {
        s1 = (s1 + UInt64(d[index])) % 11
      }
    }

    for index in h {
      sh = (w * sh + UInt64(index)) % p5
    }
    c = (((UInt64(addr.count % 5) * 11 + s0) * 11 + s1) * p3 + s + sh) % p5
    c = (c * m) % p5

    for _ in 0..<5 {
      answer = String(Character(UnicodeScalar(UInt32(asciiA + (c % 26)))!)) + answer
      c = c / 26
    }

    return String(answer)
  }

  static func checksumVerify(_ num: Int32) throws {
    switch num {
    case 0:
      throw EntityIdError.invalidFormat(
        "Invalid ID: format should look like 0.0.123 or 0.0.123-laujm")
    case 1:
      throw EntityIdError.wrongChecksum(
        "Invalid ID: checksum does not match, possible network mismatch")
    case 2:
      return
    case 3:
      return
    default:
      throw EntityIdError.invalidFormat("Invalid ID: Unrecognized status")
    }
  }

  static func checksumParseAddress(_ ledgerId: String, _ address: String) -> ParseAddressResult {
    var result = ParseAddressResult()
    let range = NSRange(
      address.startIndex..<address.endIndex,
      in: address
    )
    let matches = idAndChecksum.matches(
      in: address, options: [],
      range: range)

    guard let match = matches.first else {
      result.status = 0
      return result
    }

    var nums: [String] = []

    for rangeIndex in 0..<match.numberOfRanges {
      let matchRange = match.range(at: rangeIndex)

      if matchRange == range { continue }

      if let substringRange = Range(matchRange, in: address) {
        let capture = String(address[substringRange])
        nums.append(capture)
      }
    }

    let ad = nums[0] + "." + nums[1] + "." + nums[2]

    let chksum = checkChecksum(ledgerId, ad)

    var status: Int32 = 0
    var given = String()
    if nums.count == 3 {
      status = 2
    } else {
      given = nums[3]
      switch nums[3] {
      case chksum:
        status = 3
        break
      default:
        status = 1
        break
      }
    }

    result.num1 = UInt64(nums[0])!
    result.num2 = UInt64(nums[1])!
    result.num3 = UInt64(nums[2])!
    result.correctChecksum = chksum
    result.status = status
    result.noChecksumFormat = ad
    result.withChecksumFormat = ad + "-" + chksum
    result.givenChecksum = given

    return result
  }

  public func toStringWithChecksum(_ client: Client) throws -> String {
    if client.network.networkName != nil {
      let tempChecksum = EntityId.checksumParseAddress(
        client.network.networkName!.ledgerId(), "\(shard).\(realm).\(num)")
      return tempChecksum.withChecksumFormat
    } else {
      throw EntityIdError.errNetworkNameMissing(
        "NetworkName is empty")
    }
  }

  public mutating func validate(_ client: Client) throws {
    var str = "\(shard).\(realm).\(num)"
    if let checksum = checksum {
      str = str + "-\(checksum)"
    }
    if client.network.networkName != nil {
      let tempChecksum = EntityId.checksumParseAddress(
        client.network.networkName!.ledgerId(), str)
      try EntityId.checksumVerify(tempChecksum.status)
      if checksum == "" {
        checksum = tempChecksum.correctChecksum
      }
      if tempChecksum.correctChecksum != checksum {
        throw EntityIdError.wrongChecksum(
          "Invalid ID: checksum does not match, possible network mismatch")
      }
    } else {
      throw EntityIdError.errNetworkNameMissing(
        "NetworkName is empty")
    }
  }
}

let idAndChecksum = try! NSRegularExpression(
  pattern: #"(0|(?:[1-9]\d*))\.(0|(?:[1-9]\d*))\.(0|(?:[1-9]\d*))(?:-([a-z]{5}))?$"#,
  options: []
)

extension EntityId: Equatable {
  public static func == (lhs: EntityId, rhs: EntityId) -> Bool {
    lhs.shard == rhs.shard && lhs.realm == rhs.realm && lhs.num == rhs.num
  }
}

extension EntityId: Hashable {}

extension EntityId: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    "\(shard).\(realm).\(num)"
  }

  public var debugDescription: String {
    description
  }
}

extension EntityId: LosslessStringConvertible {
  // Create an EntityId from a String. It's valid to have just the number, e.g. "1000",
  // in which case the shard and realm will default to 0.
  public init?(_ description: String) {
    let stat = EntityId.checksumParseAddress("", description)
    self = EntityId(
      shard: stat.num1, realm: stat.num2, num: stat.num3, checksum: stat.givenChecksum)
  }
}
