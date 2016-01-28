//////////// TEST CODE /////////////////


//////////// UPLOAD FILE ////////////////
var filePath = NSBundle.mainBundle().pathForResource("index" , ofType: "txt");
var fileURL = NSURL(fileURLWithPath: filePath!)
var serverURL = NSURL(string: "http://10.5.1.41:8888/SwiftUploadFile/receiveFile.php")

var uploader = FileUploader();
uploader.UploadFile(serverURL! , filePath: fileURL!, fileName: "index", {
(data , success) in
    println("\(NSString(data: data! as! NSData, encoding: NSUTF8StringEncoding)) \(success!)")
})

//////////// LIST FILES ////////////////

let downloader = FileDownloader()

downloader.getListOfFiles("http://10.5.1.41:8888/SwiftUploadFile/listFiles.php", inFolder: "ar" , {
    (success , fileList , downloadFolder) in
    println("\(success!) : \(fileList!) : \(downloadFolder!)")
    let files = downloader.getFilesURLs(fileList!, serverAddress: "http://10.5.1.41:8888/SwiftUploadFile" , serverSubdirectory: downloadFolder!)
    println(files)
})

///////// DOWNLOAD ONE FILE ////////////

downloader.downloadFile(downloadFileURL: "http://10.5.1.41:8888/SwiftUploadFile/uploads/ar/index.txt", {
    (success , content) in
    println("\(success!) : \(content!)")
})