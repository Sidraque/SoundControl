//
//  MenuBarView.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var menuBarController: MenuBarController

    var body: some View {
        VStack {
            Text("Menu")
                .font(.headline)
                .padding()

            ForEach(menuBarController.runningApps, id: \.appName) { app in
                HStack {
                    Text(app.appName)
                    Slider(value: Binding(
                        get: { app.volume },
                        set: { newVolume in
                            menuBarController.adjustVolume(for: app.appName, to: newVolume)
                        }
                    ), in: 0...1)
                    .frame(width: 150)

                    Button(action: {
                        menuBarController.toggleMute(for: app.appName)
                    }) {
                        Text(app.isMuted ? "Restaurar Volume" : "Silenciar")
                    }
                    .padding(5)
                }
                .padding(.bottom, 5)
            }

            Divider()

            Button("Configurações") {
                print("Abrindo configurações...")
            }

            Button("Sair") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}
