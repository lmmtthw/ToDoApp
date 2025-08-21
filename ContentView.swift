//
//  ContentView.swift
//  ToDoApp
//
//  Created by Matthew Lim on 18/8/25.
//

import SwiftUI
// Model
struct Task: Codable, Identifiable {
    
    let id = UUID()
    let _id: Int?
    let title: String?
    let description: String?
    let status: String?
    
}

struct ContentView: View {
    //View
    @State private var tasks: [Task] = []
    @State private var addTasks: Bool = false
    @State private var counter = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Text("To Do App")
                    .font(.largeTitle)
                    .padding()

                HStack {
                    
                    NavigationLink {
                        ToDoItemView()
                    } label: {
                        Text("Add Task")
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(.red)
                            .padding()
                    }
                    
                    NavigationLink {
                        ToDeleteItemView()
                    } label: {
                        Text("Delete Task")
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(.red)
                            .padding()
                    }
                    
                    NavigationLink {
                        ToUpdateItemView()
                    } label: {
                        Text("Update Task")
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(.red)
                            .padding()
                            
                    }
                    
                }
                
            }
            
            List(tasks) {task in
                VStack(alignment: .leading) {
                    Text("\(task._id ?? 0)").bold()
                    Text("\(task.title ?? "")").bold()
                    Text("\(task.description ?? "")").bold()
                    Text("\(task.status ?? "")").bold()
                }
                .padding(6)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Tasks from API")
        .onAppear {
            fetchTasks()
        }
        .onReceive(timer) {_ in
            self.updateCounter()}
    }
    // View Model
    
    private func updateCounter() {
        counter += 1
        print("Counter\(counter)")
        fetchTasks()
    }
    
    private func fetchTasks() {
        let url = URL(string: "http://127.0.0.1:3000/Tasks")!
        let username = "root"
        let password = 12345
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){data, response,error in
            if let error = error{
                print("Error while fetching data:", error)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([Task].self, from: data)
                // Assigning the data to the array
                self.tasks = decodedData
            } catch let jsonError {
                print("Failed to decode json", jsonError)
            }
        }
        
        task.resume()
    }
}

#Preview {
    ContentView()
}
