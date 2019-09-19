//
//  File.swift
//  
//
//  Created by Paul Wood on 9/19/19.
//

import Foundation

public class InMemoryLRUCache<K: Hashable, V, C: Comparable & ExpressibleByIntegerLiteral & AdditiveArithmetic> {
  
  // MARK: STATE
  
  private class Node<K,C> {
    let key: K
    let cost: C
    var prev: Node?
    var next: Node?
    
    init(key: K, cost: C) {
      self.key = key
      self.cost = cost
    }
  }
  
  private struct StorePairing<K,V> {
    let key: K
    let value: V
    let node: Node<K,C>
  }
  
  private let maxCapacity: C
  private var currentCapacity: C = 0
  private var head: Node<K,C>?
  private var tail: Node<K,C>?
  private var store: [K: StorePairing<K,V>] = [:]
  
  // MARK: PRIVATE METHODS
  
  private func createNewHead(_ cost: C, _ key: K, _ value: V) -> Result<Void, InMemoryLRUCache.Error> {
    let newHead = Node(key: key, cost: cost)
    let newPair = StorePairing(key: key, value: value, node: newHead)
    if let currentHead = self.head {
      currentHead.prev = newHead
      newHead.next = currentHead
    }
    self.head = newHead
    if self.tail == nil { // Empty Cache State
      self.tail = newHead
    }
    store[key] = newPair
    currentCapacity += cost
    return .success(())
  }
  
  private func moveNodeToFront(_ pair: StorePairing<K,V>) {
    // We found it cost does not change
    if tail !== head { // Only if there is more than one item in the list do we do this logic
      let newHead = pair.node
      if newHead === tail {
        tail = newHead.prev
      }
      newHead.prev?.next = newHead.next
      newHead.next?.prev = newHead.prev
      newHead.prev = nil
      newHead.next = self.head
      head = newHead
    }
  }
  
  private func resizeForCost(_ cost: C) {
    while (self.currentCapacity + cost > maxCapacity){
      if self.tail === self.head {
        self.currentCapacity = 0
        self.head = nil
        self.tail = nil
        return
      }
      
      let toRemove = self.tail!
      store[toRemove.key] = nil
      self.currentCapacity -= toRemove.cost
      self.tail = toRemove.prev
      toRemove.prev?.next = nil
      toRemove.prev = nil //toRemove should now have no references
    }
  }
  
  // MARK: PUBLIC METHODS
  
  public init(capacity: C){
    self.maxCapacity = capacity
  }
  
  public enum Error: Swift.Error {
    case exceedsCapacity
  }
  
  func add(key: K, value: V, cost: C) -> Result<Void, Error> {
    if cost > maxCapacity {
      return .failure(.exceedsCapacity)
    }
    
    if head == nil {
      return createNewHead(cost, key, value)
    }
    
    if let pair = store[key] {
      moveNodeToFront(pair)
      return .success(())
    }
    
    if self.currentCapacity + cost > maxCapacity {
      resizeForCost(cost)
    }
    return createNewHead(cost, key, value)
  }
  
  subscript(key: K) -> V? /*Return Value*/ {
    if let pair = store[key] {
      moveNodeToFront(pair)
      return pair.value
    }
    return nil
  }
}
