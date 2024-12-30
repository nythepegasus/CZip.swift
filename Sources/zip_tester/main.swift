import CZip

if CommandLine.arguments.count > 1 {
    let file = CommandLine.arguments[1]
    if let zip = CZip(file, .read) {
        print("Total files in \(file): \(zip.entry_count)")
        for i in 0..<zip.entry_count {
            let name = zip.entry_name(at: i, close: false) ?? "Unknown entry \(i)"
            defer { zip.entry_close(at: i) }
            if !zip.is_dir {
                do {
                    let d = try zip.entry_read(at: i)
                    if let s = String(data: d, encoding: .utf8) {
                        print("\(name): \(zip.entry_uncompressed_size) bytes, CRC32: \(zip.entry_crc32)\n\(s)")
                    }
                } catch {
                    print("Error reading entry \(name): \(error)")
                }
            } else { print("\(name): directory") }
        }
    }
}
