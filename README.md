# WKWebViewSijainti

Laitteen oman sijainnin kysely CLLocationManager-oliolta ja välitys Javascript-kontekstiin.

Näin vältetään lupapyyntö sovelluksen lisäksi sen sisältämän WKWebView-selainkontekstin sisältä.

## Käyttöönotto

```swift
import WKWebViewSijainti

class ViewController: UIViewController {
    ...
    private var _sijainti: Sijaintihaku?
    ...
    override func viewDidLoad() {
        ...
        let webView = WKWebView(...)
        self._sijainti = webView.sijainti()
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        _sijainti!.sivuAvattu()
    }
}
```
