
import Foundation

public enum LogLevel: Int {
    case all = 1, debug, info, warn, error, fatal, off
}

public class MyLogger {

    fileprivate var logLevel: LogLevel = LogLevel.all
    fileprivate var logName: String = ""
    
    fileprivate var printFlag: Bool = true
    
    fileprivate let writeFileQueue = DispatchQueue(label: "writeFileQueue", attributes: [])
    
    
    public func setLog(level: LogLevel) {
        logLevel = level
    }
    
    public func setPrint(flag: Bool) {
        printFlag = flag
    }
    
    public init(level: LogLevel, name: String = "default") {
        logLevel = level
        logName = name
    }
    
    
    fileprivate func doLog(_ level: LogLevel, fileName: String, funcName: String, line: Int, logStr: String) {
        if level.rawValue >= logLevel.rawValue  {
            
            let pathNameArr = fileName.split{$0 == "/"}.map { String($0) }
            var file = fileName
            if pathNameArr.last != nil {
                file = pathNameArr.last!
            }
            
            let funcNameArr = funcName.split{$0 == "("}.map { String($0) }
            var funcNameNoParam = funcName
            if funcNameArr.first != nil {
                funcNameNoParam = funcNameArr.first!
            }
            
            let now = getTodayString()
       
            switch (level) {
            case .debug:
                let outStr = "\(now) [DEBUG] [\(file):\(line)] [\(funcNameNoParam)] \(logStr)"
                printContent(outStr)
                writeFile(outStr + "\n")
            case .info:
                let outStr = "\(now) [INFO] [\(file):\(line)] [\(funcNameNoParam)] \(logStr)"
                printContent(outStr)
                writeFile(outStr + "\n")
            case .warn:
                let outStr = "\(now) [WARN] [\(file):\(line)] [\(funcNameNoParam)] \(logStr)"
                printContent(outStr)
                writeFile(outStr + "\n")
            case .error:
                let outStr = "\(now) [ERROR] [\(file):\(line)] [\(funcNameNoParam)] \(logStr)"
                printContent(outStr)
                writeFile(outStr + "\n")
            case .fatal:
                let outStr = "\(now) [FATAL] [\(file):\(line)] [\(funcNameNoParam)] \(logStr)"
                printContent(outStr)
                writeFile(outStr + "\n")
            case .off:
                break
            default:
                let outStr = "\(now) [\(file):\(line)] [\(funcNameNoParam)] \(logStr)"
                printContent(outStr)
                writeFile(outStr + "\n")
            }
        }
    }
    
    public func debug(_ content: String, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        doLog(.debug, fileName: fileName, funcName: funcName, line: line, logStr: content)
    }
    
    public func info(_ content: String, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        doLog(.info, fileName: fileName, funcName: funcName, line: line, logStr: content)
    }
    
    public func warn(_ content: String, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        doLog(.warn, fileName: fileName, funcName: funcName, line: line, logStr: content)
    }
    
    public func error(_ content: String, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        doLog(.error, fileName: fileName, funcName: funcName, line: line, logStr: content)
    }
    
    public func fatal(_ content: String, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        doLog(.fatal, fileName: fileName, funcName: funcName, line: line, logStr: content)
    }
    
    fileprivate func getTodayString() -> String {
        let now = Date()
        let form = DateFormatter()
        form.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let str = form.string(from: now)
        return str
    }
    
    fileprivate func getDateString() -> String {
        let now = Date()
        let form = DateFormatter()
        form.dateFormat = "yyyyMMdd"
        let str = form.string(from: now)
        
        return str
    }
    
    fileprivate func getLogPath() -> String? {

        let file = logName + "_" + getDateString() + ".log"
        do {
            let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directory = documents.appendingPathComponent("logs", isDirectory: true)
                
            if FileManager.default.fileExists(atPath: directory.path) == false {
                do {
                    try FileManager.default.createDirectory(atPath: directory.path, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    print("\(error.localizedDescription)")
                }
            }
            
            let path = directory.appendingPathComponent(file).path
            print("log path is \(path)")
            return path

        } catch {
            print("Unable to open directory: \(error)")
            return nil
        }
        
    }
    
    fileprivate func printContent(_ content: String) {
        if printFlag {
            print("\(content)")
        }
    }
    
    fileprivate func writeFile(_ content: String) {
        writeFileQueue.async { [self] in
            writeData(content)
        }
    }
    
    fileprivate func writeData(_ content: String) {
    
        guard let path = getLogPath() else {
            print("log path is nil")
            return
        }
        
        guard let streamHandler = OutputStream(toFileAtPath: path, append: true) else {
            print("OutputStream is nil")
            return
        }
        streamHandler.open()
        //let protectionAttribute = [FileAttributeKey.protectionKey: FileProtectionType.complete]
        //try FileManager.default.setAttributes(protectionAttribute, ofItemAtPath: path)
        _ = streamHandler.write(content)
        streamHandler.close()
    }
    
    
    func getLogFilePath(date: String) -> String {
        do {
            let file = logName + "_" + date + ".log"
            
            let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directory = documents.appendingPathComponent("logs", isDirectory: true)
            let path = directory.appendingPathComponent(file).path
            return path
        } catch {
            return ""
        }
    }
    
}


// reference from http://stackoverflow.com/questions/26989493/how-to-open-file-and-append-a-string-in-it-swift
extension OutputStream {
    
    /// Write String to outputStream
    ///
    /// - parameter string:                The string to write.
    /// - parameter encoding:              The NSStringEncoding to use when writing the string. This will default to UTF8.
    /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string.
    ///
    /// - returns:                         Return total number of bytes written upon success. Return -1 upon failure.
    
    func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8, allowLossyConversion: Bool = true) -> Int {
        if let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) {
            var bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
            var bytesRemaining = data.count
            var totalBytesWritten = 0
            
            while bytesRemaining > 0 {
                let bytesWritten = self.write(bytes, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    return -1
                }
                
                bytesRemaining -= bytesWritten
                bytes += bytesWritten
                totalBytesWritten += bytesWritten
            }
            
            return totalBytesWritten
        }
        
        return -1
    }
    
}

