import Foundation
import CoreBluetooth

class LEDBadgeManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var badge: CBPeripheral?
    private var characteristic: CBCharacteristic?
    private let serviceUUID = CBUUID(string: "FEE0")
    private let characteristicUUID = CBUUID(string: "FEE1")
    
    // Published properties for UI updates
    @Published var isScanning = false
    @Published var isConnected = false
    
    // Constants matching TypeScript implementation
    private let HEADER = "77616E670000"
    private let PADDING1 = "000000000000"
    private let PADDING2 = "00000000"
    private let SEPARATOR = "00000000000000000000000000000000"
    
    // Character bitmaps from constants.ts
    private let LETTERS_HEX_BITMAPS: [String: String] = [
            "0": "007CC6CEDEF6E6C6C67C00",
            "1": "0018387818181818187E00",
            "2": "007CC6060C183060C6FE00",
            "3": "007CC606063C0606C67C00",
            "4": "000C1C3C6CCCFE0C0C1E00",
            "5": "00FEC0C0FC060606C67C00",
            "6": "007CC6C0C0FCC6C6C67C00",
            "7": "00FEC6060C183030303000",
            "8": "007CC6C6C67CC6C6C67C00",
            "9": "007CC6C6C67E0606C67C00",
            "#": "006C6CFE6C6CFE6C6C0000",
            "&": "00386C6C3876DCCCCC7600",
            "_": "00000000000000000000FF",
            "-": "0000000000FE0000000000",
            "?": "007CC6C60C181800181800",
            "@": "00003C429DA5ADB6403C00",
            "(": "000C183030303030180C00",
            ")": "0030180C0C0C0C0C183000",
            "=": "0000007E00007E00000000",
            "+": "00000018187E1818000000",
            "!": "00183C3C3C181800181800",
            "'": "1818081000000000000000",
            ":": "0000001818000018180000",
            "%": "006092966C106CD2920C00",
            "/": "000002060C183060C08000",
            "\"": "6666222200000000000000",
            " ": "0000000000000000000000",
            "*": "000000663CFF3C66000000",
            ",": "0000000000000030301020",
            ".": "0000000000000000303000",
            "$": "107CD6D6701CD6D67C1010",
            "~": "0076DC0000000000000000",
            "[": "003C303030303030303C00",
            "]": "003C0C0C0C0C0C0C0C3C00",
            "{": "000E181818701818180E00",
            "}": "00701818180E1818187000",
            "<": "00060C18306030180C0600",
            ">": "006030180C060C18306000",
            "^": "386CC60000000000000000",
            "`": "1818100800000000000000",
            ";": "0000001818000018180810",
            "\\": "0080C06030180C06020000",
            "|": "0018181818001818181800",
            "a": "00000000780C7CCCCC7600",
            "b": "00E060607C666666667C00",
            "c": "000000007CC6C0C0C67C00",
            "d": "001C0C0C7CCCCCCCCC7600",
            "e": "000000007CC6FEC0C67C00",
            "f": "001C363078303030307800",
            "g": "00000076CCCCCC7C0CCC78",
            "h": "00E060606C76666666E600",
            "i": "0018180038181818183C00",
            "j": "0C0C001C0C0C0C0CCCCC78",
            "k": "00E06060666C78786CE600",
            "l": "0038181818181818183C00",
            "m": "00000000ECFED6D6D6C600",
            "n": "00000000DC666666666600",
            "o": "000000007CC6C6C6C67C00",
            "p": "000000DC6666667C6060F0",
            "q": "0000007CCCCCCC7C0C0C1E",
            "r": "00000000DE76606060F000",
            "s": "000000007CC6701CC67C00",
            "t": "00103030FC303030341800",
            "u": "00000000CCCCCCCCCC7600",
            "v": "00000000C6C6C66C381000",
            "w": "00000000C6D6D6D6FE6C00",
            "x": "00000000C66C38386CC600",
            "y": "000000C6C6C6C67E060CF8",
            "z": "00000000FE8C183062FE00",
            "A": "00386CC6C6FEC6C6C6C600",
            "B": "00FC6666667C666666FC00",
            "C": "007CC6C6C0C0C0C6C67C00",
            "D": "00FC66666666666666FC00",
            "E": "00FE66626878686266FE00",
            "F": "00FE66626878686060F000",
            "G": "007CC6C6C0C0CEC6C67E00",
            "H": "00C6C6C6C6FEC6C6C6C600",
            "I": "003C181818181818183C00",
            "J": "001E0C0C0C0C0CCCCC7800",
            "K": "00E6666C6C786C6C66E600",
            "L": "00F060606060606266FE00",
            "M": "0082C6EEFED6C6C6C6C600",
            "N": "0086C6E6F6DECEC6C6C600",
            "O": "007CC6C6C6C6C6C6C67C00",
            "P": "00FC6666667C606060F000",
            "Q": "007CC6C6C6C6C6D6DE7C06",
            "R": "00FC6666667C6C6666E600",
            "S": "007CC6C660380CC6C67C00",
            "T": "007E7E5A18181818183C00",
            "U": "00C6C6C6C6C6C6C6C67C00",
            "V": "00C6C6C6C6C6C66C381000",
            "W": "00C6C6C6C6D6FEEEC68200",
            "X": "00C6C66C7C387C6CC6C600",
            "Y": "00666666663C1818183C00",
            "Z": "00FEC6860C183062C6FE00",
            "¶": "003E7A7A7A3A1A0A0A0A00",
            "£": "001C222220782020207E00",
            "∆": "001010282844444482FE00",
            "°": "0038283800000000000000",
            "€": "000E10207E207E20100E00",
            "¢": "00081C20404040201C0800",
            "¥": "0082444428103810381000",
            "π": "000000007E242424640000",
            "₹": "007C087C08702010080400",
            "•": "0000000000001818000000",
            "×": "0000006C7C387C6C000000",
            "÷": "00000010007C0010000000",
            "√": "0004040C08482828181000",
            "₱": "003CFF22FF3C2020202000"
        
    ]
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func sendBitmaps(bitmaps: [String], speed: Int = 1, flash: Bool = false, marquee: Bool = false, mode: Int) {
        guard let peripheral = badge, let characteristic = characteristic else {
            print("Badge not connected")
            return
        }
        
        // Build packet components
        let flashValue = getFlashValue(flash)
        let marqueeValue = getMarqueeValue(marquee)
        let modes = getModeString(speed, mode: mode)
        let size = getSize(bitmaps)
        let timestamp = getTimestamp()
        let payload = bitmaps.joined()
        
        // Construct full hex string
        let hexString = HEADER + flashValue + marqueeValue + modes + size + PADDING1 + timestamp + PADDING2 + SEPARATOR + payload
        print("Full hex string: \(hexString)")
        
        // Split into chunks and send
        let chunks = splitHexStringIntoChunks(hexString)
        for chunk in chunks {
            let bytes = hexStringToByteArray(chunk)
            let data = Data(bytes)
            let base64String = data.base64EncodedString()
            print(chunk)
            
            
            if let base64Data = Data(base64Encoded: base64String) {
                peripheral.writeValue(base64Data, for: characteristic, type: .withResponse)
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
    
    func sendText(_ text: String, speed: Int = 1, flash: Bool = false, marquee: Bool = false) {
        guard let peripheral = badge, let characteristic = characteristic else {
            print("Badge not connected")
            return
        }
        
        // Get bitmaps for the text
        let bitmaps = getLetterBitmaps(text)
     
        self.sendBitmaps(bitmaps: bitmaps, speed: speed, flash: flash, marquee: marquee, mode: 0)
    }
    
    private func getLetterBitmaps(_ text: String) -> [String] {
        return text.map { String($0) }.compactMap { LETTERS_HEX_BITMAPS[$0] }
    }
    
    private func getFlashValue(_ isFlash: Bool) -> String {
        return isFlash ? "01" : "00"
    }
    
    private func getMarqueeValue(_ isMarquee: Bool) -> String {
        return isMarquee ? "01" : "00"
    }
    
    private func getModeString(_ speed: Int, mode: Int) -> String {
        return "\(speed)\(mode)" + "00" + "00" + "00" + "00" + "00" + "00" + "00"
    }
    
    private func getSize(_ letters: String) -> String {
        // Get the length and convert to hex string padded to 4 chars
        let size = letters.count
        let firstBitmapSize = String(format: "%04x", size)
        
        // Constants from TypeScript
        // let MAX_BITMAPS_NUMBER = 8
        
        // Add padding for remaining bitmaps (7 times "0000")
        return firstBitmapSize + "0000" + "0000" + "0000" + "0000" + "0000" + "0000" + "0000"
    }
    
    private func getSize(_ chunks: [String]) -> String {
        let size = chunks.count
        let firstBitmapSize = String(format: "%04x", size)
        
        return firstBitmapSize + "0000" + "0000" + "0000" + "0000" + "0000" + "0000" + "0000"
    }
    
    private func getTimestamp() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        return String(format: "%02X%02X%02X%02X%02X%02X",
                      components.year! & 0xFF,
                      components.month!,
                      components.day!,
                      components.hour!,
                      components.minute!,
                      components.second!)
    }
    
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
    
    // Bluetooth scanning and connection methods
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.stopScanning()
        }
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on")
        } else {
            print("Bluetooth is not available: \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name == "LSLED" else { return }
        
        print("Found LED Badge: \(peripheral)")
        stopScanning()
        
        self.badge = peripheral
        self.badge?.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("Connected to LED Badge")
        peripheral.discoverServices([serviceUUID])
    }
    
    // MARK: - CBPeripheralDelegate
    
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
            }
        }
    }
}
