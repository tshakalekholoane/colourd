import Cocoa

class StandardError: TextOutputStream {
  static var shared = StandardError()

  func write(_ string: String) {
    try! FileHandle.standardError.write(contentsOf: Data(string.utf8))
  }
}
