import Foundation
import CoreBluetooth

/// Manages communication with an LED badge device over Bluetooth
/// Handles device discovery, connection, and data transmission
@MainActor
class LEDBadgeManager: NSObject, ObservableObject {
    // MARK: - Properties
    
    /// The current state of the badge connection and data transfer process
    @Published var connectionState: BadgeConnectionState = .ready
    
    /// Core Bluetooth manager for handling Bluetooth operations
    internal var centralManager: CBCentralManager!
    /// Currently connected badge peripheral
    internal var badge: CBPeripheral?
    /// Characteristic used for writing data to the badge
    internal var characteristic: CBCharacteristic?
    /// Messages waiting to be sent
    internal var pendingMessages: [Message]?
    
    // MARK: - Constants
    
    /// UUID for the LED badge service
    internal let serviceUUID = CBUUID(string: "FEE0")
    /// UUID for the write characteristic
    internal let characteristicUUID = CBUUID(string: "FEE1")
    
    /// Protocol constants for packet construction
    internal let HEADER = "77616E670000"
    internal let PADDING1 = "000000000000"
    internal let PADDING2 = "00000000"
    internal let SEPARATOR = "00000000000000000000000000000000"
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    /// Initiates the connection and sending process
    /// - Parameter messages: Array of Message objects to send to the badge
    @MainActor
    func connectAndSend(messages: [Message]) {
        guard centralManager.state == .poweredOn else {
            connectionState = .error("Bluetooth is not available")
            return
        }
        
        pendingMessages = messages
        connectionState = .searching
        startScanning()
    }
    
    // MARK: - Private Methods
    
    /// Creates and sends a payload to the connected LED badge
    /// - Parameter messages: Array of Message objects containing display information
    @MainActor
    internal func createPayload(messages: [Message]) async {
        guard let peripheral = badge, let characteristic = characteristic else {
            connectionState = .error("Badge not connected")
            return
        }
        
        let hexString = buildHexString(from: messages)
        await sendBitmaps(hexString, peripheral: peripheral, characteristic: characteristic)
    }
    
    /// Starts scanning for LED badge devices
    private func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// Stops scanning for LED badge devices
    public func stopScanning() {
        centralManager.stopScan()
    }
    
    /// Builds the complete hex string payload from the provided messages
    private func buildHexString(from messages: [Message]) -> String {
        let payload = messages.map { $0.getBitmap() }
        
        
        return HEADER +
        getFlashByte(messages) +
        getMarqueeByte(messages) +
        getModesString(messages) +
        getSizesString(payload) +
        PADDING1 +
        getTimestamp() +
        PADDING2 +
        SEPARATOR +
        getMessagePayload(payload)
    }
    
    /// Generates a byte representing flash settings for all messages
    /// Each bit represents whether the corresponding message should flash
    private func getFlashByte(_ messages: [Message]) -> String {
        var flashByte: UInt8 = 0
        for (index, message) in messages.enumerated() where message.flash {
            flashByte |= (1 << index)
        }
        return String(format: "%02X", flashByte)
    }
    
    /// Generates a byte representing marquee settings for all messages
    /// Each bit represents whether the corresponding message uses marquee
    private func getMarqueeByte(_ messages: [Message]) -> String {
        var marqueeByte: UInt8 = 0
        for (index, message) in messages.enumerated() where message.marquee {
            marqueeByte |= (1 << index)
        }
        return String(format: "%02X", marqueeByte)
    }
    
    /// Combines speed and mode settings for all messages into a hex string
    /// Each message uses one byte: upper nibble for speed, lower nibble for mode
    private func getModesString(_ messages: [Message]) -> String {
        let modesString = messages.map { message -> String in
            let speedValue = message.speed.rawValue << 4
            let modeValue = message.mode.rawValue
            let combined = speedValue | modeValue
            return String(format: "%02X", combined)
        }.joined()
        
        return modesString + String(repeating: "00", count: 8 - messages.count)
    }
    
    /// Generates size information for all messages
    /// Each message size uses two bytes in big-endian format
    private func getSizesString(_ messagesPayloads: [[String]]) -> String {
        let sizesString = messagesPayloads.map { message in
            let length = message.count
            let highByte = (length >> 8) & 0xFF
            let lowByte = length & 0xFF
            return String(format: "%02X%02X", highByte, lowByte)
        }.joined()
        
        let remainingBytes = 32 - (messagesPayloads.count * 4)
        return sizesString + String(repeating: "0", count: remainingBytes)
    }
    
    /// Combines all message bitmaps into a single string
    private func getMessagePayload(_ messagesPayload: [[String]]) -> String {
        messagesPayload.map { $0.joined() }.joined()
    }
    
    /// Generates timestamp bytes for the current time
    private func getTimestamp() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        return String(format: "%02X%02X%02X%02X%02X%02X",
                      components.year! & 0xFF,
                      components.month!,
                      components.day!,
                      components.hour!,
                      components.minute!,
                      components.second!)
    }
    
    // MARK: - Data Transmission Methods
    
    /// Sends bitmap data to the LED badge in chunks
    @MainActor
    private func sendBitmaps(_ hexString: String, peripheral: CBPeripheral, characteristic: CBCharacteristic) async {
        connectionState = .sending
        let chunks = splitHexStringIntoChunks(hexString)
        
        print("Sending bitmaps to LED badge …")
        
        do {
            for chunk in chunks {
                let bytes = hexStringToByteArray(chunk)
                let data = Data(bytes)
                let base64String = data.base64EncodedString()
                print(chunk)
                
                if let base64Data = Data(base64Encoded: base64String) {
                    try await withCheckedThrowingContinuation { continuation in
                        peripheral.writeValue(base64Data, for: characteristic, type: .withResponse)
                        continuation.resume()
                    }
                    // try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                }
            }
            connectionState = .ready
        } catch {
            connectionState = .error("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    /// Splits a hex string into chunks of 32 characters
    private func splitHexStringIntoChunks(_ hexString: String) -> [String] {
        var result: [String] = []
        let chunkSize = 32
        var index = 0
        
        while index < hexString.count {
            let endIndex = min(index + chunkSize, hexString.count)
            let chunk = String(hexString[hexString.index(hexString.startIndex, offsetBy: index)..<hexString.index(hexString.startIndex, offsetBy: endIndex)])
            result.append(chunk.padding(toLength: 32, withPad: "0", startingAt: 0))
            index += chunkSize
        }
        
        return result
    }
    
    /// Converts a hex string to an array of bytes
    private func hexStringToByteArray(_ hexString: String) -> [UInt8] {
        var data = [UInt8]()
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            let byteString = String(hexString[index..<nextIndex])
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            }
            index = nextIndex
        }
        
        return data
    }
}




