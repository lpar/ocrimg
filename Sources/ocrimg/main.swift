
import AppKit
import Vision

if #available(macOS 10.15, *) {
    let cwd = FileManager.default.currentDirectoryPath
    var i = 0
    for arg in CommandLine.arguments {
        if i == 0 {
            i += 1
            continue
        }
        var filename = arg
        if !filename.hasPrefix("/") {
            filename = cwd + "/" + filename
        }
        print(filename)
        let r = Recognizer(fromFile: filename)
        r.run()
    }
} else {
    print("This code requires macOS 10.15 or higher")
    exit(0)
}

@available(macOS 10.15, *)
class Recognizer {
    var imageFile: String
    
    init (fromFile filename: String) {
        imageFile = filename
    }
    
    func run() {
        guard let imageRef = NSImage(byReferencingFile: imageFile) else { return }
        
        guard let cgImage = imageRef.cgImage(forProposedRect: nil, context: nil, hints: nil) else {return}
        
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
                    return
                }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        // Process the recognized strings.
        processResults(results: recognizedStrings)
    }
    
    func processResults(results: [String]) {
        let text = results.joined(separator: " ")
        
        if let regex = try? NSRegularExpression(pattern: "[\r\n'\"]", options: .caseInsensitive) {
            let safetext = regex.stringByReplacingMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text), withTemplate: "")
            
            let scriptText = """
tell app "Finder" to set comment of (POSIX file "\(imageFile)" as alias) to "\(safetext)"
"""
            if let script = NSAppleScript(source: scriptText) {
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if let err = error {
                    print(err)
                }
            }
        }
    }
}

func plistify(text: String) -> String {
    do {
        let data = try PropertyListSerialization.data(fromPropertyList: text, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
        let s:String = data.compactMap({ String(format: "%02x", $0) }).joined()
        return s
    } catch {
        return ""
    }
}
