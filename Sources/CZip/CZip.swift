import zip
import Foundation


public enum ZipError: Error {
    case open
    case read(code: Int32)
}

public enum ZipModeOption: CChar, RawRepresentable {
    case read   = 114
    case create = 119
    case append = 97
}

extension zip_entry_t {
    var uncompressed_crc32: UInt32 {
        get { uncomp_crc32 }
    }
    
    var uncompressed_size: UInt64 {
        get { uncomp_size }
    }
    
    var compressed_size: UInt64 {
        get { comp_size }
    }
}

public class CZip {
    var zip: UnsafeMutablePointer<zip_t>!
    var entry: zip_entry_t?
    var mode: ZipModeOption
    
    public init(name: String, mode: ZipModeOption, level: Int32 = ZIP_DEFAULT_COMPRESSION_LEVEL) throws(ZipError) {
        self.zip = UnsafeMutablePointer<zip_t>.allocate(capacity: 1)
        guard let zip = zip_open(name, level, mode.rawValue) else { throw .open }
        self.zip = zip
        self.mode = mode
    }
    
    public init?(_ name: String, _ mode: ZipModeOption, _ level: Int32 = ZIP_DEFAULT_COMPRESSION_LEVEL) {
        self.zip = UnsafeMutablePointer<zip_t>.allocate(capacity: 1)
        guard let zip = zip_open(name, level, mode.rawValue) else { return nil }
        self.zip = zip
        self.mode = mode
    }

    deinit { zip_close(zip) }
    
    public var entry_count: Int { zip_entries_total(zip) }
    public var is_dir: Bool { entry != nil ? zip_entry_isdir(zip) == 1 : false }
    public var entry_uncompressed_size: UInt64 { entry != nil ? entry!.uncompressed_size : 0 }
    public var entry_compressed_size: UInt64 { entry != nil ? entry!.compressed_size : 0 }
    public var entry_crc32: Int { entry != nil ? Int(entry!.uncomp_crc32) : 0 }
    
    // So we need to figure out how to read as well as write by this handle
    func entry_open(at index: Int) throws(ZipError) {
        if self.entry != nil { throw .read(code: -1) }
        guard zip_entry_openbyindex(zip, index) == 0 else { throw .read(code: -1) }
        self.entry = self.zip.pointee.entry
    }
    
    public func entry_close(at index: Int) {
        zip_entry_close(zip)
        entry = nil
    }
    
    public func entry_read(at index: Int, close: Bool = false) throws(ZipError) -> Data {
        if nil != entry && entry!.index != index { throw .read(code: -3) }
        if nil == entry { try entry_open(at: index) }
        defer { if close { entry_close(at: index) } }
        if is_dir { throw .read(code: -2) }
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Int(entry_uncompressed_size), alignment: MemoryLayout<UInt8>.alignment)
        guard zip_entry_noallocread(zip, buffer.baseAddress!, buffer.count) == buffer.count else { throw .read(code: -1) }
        return Data(buffer)
    }
    
    public func entry_name(at index: Int, close: Bool = false) -> String? {
        if nil == entry { do { try entry_open(at: index) } catch { return nil } }
        defer { if close { entry_close(at: index) } }
        return String(cString: zip_entry_name(zip))
    }
}
