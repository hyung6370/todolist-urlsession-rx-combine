//
//  TodosAPI.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/24.
//

import Foundation
import MultipartForm

enum TodosAPI {
    
    static let version = "v2"
    
    #if DEBUG // 디버그용
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/\(version)"
    #else // 릴리즈용
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/\(version)"
    #endif
    
    enum APIError: Error {
        case noContent
        case decodingError
        case unauthorized
        case notAllowedUrl
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        var info: String {
            switch self {
            case .noContent: return "데이터가 없습니다."
            case .decodingError: return "디코딩 에러입니다."
            case .unauthorized: return "인증되지 않은 사용자입니다."
            case .notAllowedUrl: return "올바른 URL 형식이 아닙니다."
            case let .badStatus(code): return "에러 상태코드: \(code)"
            case .unknown(let err): return "알 수 없는 에러입니다.\n \(err)"
            }
        }
    }
        
    // 모든 할 일 목록 가져오기
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, APIError>) -> Void) {
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
            print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(APIError.unknown(error)))
            }
              
              // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
              // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(APIError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(APIError.unauthorized))
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(APIError.badStatus(code: httpResponse.statusCode)))
            }

            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데, 파싱한 데이터에 따라서 에러 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return completion(.failure(APIError.noContent))
                    }
                    
                    completion(.success(listResponse))
                } catch {
                  // decoding error
                    completion(.failure(APIError.decodingError))
                }
              }
        }.resume()
    }
    
    
    // 특정 할 일 가져오기
    static func fetchATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos" + "/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
            print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(APIError.unknown(error)))
            }
              
              // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
              // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(APIError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(APIError.unauthorized))
            case 204:
                return completion(.failure(APIError.noContent))
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(APIError.badStatus(code: httpResponse.statusCode)))
            }

            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)

                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(APIError.decodingError))
                }
              }
        }.resume()
    }
    
    // 할 일 검색하기
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, APIError>) -> Void) {
        // 1. urlRequest를 만든다
//        let urlString = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query": searchTerm, "page": "\(page)"])
        
        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "page", value: "\(page)"),
//            URLQueryItem(name: "query", value: searchTerm)
//        ]
        
        guard let url = requestUrl else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
            print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(APIError.unknown(error)))
            }
              
              // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
              // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(APIError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(APIError.unauthorized))
            case 204:
                return completion(.failure(APIError.noContent))
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(APIError.badStatus(code: httpResponse.statusCode)))
            }

            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데, 파싱한 데이터에 따라서 에러 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return completion(.failure(APIError.noContent))
                    }
                    
                    completion(.success(listResponse))
                } catch {
                  // decoding error
                    completion(.failure(APIError.decodingError))
                }
              }
        }.resume()
    }
    
    // 할 일 추가하기
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodo(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        print("form.contentType: \(form.contentType)")
        
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = form.bodyData
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
            print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(APIError.unknown(error)))
            }
              
              // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
              // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(APIError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(APIError.unauthorized))
            case 204:
                return completion(.failure(APIError.noContent))
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(APIError.badStatus(code: httpResponse.statusCode)))
            }

            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)

                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(APIError.decodingError))
                }
              }
        }.resume()
    }
}


