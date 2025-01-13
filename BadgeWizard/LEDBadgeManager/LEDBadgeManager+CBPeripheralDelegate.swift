//
//  LEDBadgeManager+Delegate.swift
//  BadgeLedApp
//
//  Created by Gustav on 07.01.25.
//

import CoreBluetooth

extension LEDBadgeManager: @preconcurrency CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == serviceUUID {
                print("Found FEE0 service")
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                print("Found FEE1 characteristic")
                self.characteristic = characteristic
                
                // Now that we're fully connected, send the pending messages
                if let messages = pendingMessages {
                    Task { @MainActor in
                        await createPayload(messages: messages)
                        pendingMessages = nil
                    }
                }
            }
        }
    }
}
