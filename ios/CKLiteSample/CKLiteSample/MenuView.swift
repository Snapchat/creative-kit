//
//  MenuView.swift
//  CKLiteSample
//
//  Created by Edgar Neto on 09/11/2022.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack {
            Image("ghost_logo")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("CKLite Demo")
            Spacer()
            NavigationView {
                VStack(spacing:30) {
                    NavigationLink(destination: ShareToDynamicLensesView(), label: {Label("Dynamic Lenses", systemImage: "camera")})
                    NavigationLink(destination: ShareToCameraView(), label: {Label("Share to Camera", systemImage: "camera.circle")})
                    NavigationLink(destination: ShareToPreviewView(), label: {Label("Share to Preview", systemImage: "iphone")})
                }
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
