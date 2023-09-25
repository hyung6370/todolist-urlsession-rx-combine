//
//  TodosAPI.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/24.
//

import Foundation

enum TodosAPI {
    
    static let version = "v2"
    
    #if DEBUG // 디버그용
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/\(version)"
    #else // 릴리즈용
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/\(version)"
    #endif
    
    enum APIError: Error {
        case parsingError
        case noContent
        case decodingError
        case badStatus(code: Int)
    }
        
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<TodosResponse, APIError>) -> Void) {
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos" + "?page=\(page)"
        let url = URL(string: urlString)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
            print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
            print("err: \(err)")
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let todosResponse = try JSONDecoder().decode(TodosResponse.self, from: jsonData)
                  let modelObjects = todosResponse.data
                    
                    print("todosResponse: \(todosResponse)")
                    completion(.success(todosResponse))
                } catch {
                  // decoding error
                    completion(.failure(APIError.decodingError))
                }
              }
            
        }.resume()
        
        
    }
    
}


