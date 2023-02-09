import Cocoa

enum Daemon {
  private static var configurationDirectory: URL {
    var configurationDirectory = FileManager.default.homeDirectoryForCurrentUser
    configurationDirectory.append(component: ".config")
    configurationDirectory.append(component: "colourd")
    return configurationDirectory
  }

  private static var style: String {
    let currentAppearance = NSAppearance.currentDrawing()
    let mode = currentAppearance.bestMatch(from: [.aqua, .darkAqua])
    return mode == .aqua ? "light" : "dark"
  }

  /// Adds an entry to the default notification center to receive a
  /// notification when the theme changes and execute the provided
  /// block.
  ///
  /// - Parameter block: The block that executes after receiving a
  ///   notification.
  private static func addObserver(execute block: @escaping @Sendable (Notification) -> Void) {
    let notificationCenter = DistributedNotificationCenter.default
    let themeChangedNofitication = Notification.Name("AppleInterfaceThemeChangedNotification")
    notificationCenter.addObserver(forName: themeChangedNofitication, object: nil, queue: nil, using: block)
  }

  private static func execute(_ program: String) {
    do {
      let url = configurationDirectory.appending(path: program)
      try Process.run(url, arguments: [style]).waitUntilExit()
    } catch {
      print("\(error.localizedDescription)\nTry enabling executable permissions.", to: &StandardError.shared)
    }
  }

  private static func getPrograms() -> [String]? {
    do {
      let path = configurationDirectory.path(percentEncoded: false)
      return try FileManager.default.contentsOfDirectory(atPath: path)
    } catch {
      print("\(error.localizedDescription)", to: &StandardError.shared)
      return nil
    }
  }

  private static func register() {
    let onStyleChange: @Sendable (Notification) -> Void = { _ in
      if let programs = getPrograms() {
        for program in programs {
          execute(program)
        }
      }
    }
    addObserver(execute: onStyleChange)
  }

  static func run() {
    register()
    NSApplication.shared.run()
  }
}
