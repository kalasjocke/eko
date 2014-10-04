import Foundation
import CoreLocation
import CoreBluetooth
import UIKit

class ProximityService : NSObject, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    let uuid : NSUUID = NSUUID(UUIDString: "B072B015-8E55-4AFD-B8EE-2DDFF1B16038")
    let identifier : NSString = "com.ekbergedelstam.myRegion"

    var peripheralManager : CBPeripheralManager!
    var beaconRegion : CLBeaconRegion!
    var beaconPeripheralData : NSDictionary!
    var locationManager : CLLocationManager!
    var delegate : ViewController;
    
    init(delegate: ViewController) {
        self.beaconRegion = CLBeaconRegion(
            proximityUUID: self.uuid,
            identifier: self.identifier
        )
        self.delegate = delegate
    }
    
    // Transmitting

    func startTransmitting() {
        NSLog("startTransmitting()")
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.beaconPeripheralData = self.beaconRegion.peripheralDataWithMeasuredPower(nil)
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if (peripheral.state == CBPeripheralManagerState.PoweredOn) {
            self.peripheralManager.startAdvertising(beaconPeripheralData)
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        NSLog("peripheralManagerDidStartAdvertising()")
    }
    
    // Receiving
    
    func startReceiving() {
        NSLog("startReceiving()")
        
        self.locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
        
        // Hack for monitoring straight away
        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        // self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        // self.locationManager.stopMonitoringForRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        if beacons.count > 0 {
            let nearestBeacon:CLBeacon = beacons[0] as CLBeacon
            self.delegate.didUpdateProximity(nearestBeacon.rssi)
        }
    }
}