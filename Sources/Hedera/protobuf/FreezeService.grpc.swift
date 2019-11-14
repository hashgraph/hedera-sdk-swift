//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: FreezeService.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import GRPC
import NIO
import NIOHTTP1
import SwiftProtobuf


/// Usage: instantiate Proto_FreezeServiceServiceClient, then call methods of this protocol to make API calls.
internal protocol Proto_FreezeServiceService {
  func freeze(_ request: Proto_Transaction, callOptions: CallOptions?) -> UnaryCall<Proto_Transaction, Proto_TransactionResponse>
}

internal final class Proto_FreezeServiceServiceClient: GRPCServiceClient, Proto_FreezeServiceService {
  internal let connection: ClientConnection
  internal var serviceName: String { return "proto.FreezeService" }
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the proto.FreezeService service.
  ///
  /// - Parameters:
  ///   - connection: `ClientConnection` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(connection: ClientConnection, defaultCallOptions: CallOptions = CallOptions()) {
    self.connection = connection
    self.defaultCallOptions = defaultCallOptions
  }

  /// Asynchronous unary call to freeze.
  ///
  /// - Parameters:
  ///   - request: Request to send to freeze.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func freeze(_ request: Proto_Transaction, callOptions: CallOptions? = nil) -> UnaryCall<Proto_Transaction, Proto_TransactionResponse> {
    return self.makeUnaryCall(path: self.path(forMethod: "freeze"),
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

}

/// To build a server, implement a class that conforms to this protocol.
internal protocol Proto_FreezeServiceProvider: CallHandlerProvider {
  func freeze(request: Proto_Transaction, context: StatusOnlyCallContext) -> EventLoopFuture<Proto_TransactionResponse>
}

extension Proto_FreezeServiceProvider {
  internal var serviceName: String { return "proto.FreezeService" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handleMethod(_ methodName: String, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "freeze":
      return UnaryCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.freeze(request: request, context: context)
        }
      }

    default: return nil
    }
  }
}

