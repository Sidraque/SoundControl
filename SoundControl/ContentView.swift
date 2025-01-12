//
//  ContentView.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//


// ContentView.swift
// SoundControl
//
// Created by Sidraque Agostinho on 11/01/25.

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Bem-vindo ao SoundControl!")
                .font(.title)
                .padding()

            Button(action: {
                print("Botão clicado!")
            }) {
                Text("Abrir Configurações")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
