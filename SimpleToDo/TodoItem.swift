import Foundation


// Lưu vị trí người dùng
struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
}

// Mỗi task là một TodoItem
struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String?
    var date: Date?
    var isCompleted: Bool = false
    var imageData: Data? = nil
    var location: LocationData? = nil
    var journal: String? = nil
}
