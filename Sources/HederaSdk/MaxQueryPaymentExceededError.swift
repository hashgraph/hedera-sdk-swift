import Foundation

public final class MaxQueryPaymentExceededError<O>: Error {
  public let query: Query<O>
  public let cost: Hbar
  public let maxCost: Hbar

  init(query: Query<O>, cost: Hbar, maxCost: Hbar) {
    self.query = query
    self.cost = cost
    self.maxCost = maxCost
  }
}
