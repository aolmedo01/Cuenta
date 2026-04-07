import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        verifyManropeFonts()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private func verifyManropeFonts() {
        let expectedFonts = [
            "Manrope-Regular",
            "Manrope-Medium",
            "Manrope-SemiBold",
            "Manrope-Bold",
            "Manrope-Light"
        ]

        print("=== Font Check: Manrope ===")
        for fontName in expectedFonts {
            let isAvailable = UIFont(name: fontName, size: 14) != nil
            print("[\(isAvailable ? "OK" : "FAIL")] \(fontName)")
        }

        let installedManropeFonts = UIFont.familyNames
            .sorted()
            .flatMap { family in UIFont.fontNames(forFamilyName: family) }
            .filter { $0.localizedCaseInsensitiveContains("manrope") }
            .sorted()

        print("Installed Manrope font names: \(installedManropeFonts)")
        print("===========================")
    }
}
