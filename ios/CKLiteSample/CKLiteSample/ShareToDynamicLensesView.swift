//
//  ContentView.swift
//  CKLiteSample
//
//  Created by Edgar Neto on 07/11/2022.
//

import SwiftUI

struct ShareToDynamicLensesView: View {
    @State private var lensId: String = "4fb863f7b6024383aff06c814219ac06"
    @State private var clientId: String = "3d68a397-4f69-4f01-94e0-72a9975d8f58"
    @State private var url: String = "something_simple"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("Provide values to the keys below:")
            HStack{
                Text("Lens ID: ").bold()
                TextField("Lens ID", text: $lensId)
            }
            HStack{
                Text("Client ID: ").bold()
                TextField("Client ID", text: $clientId)
            }
            HStack{
                Text("URL: ").bold()
                TextField("URL", text: $url)
            }
            Spacer()
            HStack() {
                Spacer()
                Button(action:{
                    shareDynamicLenses(
                        lensUUID: $lensId.wrappedValue,
                        clientID: $clientId.wrappedValue,
                        launchData: [
                            "share_url":$url.wrappedValue
                        ]
                    )
                }) {
                    Text("Share to dynamic lens")
                }
                Spacer()
            }
        }
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShareToDynamicLensesView()
    }
}
