//
//  LEDBadgeManager+CBManagerDelegate.swift
//  BadgeLedApp
//
//  Created by Gustav on 07.01.25.
//

import CoreBluetooth
// MARK: - CBCentralManagerDelegate

extension LEDBadgeManager: @preconcurrency CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            if central.state == .poweredOn {
                print("Bluetooth is powered on")
            } else {
                print("Bluetooth is not available: \(central.state)")
                connectionState = .error("Bluetooth is not available")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name == "LSLED" else { return }
        
        print("Found LED Badge: \(peripheral)")
        stopScanning()
        
        Task { @MainActor in
            connectionState = .connecting
            self.badge = peripheral
            self.badge?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to LED Badge")
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            connectionState = .error("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            if connectionState != .ready {
                connectionState = .error("Disconnected: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
