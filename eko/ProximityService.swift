import Foundation
import CoreLocation
import CoreBluetooth

class ProximityService : NSObject, CBPeripheralManagerDelegate {
    let uuid : NSUUID = NSUUID(UUIDString: "B072B015-8E55-4AFD-B8EE-2DDFF1B16038")
    let identifier : NSString = "com.ekbergedelstam.myRegion"

    var peripheralManager : CBPeripheralManager!

    func startAdvertising() {
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if (peripheral.state == CBPeripheralManagerState.PoweredOn) {
            let beaconRegion = CLBeaconRegion(
                proximityUUID: self.uuid,
                major: 1,
                minor: 1,
                identifier: self.identifier
            )
            
            let beaconPeripheralData = beaconRegion.peripheralDataWithMeasuredPower(nil)
            
            self.peripheralManager.startAdvertising(beaconPeripheralData)
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        NSLog("peripheralManagerDidStartAdvertising()")
    }
}