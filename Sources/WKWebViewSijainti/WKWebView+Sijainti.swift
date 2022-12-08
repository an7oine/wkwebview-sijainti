//
// Oman sijainnin kysely CLLocationManager-oliolta.
//

import WebKit
import CoreLocation


public protocol Sijaintihaku {
    func sivuAvattu()
}


fileprivate class Sijainti: NSObject {
    
    var kuuntelijaKaynnissa: Bool = false
    var sallittu: Bool = false
    var kielletty: Bool = false
    
    var webView: WKWebView

    init (_ webView: WKWebView) {
        self.webView = webView
        super.init()
        webView.configuration.userContentController.add(self, name: "listenerAdded");
        webView.configuration.userContentController.add(self, name: "listenerRemoved");
    }
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
}

extension Sijainti: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        sallittu = (status == .authorizedAlways || status == .authorizedWhenInUse)
        kielletty = (status == .restricted || status == .denied)

        if kielletty {
            webView.evaluateJavaScript("navigator.geolocation.helper.error(1, 'Sijaintihaku estetty!');");
        }
        else if sallittu {
              locationManager.startUpdatingLocation();
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.last {
        webView.evaluateJavaScript("navigator.geolocation.helper.success('\(location.timestamp)', \(location.coordinate.latitude), \(location.coordinate.longitude), \(location.altitude), \(location.horizontalAccuracy), \(location.verticalAccuracy), \(location.course), \(location.speed));");
      }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      webView.evaluateJavaScript("navigator.geolocation.helper.error(2, 'Sijaintitietoa ei saatu: (\(error.localizedDescription))');");
    }
}

extension Sijainti: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if (message.name == "listenerAdded") {
        kuuntelijaKaynnissa = true
          
        if kielletty {
        }
        else if sallittu {
            locationManager.startUpdatingLocation();
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    else if (message.name == "listenerRemoved") {
        kuuntelijaKaynnissa = false;
        locationManager.stopUpdatingLocation();
    }
  }
}

extension Sijainti: Sijaintihaku {
    func sivuAvattu() {
        if let fileURL = Bundle.module.url(forResource: "wkwebview-sijainti", withExtension: "js") {
            if let fileContents = try? String(contentsOf: fileURL) {
                webView.evaluateJavaScript(fileContents)
            }
        }
    }
}

public extension WKWebView {
    func sijainti() -> Sijaintihaku {
        Sijainti(self)
    }
}
