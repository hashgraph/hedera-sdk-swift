import GRPC

public protocol MethodDescriptor {
  associatedtype ProtoRequest
  associatedtype ProtoResponse

  static func getMethodDescriptor(_ node: Node) -> (ProtoRequest, CallOptions?) -> UnaryCall<
    ProtoRequest, ProtoResponse
  >
}
