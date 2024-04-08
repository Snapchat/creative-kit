//
//  ShareToPreviewView.swift
//  CKLiteSample
//
//  Created by Edgar Neto on 09/11/2022.
//

import SwiftUI

struct ShareToPreviewView: View {
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var caption  = "Hello!"
    @State private var attachmentUrl = "http://kit.snap.com"
    
    var body: some View {
        ScrollView{
            VStack (alignment: .leading) {
                if selectedImage != nil {
                    let resized = resizeImage(image: selectedImage!, newWidth: 200)
                    Image(uiImage: resized!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                Spacer()
                Text("1. Select a photo to share to preview")
                Button("Select photo") {
                    showImagePicker = true
                }
                .sheet(isPresented: self.$showImagePicker) {
                    ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
                }
                Text("2. (Optional) Set a caption")
                TextField("Caption", text: $caption)
                    .textFieldStyle(.roundedBorder)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                Text("3. (Optional) Set an attachment URL")
                TextField("http://kit.snap.com", text: $attachmentUrl)
                    .textFieldStyle(.roundedBorder)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                Spacer()
                HStack()
                {
                    Spacer()
                    Button(action:{
                        shareOnSnapchat(
                            clientID: Identifiers.CLIENT_ID,
                            shareMedia: ShareMedia.image,
                            shareDest: ShareDestination.preview,
                            mediaData: self.selectedImage!.pngData()!,
                            caption: $caption.wrappedValue,
                            attachmentURL: $attachmentUrl.wrappedValue
                        )
                    })
                    {
                        Text("Share to Preview")
                    }
                    .disabled(self.selectedImage == nil)
                    Spacer()
                }
            }
        }
    }
}

struct ShareToPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ShareToCameraView()
    }
}