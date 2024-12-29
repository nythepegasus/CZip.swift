import zip

public func pzip(zip: zip_t) {
    var z = zip
    let total_files = zip_entries_total(&z)

    print(total_files)
}

public extension zip_t {
    //init(name: String){
    //    .init()
    //}
}
