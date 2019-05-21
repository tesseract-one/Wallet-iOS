//
//  AppDelegate.swift
//  Tesseract
//
//  Created by Yehor Popovych on 11/8/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

protocol ViewControllerContainer: class {
    var view: UIViewController? { get }
    var windowView: UIView? { get }
    
    func setView(vc: UIViewController, animated: Bool)
    
    func showModalView(vc: UIViewController, animated: Bool)
    func hideModalView(animated: Bool)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ViewControllerContainer {
    
    let window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let context = ApplicationContext()
    
    var view: UIViewController? {
        return window?.rootViewController
    }
    
    var windowView: UIView? {
        return window
    }
    
    func setView(vc: UIViewController, animated: Bool) {
        window?.replaceRootViewControllerWith(vc, animated: animated) { [weak self] in
            if self?.window != nil && !self!.window!.isKeyWindow {
                self!.window!.makeKeyAndVisible()
            }
        }
    }
    
    func showModalView(vc: UIViewController, animated: Bool) {
        view!.present(vc, animated: animated, completion: nil)
    }
    
    func hideModalView(animated: Bool) {
        view!.dismiss(animated: animated, completion: nil)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        context.rootContainer = self
        
        context.registrationViewFactory = RegistrationViewFactory(resolver: UIStoryboard(name: "Registration", bundle: nil), context: context)
        context.walletViewFactory = WeakContextViewFactory(resolver: UIStoryboard(name: "Main", bundle: nil), context: context)
        context.urlHandlerViewFactory = WeakContextViewFactory(resolver: UIStoryboard(name: "URLHandler", bundle: nil), context: context)

        context.bootstrap()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return context.applicationService.handle(url: url)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

