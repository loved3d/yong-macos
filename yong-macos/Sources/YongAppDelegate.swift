//
//  YongAppDelegate.swift
//  yong-macos
//
//  Application delegate for Yong input method
//

import Cocoa
import InputMethodKit

@main
class YongAppDelegate: NSObject, NSApplicationDelegate {
    var server: IMKServer!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize IMK server with our input controller
        server = IMKServer(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, 
                          bundleIdentifier: Bundle.main.bundleIdentifier)
        
        NSLog("Yong Input Method started successfully")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSLog("Yong Input Method terminating")
    }
}
