import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TodoViewModel()
    @State private var showAddView = false
    @State private var selectedTask: TodoItem? = nil
    
    @State private var isSelectionMode = false
    @State private var selectedItems = Set<UUID>()

    var body: some View {
        NavigationView {
            List {
                // Nhóm task theo ngày
                let grouped = Dictionary(grouping: viewModel.items) { item in
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    return formatter.string(from: item.date ?? Date.distantPast)
                }

                ForEach(grouped.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(grouped[key]!) { item in
                            HStack {
                                if isSelectionMode {
                                    Button(action: {
                                        if selectedItems.contains(item.id) {
                                            selectedItems.remove(item.id)
                                        } else {
                                            selectedItems.insert(item.id)
                                        }
                                    }) {
                                        Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.blue)
                                    }
                                } else {
                                    Button(action: {
                                        viewModel.toggleComplete(item: item)
                                    }) {
                                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isCompleted ? .green : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }

                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                        .strikethrough(item.isCompleted)
                                    if let desc = item.description {
                                        Text(desc).font(.subheadline).foregroundColor(.gray)
                                    }
                                    if let journal = item.journal, item.isCompleted {
                                        Text("📝 \(journal)").font(.footnote).foregroundColor(.blue)
                                    }
                                    
                                    
                                }
                                
                                .onTapGesture {
                                        if isSelectionMode {
                                            if selectedItems.contains(item.id) {
                                                selectedItems.remove(item.id)
                                            } else {
                                                selectedItems.insert(item.id)
                                            }
                                        } else {
                                            selectedTask = item
                                        }
                                    }
                                    .onLongPressGesture {
                                        isSelectionMode = true
                                        selectedItems.insert(item.id)
                                    }
                                
                                
                            }
                            .padding()
                            .listRowBackground(
                                isSelectionMode && selectedItems.contains(item.id)
                                ? Color.gray.opacity(0.2)
                                : Color.clear
                            )
                            
                        }
                        
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("To-Do List")
            .toolbar {
                if isSelectionMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Huỷ") {
                            isSelectionMode = false
                            selectedItems.removeAll()
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("🗑️ Xoá (\(selectedItems.count))") {
                            viewModel.items.removeAll { selectedItems.contains($0.id) }
                            isSelectionMode = false
                            selectedItems.removeAll()
                        }
                        .disabled(selectedItems.isEmpty)
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddView = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddView) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(item: $selectedTask) { task in
                AddTaskView(viewModel: viewModel, taskToEdit: task)
            }
        }
    }
}
