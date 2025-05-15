import Foundation

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = [] {
        didSet { saveItems() }  // Auto save mỗi lần thay đổi
    }

    private let key = "todo_items"

    init() {
        loadItems()
    }

    // Thêm mới
    func addItem(title: String, description: String?, date: Date?, imageData: Data?, location: LocationData?, journal: String?, isCompleted: Bool) {
        let newItem = TodoItem(title: title, description: description, date: date, isCompleted: isCompleted, imageData: imageData, location: location, journal: journal)
        items.append(newItem)
    }

    // Cập nhật task
    func updateItem(_ task: TodoItem, title: String, description: String?, date: Date?, imageData: Data?, location: LocationData?, journal: String?) {
        if let index = items.firstIndex(where: { $0.id == task.id }) {
            items[index].title = title
            items[index].description = description
            items[index].date = date
            items[index].imageData = imageData
            items[index].location = location
            items[index].journal = journal
        }
    }

    func toggleComplete(item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }

    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }

    // Lưu vào UserDefaults
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // Tải từ UserDefaults
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = decoded
        }
    }
}
