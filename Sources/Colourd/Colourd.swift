import Cocoa

@main
enum Colourd {
  private static var isRunning: Bool {
    let runningApplications = NSWorkspace.shared.runningApplications.map(\.localizedName)
    return runningApplications.contains("colourd")
  }

  static func main() {
    if isRunning {
      return
    }

    Daemon.run()
  }
}
