import SwiftUI

/// Event Detail. The web's two-column layout (main content + 320px sidebar) is reflowed into one
/// scrolling column of stacked sections — the natural iOS equivalent once there's no room for
/// side-by-side columns.
protocol BaseDetailView : View {
    func openInMaps(address : String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let appleMapsURL = URL(string: "maps://?q=\(encodedAddress)")!
        let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedAddress)")!
        
        // Check if Google Maps is installed, otherwise fallback to Apple Maps
        if UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        } else {
            UIApplication.shared.open(appleMapsURL)
        }
    }
}
