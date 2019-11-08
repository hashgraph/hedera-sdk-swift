enum TransactionKind {
    case contractCall
    case contractCreate
    case contractUpdate
    case contractDelete
    case accountAddClaim
    case accountCreate
    case accountDelete
    case accountDeleteClaim
    case cryptoTransfer
    case accountUpdate
    case fileAppend
    case fileCreate
    case fileDelete
    case fileUpdate
    case systemUndelete
    case systemDelete
    // TODO: Freeze service
    // case freeze

    init(_ body: Proto_TransactionBody.OneOf_Data) {
        switch body {
        case .contractCall:
            self = .contractCall
        case .contractCreateInstance:
            self = .contractCreate
        case .contractUpdateInstance:
            self = .contractUpdate
        case .contractDeleteInstance:
            self = .contractDelete
        case .cryptoAddClaim:
            self = .accountAddClaim
        case .cryptoCreateAccount:
            self = .accountCreate
        case .cryptoDelete:
            self = .accountDelete
        case .cryptoDeleteClaim:
            self = .accountDeleteClaim
        case .cryptoTransfer:
            self = .cryptoTransfer
        case .cryptoUpdateAccount:
            self = .accountUpdate
        case .fileAppend:
            self = .fileAppend
        case .fileCreate:
            self = .fileCreate
        case .fileDelete:
            self = .fileDelete
        case .fileUpdate:
            self = .fileUpdate
        case .systemDelete:
            self = .systemDelete
        case .systemUndelete:
            self = .systemUndelete
        case .freeze:
            fatalError("TODO: freeze service")
        }
    }
}
