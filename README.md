# ToDoApp (Node.js + SwiftUI)

![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift)
![Xcode](https://img.shields.io/badge/Xcode-15-blue?logo=xcode)
![iOS](https://img.shields.io/badge/iOS-17-lightgrey?logo=apple)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green?logo=node.js)
![Express](https://img.shields.io/badge/Express.js-Backend-lightgrey?logo=express)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-green?logo=mongodb)

This project is a simple **To-Do List App** built with:
- **Node.js (Express)** and **MongoDB (Mongoose)** for the backend API
- **SwiftUI** for the iOS frontend

The app supports **CRUD operations**:
- Create Task  
- Read (fetch) Task  
- Update Task  
- Delete Task  

---

## 🚀 Backend Setup (Node.js + MongoDB)

### 1. Install dependencies
```bash
npm init -y
npm install express mongoose
```

### 2. MongoDB Setup
Make sure MongoDB is running locally.
Create a database named ToDoApp and a user:
```
user: "root"
pass: "12345"
```

### 3. Run the server
```
node server.js
```
### 📂 Backend Code
server.js
```
const express = require('express');
const mongoose = require('mongoose');
const Tasks = require('./Task.js');  // Adjust path if needed

const app = express();
app.use(express.json());

mongoose.connect("mongodb://localhost:27017/ToDoApp", {
    authSource: "admin",
    user: "root",
    pass: "12345",
    useNewUrlParser: true,
    useUnifiedTopology: true
});

// Create task
app.post('/Tasks', async (req, res) => {
    try {
        const task = await Tasks.create(req.body);
        res.status(201).json(task);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Get all tasks
app.get('/Tasks', async (req, res) => {
    try {
        const tasks = await Tasks.find();
        res.json(tasks);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Delete task by ID
app.delete('/Tasks/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const deletedTask = await Tasks.findByIdAndDelete(id);
        if (!deletedTask) {
            return res.status(404).json({ message: 'Task not found' });
        }
        res.status(200).json({ message: 'Task deleted successfully', deletedTask });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update task
app.patch('/Tasks/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updatedTask = await Tasks.findByIdAndUpdate(id, req.body, { new: true });
        if (!updatedTask) {
            return res.status(404).json({ error: 'Task not found' });
        }
        res.json(updatedTask);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
```

Task.js
```
const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
    _id: { type: Number, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    status: { type: String, required: true }
});

module.exports = mongoose.model('Tasks', taskSchema);
```

## 📱 iOS (SwiftUI Frontend)
### Add Task – ToDoItemView.swift
```
//
//  ToDoItemView.swift
//  ToDoApp
//
//  Created by Matthew Lim on 18/8/25.
//
import SwiftUI

// Model
struct ToDoItem: Codable, Identifiable {
    var id = UUID()
    let _id: Int?
    let title: String?
    let description: String?
    let status: String?
}

struct ToDoItemView: View {
    
    @State private var new_id: Int = 0
    @State private var newTitle: String = ""
    @State private var newDescription: String = ""
    @State private var newStatus: String = ""
    
    // View
    var body: some View {
        
        VStack {
            
            TextField("Enter a new id", value: $new_id, format:.number)
                .textFieldStyle(.roundedBorder)
            
            TextField("Enter a new title", text: $newTitle)
                .textFieldStyle(.roundedBorder)
            
            TextField("Enter a new description", text: $newDescription)
                .textFieldStyle(.roundedBorder)
            
            TextField("Enter a new status", text: $newStatus)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
        }
        
        Button("Add") {
            addToDoItem(item: ToDoItem(_id: new_id, title: newTitle, description: newDescription, status: newStatus), completion: { result in
                switch result {
                case .success(let item):
                    print("Added item: \(item)")
                case .failure(let error):
                    print("Error adding item: \(error)")
                }
            })
        }
    }
}

// View Model
    private func addToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:3000/Tasks") else {
        completion(.failure(NetworkError.invalidURL))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let jsonData = try JSONEncoder().encode(item)
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }
    
    URLSession.shared.dataTask(with: request) {
        data, response, error in if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            completion(.failure(NetworkError.badRequest))
            return
        }
        
        guard let data = data else {
            completion(.failure(NetworkError.noData))
            return
        }
        
        do {
            let createdToDo = try JSONDecoder().decode(ToDoItem.self, from: data)
            completion(.success(createdToDo))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

enum NetworkError: Error {
    case invalidURL
    case badRequest
    case noData
    case decodingError
}

#Preview {
    ToDoItemView()
}
```
### Update Task – ToUpdateItemView.swift
```
//
//  ToUpdateItemView.swift
//  ToDoApp
//
//  Created by Matthew Lim on 19/8/25.
//

import SwiftUI
// Model
struct TaskData: Codable, Identifiable {
    let id = UUID()
    let _id: Int?
    let title: String?
    let description: String?
    let status: String?
}

// View
struct ToUpdateItemView: View {
    
    @State private var new_id: Int = 0
    @State private var new_title: String = ""
    @State private var new_description: String = ""
    @State private var new_status: String = ""
    
    var body: some View {
        VStack {
            TextField("_id", value: $new_id, format: .number)
                .keyboardType(.numberPad)
            
            TextField("title", text: $new_title)
                .keyboardType(.numberPad)
            
            TextField("description", text: $new_description)
                .keyboardType(.numberPad)
            
            TextField("status", text: $new_status)
                .keyboardType(.numberPad)
            
            Button("Update Task") {
                let updatedFields = ["title": new_title, "description": new_description, "status": new_status, "__v": 0]
                NetworkManager.shared.updateTask(_id: new_id, updatedFields: updatedFields) {result in
                    switch result {
                    case .success(let data):
                        print("Item updated: \(data.description)")
                        
                    case .failure(let error):
                        print("Error updating task: \(error.localizedDescription)")
                        
                    }
                }
            }
        }
    }
   
}

// View Model
class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    func updateTask(_id: Int, updatedFields: [String: Any], completion: @escaping (Result<TaskData,Error>) -> Void) {
        guard let url = URL(string:"http://127.0.0.1:3000/Tasks/\(_id)") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
                    request.httpMethod = "PATCH"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: updatedFields, options: [])
                    } catch {
                        completion(.failure(error))
                        return
                    }

                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }

                        guard let data = data else {
                            completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                            return
                        }
                        
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Received JSON: \(jsonString)")
                        }

                        do {
                            let updateTask = try JSONDecoder().decode(TaskData.self, from: data)
                            completion(.success(updateTask))
                        } catch {
                            completion(.failure(error))
                        }
                    }.resume()
    }
    
}

#Preview {
    ToUpdateItemView()
}
```
### Delete Task – ToDeleteItemView.swift
```
//
//  ToDeleteItemView.swift
//  ToDoApp
//
//  Created by Matthew Lim on 19/8/25.
//

import SwiftUI

// Model
struct ToDeleteItem: Codable, Identifiable {
    var id = UUID()
    let _id: Int?
    let title: String?
    let description: String?
    let status: String?
}

struct ToDeleteItemView: View {
    
    @State private var tasks: [Task] = []
    @State private var deleteTaskID: Int = 0
    
    var body: some View {
        //View
        VStack {
            TextField("Enter a new id", value: $deleteTaskID, format:.number)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Delete Task by ID") {
                deleteItems(_id: deleteTaskID)
            }
        }
    }
}
//View Model
private func deleteItems(_id: Int)  {
    let ItemID = _id
    let urlString = "http://127.0.0.1:3000/Tasks/\(ItemID)"
    guard let url = URL(string: urlString) else {
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error deleting item: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            return
        }
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
            print("Item deleted successfully.")
            // Update your UI or data model to reflect the deletion
        } else {
            print("Server error: \(httpResponse.statusCode)")
            // Handle other status codes (e.g., 404 Not Found, 403 Forbidden)
        }
    }.resume()
}

#Preview {
    ToDeleteItemView()
}
```
### View All Tasks – ContentView.swift
```
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
```





