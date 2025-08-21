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
