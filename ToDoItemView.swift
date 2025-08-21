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
