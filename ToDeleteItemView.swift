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
