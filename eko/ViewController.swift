import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    let proximityService = ProximityService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let action : Selector = "handleTap:"
        let tapRecognizer = UITapGestureRecognizer(target: self, action: action)
        tapRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        var alertController = UIAlertController(
            title: "Start radio mode?",
            message: nil,
            preferredStyle: .Alert
        )
        alertController.addAction(UIAlertAction(
            title: "No",
            style: .Default,
            handler: {(action: UIAlertAction!) in NSLog(":((")}
        ))
        alertController.addAction(UIAlertAction(
            title: "Yes",
            style: .Default,
            handler: {(action: UIAlertAction!) in
                NSLog("YES!!")
                self.proximityService.startAdvertising()
            }
        ))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

