////
////  ToDoList.swift
////  My Orders
////
////  Created by שיראל זכריה on 20/12/2023.
////
//
//import Foundation
//import SwiftUI
//
//struct Task: Identifiable {
//    var id = UUID()
//    var title: String
//    var isCompleted: Bool = false
//}
//
//struct TaskListView: View {
//    @State private var tasks: [Task] = []
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(tasks) { task in
//                    Text(task.title)
//                        .foregroundColor(task.isCompleted ? .gray : .primary)
//                        .strikethrough(task.isCompleted)
//                        .onTapGesture {
//                            toggleTaskCompletion(task: task)
//                        }
//                }
//                .onDelete(perform: deleteTasks)
//            }
//            .navigationTitle("ToDo List")
//            .navigationBarItems(trailing: addButton)
//        }
//    }
//
//    var addButton: some View {
//        Button(action: {
//            addTask()
//        }) {
//            Image(systemName: "plus")
//        }
//    }
//
//    func addTask() {
//        // Add your logic to present a task creation UI
//    }
//
//    func toggleTaskCompletion(task: Task) {
//        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//            tasks[index].isCompleted.toggle()
//        }
//    }
//
//    func deleteTasks(offsets: IndexSet) {
//        tasks.remove(atOffsets: offsets)
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        TabView {
//            TaskListView()
//                .tabItem {
//                    Label("ToDo", systemImage: "checkmark.circle")
//                }
//
//            TaskListView()
//                .tabItem {
//                    Label("Shopping", systemImage: "cart")
//                }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//@main
//struct AppMain: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
