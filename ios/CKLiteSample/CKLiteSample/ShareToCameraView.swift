//
//  ShareToCameraView.swift
//  CKLiteSample
//
//  Created by Edgar Neto on 09/11/2022.
//

import SwiftUI

struct ShareToCameraView: View {
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
                Text("1. Select a photo to share as a sticker")
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
                        let resized = resizeImage(image: selectedImage!, newWidth: 200)
                        shareOnSnapchat(
                            clientID: Identifiers.CLIENT_ID,
                            shareMedia: ShareMedia.image,
                            shareDest: ShareDestination.camera,
                            mediaData: resized!.pngData()!,
                            caption: $caption.wrappedValue,
                            attachmentURL: $attachmentUrl.wrappedValue
                        )
                    })
                    {
                        Text("Share to camera")
                    }
                    .disabled(self.selectedImage == nil)
                    Spacer()
                }
            }
        }
    }
}

struct ShareToCameraView_Previews: PreviewProvider {
    static var previews: some View {
        ShareToCameraView()
    }
}

struct ImagePickerView: UIViewControllerRepresentable {

    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(picker: self)
    }
}

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
}

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
}

