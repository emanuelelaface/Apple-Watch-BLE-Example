//
//  BLEClass.swift
//  BLETest WatchKit Extension
//
//  Created by Emanuele Laface on 2021-06-11.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var myCentral: CBCentralManager!

    @Published var isSwitchedOn = false
    @Published var status = ""
    var sensorValue: UInt8 = 0
    
    private var peripheral: CBPeripheral!

    override init() {
        super.init()

        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }

        if peripheralName == "ArduinoSensor" {
            self.stopScanning()
            self.myCentral.connect(peripheral, options: nil)
            self.peripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral: CBPeripheral, error: Error?) {
        self.startScanning()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(string: "1101") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charac = service.characteristics {
            for characteristic in charac {
                if characteristic.uuid == CBUUID(string: "2101") {
                    self.peripheral.readValue(for: characteristic)
                    if let data = characteristic.value {
                        self.sensorValue = data[0]
                        self.status = "Value: "+String(self.sensorValue)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: "2101") {
            self.peripheral.readValue(for: characteristic)
            if let data = characteristic.value {
                self.sensorValue = data[0]
                self.status = "Value: "+String(self.sensorValue)
            }
        }
    }
    
    func startScanning() {
        self.status = "Scanning BLE devices"
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
    func stopScanning() {
        myCentral.stopScan()
    }

}
