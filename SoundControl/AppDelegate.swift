//
//  AppDelegate.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 12/01/25.
//


import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
    }
}
