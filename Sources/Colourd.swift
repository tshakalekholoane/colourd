import Cocoa
import os

@main
enum Colourd {
  private static let name = "colourd"
  private static let log = Logger(subsystem: "dev.tshaka.colourd", category: "default")

  private static var currentAppearance: String {
    let appearance = NSAppearance.currentDrawing()
    return appearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua ? "light" : "dark"
  }

  /// Stores URLs to programs in the configuration directory
  /// `~/Library/Application Support/` that are executed by the daemon
  /// when the appearance changes.
  private static var programs: [URL] {
    do {
      var url = try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      url.append(component: Bundle.main.bundleIdentifier ?? name)
      return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    } catch {
      log.error("\(error.localizedDescription)")
      return []
    }
  }

  private static var signalSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)

  private static var isRunning: Bool {
    // Seems more robust than using lock files.
    let runningApplications = Set(NSWorkspace.shared.runningApplications.map(\.localizedName))
    return runningApplications.contains(name)
  }

  /// Registers a `SIGTERM` handler using a `dispatch(3)` source. See
  /// `launchd.plist(5)`.
  private static func registerSignalHandlerWithDispatchSource() {
    signal(SIGTERM, SIG_IGN)
    signalSource.setEventHandler(handler: {
      log.info("Shutting down")
      _exit(EXIT_SUCCESS) // See sigaction(2).
    })
    signalSource.resume()
    log.info("Registered SIGTERM handler")
  }

  private static func registerNotification() {
    let notificationCenter = DistributedNotificationCenter.default
    let themeChangedNofitication = Notification.Name("AppleInterfaceThemeChangedNotification")
    notificationCenter.addObserver(
      forName: themeChangedNofitication,
      object: nil,
      queue: nil,
      using: { _ in
        log.info("Theme changed")
        for program in programs {
          do {
            try Process
              .run(program, arguments: [currentAppearance])
              .waitUntilExit()
          } catch {
            log.error("\(error.localizedDescription)")
          }
        }
      }
    )
    log.info("Registered notification")
  }

  static func main() {
    if isRunning {
      return
    }
    registerSignalHandlerWithDispatchSource()
    registerNotification()
    log.info("Starting colourd")
    NSApplication.shared.run()
  }
}
