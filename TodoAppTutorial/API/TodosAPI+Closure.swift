//
//  TodosAPI+Closure.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/27.
//

import Foundation
import MultipartForm

extension TodosAPI {
    
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
    
    // 에러 처리 없는 버전 - result
    // Closure -> Async
    static func fetchTodosClosureToAsync(page: Int = 1) async -> Result<BaseListResponse<Todo>, APIError> {
        return await withCheckedContinuation { (continuation: CheckedContinuation<Result<BaseListResponse<Todo>, APIError>, Never>) in
            
            fetchTodos(page: page, completion: { (result: Result<BaseListResponse<Todo>, APIError>) in
                continuation.resume(returning: result)
            })
        }
    }
    
    // 에러 처리 없는 버전 - [Todo] 배열로 반환
    // Closure -> Async
    static func fetchTodosClosureToAsyncReturnArray(page: Int = 1) async -> [Todo] {
        return await withCheckedContinuation { (continuation: CheckedContinuation<[Todo], Never>) in
            
            fetchTodos(page: page, completion: { (result: Result<BaseListResponse<Todo>, APIError>) in

                switch result {
                case .success(let success):
                    continuation.resume(returning: success.data ?? [])
                case .failure(let _):
                    continuation.resume(returning: [])
                }
            })
        }
    }
    
    // 에러 처리 있는 버전
    // Closure -> Async
    static func fetchTodosClosureToAsyncWithError(page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        return try await withCheckedThrowingContinuation ({ (continuation: CheckedContinuation<BaseListResponse<Todo>, Error>) in
            
            fetchTodos(page: page, completion: { (result: Result<BaseListResponse<Todo>, APIError>) in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            })
        })
    }
    
    // 에러 처리 있는 버전 - 에러 형태 변경
    // Closure -> Async
    static func fetchTodosClosureToAsyncWithMapError(page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        return try await withCheckedThrowingContinuation ({ (continuation: CheckedContinuation<BaseListResponse<Todo>, Error>) in
            
            fetchTodos(page: page, completion: { (result: Result<BaseListResponse<Todo>, APIError>) in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    
                    if let decodingErr = failure as? DecodingError {
                        continuation.resume(throwing: APIError.decodingError)
                        return
                    }
                    
                    continuation.resume(throwing: failure)
                }
            })
        })
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
    
    
    // 할 일 추가하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoJson(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos-json"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: Any] = ["title": title, "is_done": "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
            
        }
        catch {
            return completion(.failure(APIError.jsonEncoding))
        }
        
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
    
    
    
    // 할 일 수정하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJson(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos-json/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: Any] = ["title": title, "is_done": "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
            
        }
        catch {
            return completion(.failure(APIError.jsonEncoding))
        }
        
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
    
    
    
    // 할 일 수정하기 - PUT urlEncoded
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodo(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
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
    
    
    
    // 할 일 삭제하기 - DELETE
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    static func deleteATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        
        print(#fileID, #function, #line, "- deleteATodo 호출 됨 / id: \(id)")
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
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
    
    
    // 할 일 추가 -> 모든 할 일 가져오기
    static func addATodoAndFetchTodos(title: String, isDone: Bool = false, completion: @escaping (Result<BaseListResponse<Todo>, APIError>) -> Void) {
        self.addATodo(title: title) { result in
            switch result {
            case .success(_):
                self.fetchTodos(completion: {
                    switch $0 {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                })
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    
    /// 선택된 할 일들 삭제하기 - 클로저 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodos(selectedTodoIds: [Int], completion: @escaping ([Int]) -> Void) {
        
        let group = DispatchGroup()
        
        // 성공적으로 삭제가 이뤄진 ID들
        var deletedTodoIds: [Int] = [Int]()
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.deleteATodo(id: aTodoId, completion: { result in
                switch result {
                case .success(let response):
                    // 삭제된 아이디를 삭제된 아이디 배열에 넣는다
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                        print("inner deleteATodo - success: \(todoId)")
                    }
                case .failure(let failure):
                    print("inner deleteATodo - failure: \(failure)")
                    
                }
                
                group.leave()
                
            }) // 단일 삭제 API 호출
        }
        
        group.notify(queue: .main) {
            print("모든 API 완료 됨")
            completion(deletedTodoIds)
        }
    }
    
    
    /// 선택된 할 일들 가져오기 - 클로저 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 응답 결과
    static func fetchSelectedTodos(selectedTodoIds: [Int], completion: @escaping (Result<[Todo], APIError>) -> Void) {
        
        let group = DispatchGroup()
        
        // 가져온 할 일들
        var fetchedTodos: [Todo] = [Todo]()
        
        // 에러가 난 것들
        var apiErrors: [APIError] = []
        
        // 응답 결과들
        var apiResults = [Int: Result<BaseResponse<Todo>, APIError>]()
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.fetchATodo(id: aTodoId, completion: { result in
                switch result {
                case .success(let response):
                    // 가져온 할 일을 가져온 할 일 배열에 넣는다
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                        print("inner fetchATodo - success: \(todo)")
                    }
                case .failure(let failure):
                    apiErrors.append(failure)
                    print("inner fetchATodo - failure: \(failure)")
                }
                
                group.leave()
                
            }) // 단일 할 일 조회 API 호출
        }
        
        group.notify(queue: .main) {
            print("모든 API 완료 됨")
            
            // 만약 에러가 있다면 에러 올려주기
            if !apiErrors.isEmpty {
                if let firstError = apiErrors.first {
                    completion(.failure(firstError))
                    return
                }
            }
            
            completion(.success(fetchedTodos))
        }
    }
}
