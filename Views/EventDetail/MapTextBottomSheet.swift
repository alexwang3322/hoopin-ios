//
//  MyMapView.swift
//  Hoopin
//
//  Created by sheng on 9/18/26.
//
import SwiftUI

struct MapTextBottomSheet: View {
    
    // Coordinate or address to search
    let address = "1600+Amphitheatre+Parkway,+Mountain+View,+CA"
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Apple Maps Link (Triggers native iOS Maps Sheet)
            Link("Open in Apple Maps", destination: URL(string: "maps://?q=\(address)")!)
                .font(.headline)
                .foregroundColor(.blue)
            
            // 2. Google Maps Link (Opens Google Maps App if installed)
            Link("Open in Google Maps", destination: URL(string: "comgooglemaps://?q=\(address)")!)
                .font(.headline)
                .foregroundColor(.green)
        }
    }
}
