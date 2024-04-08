import UIKit

// Key names for the Pasteboard
enum CreativeKitLiteKeys {
    static let clientID = "com.snapchat.creativekit.clientID"
    static let backgroundImage = "com.snapchat.creativekit.backgroundImage"
    static let backgroundVideo = "com.snapchat.creativekit.backgroundVideo"
    static let attachmentURL = "com.snapchat.creativekit.attachmentURL"
    static let stickerImage = "com.snapchat.creativekit.stickerImage"
    static let payloadMetadata = "com.snapchat.creativekit.payloadMetadata"
    static let lensUUID = "com.snapchat.creativekit.lensUUID"
    static let appName = "com.snapchat.creativekit.appName"
    static let caption = "com.snapchat.creativekit.captionText"
    static let launchData = "com.snapchat.creativekit.lensLaunchData"
}

enum ShareDestination: String {
    case preview = "snapchat://creativekit/preview/1"
    case camera = "snapchat://creativekit/camera/1"
}

enum ShareMedia {
    case image
    case video
}

enum CreativeKitStickerMetadataKeys {
    static let posX = "posX"
    static let posY = "posY"
    static let rotation = "rotation"
    static let stickerMetadata = "stickerMetadata"
}

func createImageData(_ image: UIImage) -> Data? {
    // NOTE: you can customize the image further before sharing on Snapchat.
    
    return image.jpegData(compressionQuality: 1.0)
}

func createVideoData(_ videoURL: URL) -> Data? {
    // NOTE: you can customize the image further before sharing on Snapchat.
    
    guard let videoData = try? Data(contentsOf: videoURL,
                                    options: .uncached) else {
                                        return nil
    }
    
    return videoData
}

func shareDynamicLenses(lensUUID: String, clientID:String, launchData:NSDictionary) {
       // Verify if Snapchat can be opened
       guard var urlComponents = URLComponents(string: ShareDestination.camera.rawValue),
           let url = urlComponents.url,
           UIApplication.shared.canOpenURL(url)
       else {
           return
       }
           

       // Pass the content to the pasteboard
       var dict: [String: Any] = [
           CreativeKitLiteKeys.clientID: clientID,
           CreativeKitLiteKeys.lensUUID: lensUUID,
       ]

       // Add Launch Data (optional)
       // If you need to pass in any numeric value as part of the launch data,
       // make sure to pass it as a string if precision is important
       do {
           let launchDataData = try JSONSerialization.data(withJSONObject: launchData)
           let launchDataString = NSString.init(data: launchDataData, encoding: NSUTF8StringEncoding)! as String
           dict[CreativeKitLiteKeys.launchData] = launchDataString
       } catch {
           print("JSON serialization failed: ", error)
       }
//       dict[CreativeKitLiteKeys.appName] = "CK Lite Demo"
       dict[CreativeKitLiteKeys.caption] = "This is a test of CK Lite with Dynamic Lenses"
       let items = [dict]

       // Set expiration date for Pasteboard to 5 minutes
       let expire = Date().addingTimeInterval(5 * 60)
       let options = [UIPasteboard.OptionsKey.expirationDate: expire]
       UIPasteboard.general.setItems(items, options: options)

       // Ensure that the pasteboard isn't tampered, we pass the checkcount to ensure
       // the integrity of the pasteboard content
       let queryItem = URLQueryItem.init(
           name: "checkcount",
           value: String(format: "%ld", UIPasteboard.general.changeCount))
       urlComponents.queryItems = [queryItem]
       if let finalURL = urlComponents.url {
           UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
       }
}

func shareOnSnapchat(clientID: String,
                     shareMedia: ShareMedia,
                     shareDest: ShareDestination,
                     mediaData: Data,
                     caption: String?,
                     attachmentURL: String?) {
    // Verify if Snapchat can be opened
    guard var urlComponents = URLComponents(string: shareDest.rawValue),
        let url = urlComponents.url,
        UIApplication.shared.canOpenURL(url) else {
        return
    }
    
    // Pass the content to the pasteboard
    var dict: [String: Any] = [ CreativeKitLiteKeys.clientID: clientID ]
    switch shareMedia {
    case .image:
        dict[CreativeKitLiteKeys.backgroundImage] = mediaData
    case .video:
        dict[CreativeKitLiteKeys.backgroundVideo] = mediaData
    }
    
    if attachmentURL != nil && !(attachmentURL!.isEmpty) {
        dict[CreativeKitLiteKeys.attachmentURL] = attachmentURL
//        dict[CreativeKitLiteKeys.appName] = "My App Name"
    }
    
    if caption != nil && !(caption!.isEmpty){
        dict[CreativeKitLiteKeys.caption] = caption
    }
    
    if shareDest == ShareDestination.camera {
        let stickerData = mediaData
        dict[CreativeKitLiteKeys.stickerImage] = stickerData
        
        var stickerMetadata = [String:Any]()
        stickerMetadata[CreativeKitStickerMetadataKeys.posX] = 0.5
        stickerMetadata[CreativeKitStickerMetadataKeys.posY] = 0.5
        var payloadMetadata = [String:Any]()
        payloadMetadata[CreativeKitStickerMetadataKeys.stickerMetadata] = stickerMetadata
        dict[CreativeKitLiteKeys.payloadMetadata] = payloadMetadata
    }
    
    let items = [ dict ]
    
    // The content in the Pasteboard to expire in 5 minutes
    let expire = Date().addingTimeInterval(5*60)
    let options = [ UIPasteboard.OptionsKey.expirationDate: expire ]
    UIPasteboard.general.setItems(items, options: options)
    
    // Ensure that the pasteboard isn't tampered, we pass the change
    // count to ensure the integrity of the pasteboard content
    let queryItem = URLQueryItem.init(name: "checkcount",
                                      value: String(format: "%ld",
                                      UIPasteboard.general.changeCount))
    let clientIdQueryItem = URLQueryItem.init(name: "clientId", value: clientID)
    var appDisplayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
    if (appDisplayName == nil) {
        appDisplayName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }
    
    let appDisplayNameQueryItem = URLQueryItem.init(name: "appDisplayName", value: appDisplayName)
 
    urlComponents.queryItems = [
        queryItem,
        clientIdQueryItem,
        appDisplayNameQueryItem
    ]
    if let finalURL = urlComponents.url {
        UIApplication.shared.open(finalURL, options: [:],
                                  completionHandler: nil)
    }
}
