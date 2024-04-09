//
//  ContentView.swift
//  CKLiteSample
//
//  Created by Edgar Neto on 07/11/2022.
//

import SwiftUI

struct ShareToDynamicLensesView: View {
    @State private var key1: String = "value for key1"
    @State private var key2: String = "value for key2"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("Provide values to the keys below:")
            VStack{
                HStack{
                    Text("Key 1: ").bold()
                    TextField("Value 1", text: $key1)
                }
                HStack{
                    Text("Key 2: ").bold()
                    TextField("Value 2", text: $key2)
                }
            }
            Spacer()
            HStack() {
                Spacer()
                Button(action:{
                    shareDynamicLenses(
                        clientID: Identifiers.CLIENT_ID,
                        lensUUID: Identifiers.LENS_UUID,
                        launchData: [
                            "key1":$key1.wrappedValue,
                            "key2":$key2.wrappedValue
                        ],
                        caption: nil,
                        sticker: nil
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
