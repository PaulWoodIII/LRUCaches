import XCTest
@testable import LRUCaches

struct Food {
  let name: String
  let cost: Int
}

extension InMemoryLRUCache where K == String, V == String, C == Int {
  func addFood(_ food: Food) -> Result<Void, InMemoryLRUCache.Error> {
    return self.add(key: food.name, value: food.name, cost: food.cost)
  }
}

// Setup some test

var apple = Food(name:"Apple", cost: 20)
var banana = Food(name:"Banana", cost: 30)
var peach = Food(name:"Peach", cost: 40)
var bread = Food(name:"Bread", cost: 40)
var chips = Food(name:"Chips", cost: 110)

final class LRUCachesTests: XCTestCase {
  
  func testInMemoryCache() {
    
    let foodCache = InMemoryLRUCache<String, String, Int>(capacity: 100)
    var r = foodCache.addFood(apple)
    XCTAssertNoThrow(try r.get())
    r = foodCache.addFood(apple)
    XCTAssertNoThrow(try r.get())
    r = foodCache.addFood(banana)
    XCTAssertNoThrow(try r.get())
    r = foodCache.addFood(peach)
    XCTAssertNoThrow(try r.get())
    
    // make apple recently accessed
    _ = foodCache[apple.name]
    
    // this add will trigger the cache to remove the lest recently used object banana
    r = foodCache.addFood(bread)
    XCTAssertNoThrow(try r.get())
    
    // apple was accessed most recently and is small so it should still exist
    XCTAssertNotNil(foodCache[apple.name])
    
    // banana was last accessed it should be dropped first
    XCTAssertNil(foodCache[banana.name])
    
    r = foodCache.addFood(chips)
    XCTAssertThrowsError(try r.get())
    
    let chipsBreak = InMemoryLRUCache<String, String, Int>(capacity: 1)
    r = chipsBreak.addFood(chips)
    XCTAssertThrowsError(try r.get())
  }
  
  static var allTests = [
    ("testExample", testExample),
  ]
}
