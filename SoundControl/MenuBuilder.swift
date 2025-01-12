//
//  MenuBuilder.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 12/01/25.
//
import Cocoa
import SwiftUI

class MenuBuilder {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu?
    private weak var controller: MenuBarController?
    private var isMenuInitialized = false

    init() {
    }

    func attach(controller: MenuBarController) {
        self.controller = controller
    }

    func setupMenuBar() {
        DispatchQueue.main.async {
            if self.menu == nil {
                self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                if let button = self.statusItem.button {
                    button.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "SoundControl")
                }

                self.menu = NSMenu()
                self.statusItem.menu = self.menu
                self.isMenuInitialized = true

                self.refreshMenu()
            }
        }
    }

    func refreshMenu() {
        guard let menu = self.menu else {
            if !isMenuInitialized {
                print("Erro: Menu não foi inicializado.")
            }
            return
        }

        menu.removeAllItems()

        guard let apps = controller?.runningApps else { return }
        for app in apps {
            let appMenuItem = NSMenuItem(
                title: app.appName,
                action: nil,
                keyEquivalent: ""
            )
            appMenuItem.representedObject = app
            appMenuItem.target = self
            menu.addItem(appMenuItem)

            let volumeSliderItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
            let volumeSlider = NSSlider(value: Double(app.volume), minValue: 0, maxValue: 1, target: self, action: #selector(self.volumeSliderChanged(_:)))
            volumeSlider.isContinuous = true
            volumeSlider.tag = Int(app.pid)
            volumeSliderItem.view = volumeSlider
            menu.addItem(volumeSliderItem)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Atualizar", action: #selector(self.refreshMenuAction), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Sair", action: #selector(self.quitApp), keyEquivalent: "q"))
        menu.addItem(NSMenuItem(title: "Abrir Interface", action: #selector(self.openMenuBarView), keyEquivalent: "i"))
    }

    @objc func volumeSliderChanged(_ sender: NSSlider) {
        guard let app = controller?.runningApps.first(where: { Int($0.pid) == sender.tag }) else { return }
        let newVolume = Float(sender.doubleValue)
        controller?.adjustVolume(for: app.appName, to: newVolume)
    }

    @objc func handleAppMenuItem(_ sender: NSMenuItem) {
        guard let app = sender.representedObject as? RunningApp else { return }
        controller?.toggleMute(for: app.appName)
    }

    @objc func refreshMenuAction() {
        controller?.updateRunningApps()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func openMenuBarView() {
        guard let controller = controller else { return }
        let menuBarView = MenuBarView(menuBarController: controller)
        let hostingController = NSHostingController(rootView: menuBarView)
        let window = NSWindow(
            contentRect: NSMakeRect(0, 0, 400, 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.makeKeyAndOrderFront(nil)
    }
}
