class Node {
    var accountId: AccountId
    var address: NodeAddress

    init(_ address: String, _ accountId: AccountId) {
        self.accountId = accountId
        self.address = NodeAddress(address)
    }
}
