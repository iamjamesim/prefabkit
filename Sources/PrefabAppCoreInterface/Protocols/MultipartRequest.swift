import Foundation

/// A struct that represents a multipart HTTP request.
public struct MultipartRequest {
    /// An enum that represents a MIME type.
    public enum MimeType: String {
        case jpeg = "image/jpeg"
        case png = "image/png"
        case gif = "image/gif"
        case pdf = "application/pdf"
        case json = "application/json"
        case zip = "application/zip"
        case plain = "text/plain"
        case html = "text/html"
        case xml = "text/xml"
        case csv = "text/csv"
        case octetStream = "application/octet-stream"
    }

    /// A struct that represents a file to be included in the multipart request.
    public struct File {
        let partName: String
        let fileName: String
        let mimeType: MimeType
        let fileData: Data

        public init(partName: String, fileName: String, mimeType: MimeType, fileData: Data) {
            self.partName = partName
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileData = fileData
        }
    }

    /// A struct that represents a field to be included in the multipart request.
    public struct Field {
        let name: String
        let value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }

    private static let contentDisposition = "Content-Disposition: form-data"

    /// Request headers.
    public var headers: [String: String] {
        ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }

    /// Request body.
    public var body: Data {
        get {
            var copy = self
            copy.appendLine("--\(boundary)--")
            return copy.data
        }
    }

    private let boundary: String
    private let boundaryLine: String
    private var data = Data()

    /// Creates a new multipart request.
    /// - Parameter boundary: The boundary string used to separate each part of the request.
    public init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
        boundaryLine = "--\(boundary)"
    }

    /// Adds a file to the request.
    /// - Parameter file: The file to add.
    public mutating func addFile(_ file: File)  {
        appendLine(boundaryLine)
        appendLine("\(Self.contentDisposition); name=\"\(file.partName)\"; filename=\"\(file.fileName)\"")
        appendLine("Content-Type: \(file.mimeType.rawValue)")
        appendNewline()
        data.append(file.fileData)
        appendNewline()
    }

    /// Adds a field to the request.
    /// - Parameter field: The field to add.
    public mutating func addField(_ field: Field)  {
        appendLine(boundaryLine)
        appendLine("\(Self.contentDisposition); name=\"\(field.name)\"")
        appendNewline()
        appendLine(field.value)
    }

    private mutating func appendLine(_ line: String) {
        appendString(line)
        appendNewline()
    }

    private mutating func appendNewline() {
        appendString("\r\n")
    }

    private mutating func appendString(_ string: String) {
        data.append(Data(string.utf8))
    }
}
