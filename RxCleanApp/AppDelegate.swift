import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let countViewFactory: ViewFactory = CountViewFactory()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let countView = countViewFactory.createView()
        window?.rootViewController = UINavigationController(rootViewController: countView)
        window?.makeKeyAndVisible()
        
        return true
    }
}

