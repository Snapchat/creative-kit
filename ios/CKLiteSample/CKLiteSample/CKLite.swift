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

enum ShareMediaType {
    case image
    case video
}

enum CreativeKitStickerMetadataKeys {
    static let posX = "posX"
    static let posY = "posY"
    static let rotation = "rotation"
    static let widthDp = "widthDp"
    static let heightDp = "heightDp"
    static let stickerMetadata = "stickerMetadata"
}

struct StickerData {
    var posX:Float = 0.5
    var posY:Float = 0.5
    var rotation:Float = 0
    var widthDp:Int = 200
    var heightDp:Int = 200
    var image:Data
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

func addSticker(dict: [String:Any], sticker:StickerData) -> [String:Any]
{
    var newDict = dict;
    
    newDict[CreativeKitLiteKeys.stickerImage] = sticker.image
    
    var stickerMetadata = [String:Any]()
    stickerMetadata[CreativeKitStickerMetadataKeys.posX] = sticker.posX
    stickerMetadata[CreativeKitStickerMetadataKeys.posY] = sticker.posY
    stickerMetadata[CreativeKitStickerMetadataKeys.rotation] = sticker.rotation
    stickerMetadata[CreativeKitStickerMetadataKeys.widthDp] = sticker.widthDp
    stickerMetadata[CreativeKitStickerMetadataKeys.heightDp] = sticker.heightDp
    
    var payloadMetadata = [String:Any]()
    payloadMetadata[CreativeKitStickerMetadataKeys.stickerMetadata] = stickerMetadata
    newDict[CreativeKitLiteKeys.payloadMetadata] = payloadMetadata
    
    return newDict
}

func shareDynamicLenses(clientID:String, lensUUID: String, launchData:NSDictionary, caption:String?, sticker:StickerData?) {
    // Pass the content to the pasteboard
    var dict: [String: Any] = [
       CreativeKitLiteKeys.clientID: clientID,
       CreativeKitLiteKeys.lensUUID: lensUUID,
    ]

    // Add Launch Data (optional) - these are values that can be captured by your Lens project
    // More info about Launch Params here: https://docs.snap.com/lens-studio/references/guides/distributing/snap-kit#dynamic-lens-template
    // If you need to pass in any numeric value as part of the launch data,
    // make sure to pass it as a string if precision is important
    do {
       let launchDataData = try JSONSerialization.data(withJSONObject: launchData)
       let launchDataString = NSString.init(data: launchDataData, encoding: NSUTF8StringEncoding)! as String
       dict[CreativeKitLiteKeys.launchData] = launchDataString
    } catch {
       print("JSON serialization failed: ", error)
    }
    
    // Optionally Add caption
    if let caption = caption
    {
        dict[CreativeKitLiteKeys.caption] = caption
    }

    // Optionally Add sticker
    if let sticker = sticker
    {
       dict = addSticker(dict: dict, sticker: sticker)
    }

    createAndOpenShareUrl(clientID:clientID, shareDest: ShareDestination.camera, dict:dict)
}

// Shares media to a full screen snap that can be posted to stories or shared directly with a friend
func shareToPreview(clientID: String, mediaType: ShareMediaType, mediaData: Data, caption: String?, sticker: StickerData?)
{
    // Pass media content to the pasteboard
    var dict: [String: Any] = [ CreativeKitLiteKeys.clientID: clientID ]
    switch mediaType {
    case .image:
        dict[CreativeKitLiteKeys.backgroundImage] = mediaData
    case .video:
        dict[CreativeKitLiteKeys.backgroundVideo] = mediaData
    }
   
    // Optionally Add caption
    if let caption = caption
    {
        dict[CreativeKitLiteKeys.caption] = caption
    }
    
    // Optionally Add sticker
    if let sticker = sticker
    {
       dict = addSticker(dict: dict, sticker: sticker)
    }
    
    createAndOpenShareUrl(clientID:clientID, shareDest: ShareDestination.preview, dict:dict)
}

func shareToCamera(clientID: String, caption: String?, sticker: StickerData?)
{
    // Pass media content to the pasteboard
    var dict: [String: Any] = [ CreativeKitLiteKeys.clientID: clientID ]
    
    // Optionally Add caption
    if let caption = caption
    {
        dict[CreativeKitLiteKeys.caption] = caption
    }
    
    // Optionally Add sticker
    if let sticker = sticker
    {
       dict = addSticker(dict: dict, sticker: sticker)
    }
    
    createAndOpenShareUrl(clientID:clientID, shareDest: ShareDestination.camera, dict:dict)
    
}

func createAndOpenShareUrl(clientID:String, shareDest: ShareDestination, dict:[String:Any])
{
    // Verify if Snapchat can be opened
    guard var urlComponents = URLComponents(string: shareDest.rawValue),
        let url = urlComponents.url,
        UIApplication.shared.canOpenURL(url) else {
        return
    }
    
    let items = [ dict ]
    
    // Set content in the Pasteboard to expire in 5 minutes.
    // Content will be clared as soon as the Snapchat app receives it.
    let expire = Date().addingTimeInterval(5*60)
    let options = [ UIPasteboard.OptionsKey.expirationDate: expire ]
    UIPasteboard.general.setItems(items, options: options)
    
    // Ensure that the pasteboard isn't tampered, we pass the change
    // count to ensure the integrity of the pasteboard content
    let queryItem = URLQueryItem.init(name: "checkcount",
                                      value: String(format: "%ld",
                                      UIPasteboard.general.changeCount))
    
    // Pass Client ID to the share URL
    let clientIdQueryItem = URLQueryItem.init(name: "clientId", value: clientID)
    
    // Pass App Display name to the share URL
    var appDisplayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
    if (appDisplayName == nil) {
        appDisplayName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }
    let appDisplayNameQueryItem = URLQueryItem.init(name: "appDisplayName", value: appDisplayName)
 
    
    // Create and Open the final Share URL
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

func shareOnSnapchat(clientID: String,
                     shareMedia: ShareMediaType,
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
