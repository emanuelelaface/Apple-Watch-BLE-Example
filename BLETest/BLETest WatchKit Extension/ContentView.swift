//
//  ContentView.swift
//  BLETest WatchKit Extension
//
//  Created by Emanuele Laface on 2021-06-11.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()

    var body: some View {
        if bleManager.isSwitchedOn {
            VStack{
                Text(bleManager.status).onAppear(){bleManager.startScanning()}
                .foregroundColor(.green)
            }
        }
        else {
            Text("Bluetooth is NOT swidtched on")
                .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
