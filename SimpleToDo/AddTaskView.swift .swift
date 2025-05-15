import SwiftUI
import PhotosUI
import CoreLocation

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TodoViewModel
    var taskToEdit: TodoItem? = nil

    // Biến lưu trạng thái nhập liệu
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var journalText = ""
    
    // Quản lý vị trí
    @StateObject var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tiêu đề")) {
                    TextField("Nhập tiêu đề", text: $title)
                }

                Section(header: Text("Mô tả")) {
                    TextField("Mô tả chi tiết", text: $description)
                }

                Section(header: Text("Thời gian thực hiện")) {
                    DatePicker("Chọn ngày", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Ảnh đính kèm")) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                        } else {
                            Text("Chọn ảnh")
                        }
                    }
                }

                Section(header: Text("Nhật ký sau khi hoàn thành")) {
                    TextEditor(text: $journalText)
                        .frame(height: 100)
                }

                Section {
                    

                    Button(action: {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        let location = locationManager.lastLocation.map {
                            LocationData(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                        }

                        if let task = taskToEdit {
                            viewModel.updateItem(task, title: title, description: description, date: selectedDate, imageData: imageData, location: location, journal: journalText)
                            viewModel.toggleComplete(item: task)
                        } else {
                            viewModel.addItem(title: title, description: description, date: selectedDate, imageData: imageData, location: location, journal: journalText, isCompleted: true)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("✔️ Lưu & Hoàn thành")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "Thêm công việc" : "Chỉnh sửa công việc")
            .navigationBarItems(
                leading: Button("Huỷ") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Lưu") {
                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                    let location = locationManager.lastLocation.map {
                        LocationData(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                    }

                    if let task = taskToEdit {
                        viewModel.updateItem(task, title: title, description: description, date: selectedDate, imageData: imageData, location: location, journal: journalText)
                    } else {
                        viewModel.addItem(title: title, description: description, date: selectedDate, imageData: imageData, location: location, journal: journalText, isCompleted: false)
                    }

                    presentationMode.wrappedValue.dismiss()
                }.disabled(title.isEmpty)
            )
        }
        .onAppear {
            if let task = taskToEdit {
                self.title = task.title
                self.description = task.description ?? ""
                self.selectedDate = task.date ?? Date()
                self.journalText = task.journal ?? ""
                if let data = task.imageData {
                    self.selectedImage = UIImage(data: data)
                }
            }
        }
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    self.selectedImage = uiImage
                }
            }
        }
    }
}
