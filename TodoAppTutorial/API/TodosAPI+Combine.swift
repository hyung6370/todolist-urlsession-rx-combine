//
//  TodosAPI+Combine.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/10/02.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa
import Combine
import CombineExt

extension TodosAPI {
    // 모든 할 일 목록 가져오기
    static func fetchTodosWithPublisherResult(page: Int = 1) -> AnyPublisher<Result<BaseListResponse<Todo>, APIError>, Never> { // Never는 에러를 보내지 않는다는 뜻
        // Result <성공, 실패> 응답 Publisher
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Just(.failure(APIError.notAllowedUrl)).eraseToAnyPublisher() // 이벤트 한 번 보내려면 Just!
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map({ (data: Data, urlResponse: URLResponse) -> Result<BaseListResponse<Todo>, APIError> in
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")

                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(APIError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(APIError.unauthorized)
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(APIError.badStatus(code: httpResponse.statusCode))
                }

                
                do {
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return .failure(APIError.noContent)
                    }
                    
                    return .success(listResponse)
                } catch {
                    return .failure(APIError.decodingError)
                }
            })
//            .catch({ err in
//                return Just(.failure(APIError.unknown(nil)))
//            })
            .replaceError(with: .failure(APIError.unknown(nil))) // 이게 좀 더 안전한 방법
//            .assertNoFailure() // 에러가 무조건 나지 않는다고 확언! (주로 테스트에서 사용)
            .eraseToAnyPublisher()
    }
    
    
    static func fetchTodosWithPublisher(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, APIError> {
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")

                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }

                return data
            })
            // JSON -> Struct로 변경, 즉 디코딩, 데이터 파싱
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in // 상태 코드는 200인데 파싱한 데이터에 따라서 에러 처리
                guard let todos = response.data,
                        !todos.isEmpty else {
                    throw APIError.noContent
               }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError { // API 에러라면
                    return error
                }
                
                if let _ = err as? DecodingError { // 디코딩 에러라면
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    
    
    
    
    // 특정 할 일 가져오기
    static func fetchATodoWithPublisher(id: Int) -> AnyPublisher<BaseResponse<Todo>, APIError> {
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
                
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let _ = response.data else {
                    throw APIError.noContent
                }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            }).eraseToAnyPublisher()
    }
    
    // 할 일 검색하기
    static func searchTodosWithPublisher(searchTerm: String, page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, APIError> {
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query": searchTerm, "page": "\(page)"])

        
        guard let url = requestUrl else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)")
                print("urlResponse: \(urlResponse)")

                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }

                return data
            })
            // JSON -> Struct로 변경, 즉 디코딩, 데이터 파싱
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in // 상태 코드는 200인데 파싱한 데이터에 따라서 에러 처리
                guard let todos = response.data,
                        !todos.isEmpty else {
                    throw APIError.noContent
               }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError { // API 에러라면
                    return error
                }
                
                if let _ = err as? DecodingError { // 디코딩 에러라면
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    // 할 일 추가하기
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoWithPublisher(title: String, isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
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
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
                
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let _ = response.data else {
                    throw APIError.noContent
                }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            }).eraseToAnyPublisher()
    }
    
    
    // 할 일 추가하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithPublisher(title: String, isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos-json"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
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
            return Fail(error: APIError.jsonEncoding).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
                
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let _ = response.data else {
                    throw APIError.noContent
                }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            }).eraseToAnyPublisher()    }
    
    
    
    // 할 일 수정하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJsonWithPublisher(id: Int, title: String, isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
        
        let urlString = baseURL + "/todos-json/\(id)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
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
            return Fail(error: APIError.jsonEncoding).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
                
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let _ = response.data else {
                    throw APIError.noContent
                }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            }).eraseToAnyPublisher()

    }
    
    
    
    // 할 일 수정하기 - PUT urlEncoded
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoWithPublisher(id: Int, title: String, isDone: Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
        
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
                
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let _ = response.data else {
                    throw APIError.noContent
                }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            }).eraseToAnyPublisher()

    }
    
    
    
    // 할 일 삭제하기 - DELETE
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    static func deleteATodoWithPublisher(id: Int) -> AnyPublisher<BaseResponse<Todo>, APIError> {
        
        print(#fileID, #function, #line, "- deleteATodo 호출 됨 / id: \(id)")
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) -> Data in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw APIError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default: print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.badStatus(code: httpResponse.statusCode)
                }
                
                return data
                
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let _ = response.data else {
                    throw APIError.noContent
                }
                return response
            })
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let _ = err as? DecodingError {
                    return APIError.decodingError
                }
                
                return APIError.unknown(nil)
            }).eraseToAnyPublisher()
    }
    
    
    // 할 일 추가 -> 모든 할 일 가져오기 - 에러가 있는 버전
    static func addATodoAndFetchTodosWithPublisher(title: String, isDone: Bool = false) -> AnyPublisher<[Todo], APIError> {
        
        // 1
        return self.addATodoWithPublisher(title: title)
            .flatMap { _ in
                self.fetchTodosWithPublisher()
            } // BaseListResponse<Todo>
            .compactMap { $0.data }
//            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    // 할 일 추가 -> 모든 할 일 가져오기 - 에러가 없는 버전
    static func addATodoAndFetchTodosWithPublisherNoError(title: String, isDone: Bool = false) -> AnyPublisher<[Todo], Never> {
        
        // 1
        return self.addATodoWithPublisher(title: title)
            .flatMap { _ in
                self.fetchTodosWithPublisher()
            } // BaseListResponse<Todo>
            .compactMap { $0.data }
//            .catch({ err in
//                print("TodosAPI - catch: err: \(err)")
//                return Just([]).eraseToAnyPublisher()
//            })
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    // 할 일 추가 -> 모든 할 일 가져오기 - 에러가 없는 버전 - switchToLatest
    static func addATodoAndFetchTodosWithPublisherNoErrorSwitchToLatest(title: String, isDone: Bool = false) -> AnyPublisher<[Todo], Never> {
        
        // 1
        return self.addATodoWithPublisher(title: title)
            .map { _ in
                self.fetchTodosWithPublisher()
            } // BaseListResponse<Todo>
            .switchToLatest()
            .compactMap { $0.data }
//            .catch({ err in
//                print("TodosAPI - catch: err: \(err)")
//                return Just([]).eraseToAnyPublisher()
//            })
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    /// 선택된 할 일들 삭제하기 - Combine 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> Observable<[Int]> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map { $0.data?.id } // Int?
                .catchAndReturn(nil)
//                .catch { err in
//                    return Observable.just(nil)
//                }
        }
        
        return Observable.zip(apiCallObservables).map { // Observable<[Int?]>
            $0.compactMap{ $0 } // Int
        } // Observable[Int]
        
    }
    
    static func deleteSelectedTodosWithPublisherMergeWithError(selectedTodoIds: [Int]) -> AnyPublisher<Int, APIError> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallPublishers: [AnyPublisher<Int?, APIError>] = selectedTodoIds.map { id -> AnyPublisher<Int?, APIError> in
            return self.deleteATodoWithPublisher(id: id)
                .map { $0.data?.id }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(apiCallPublishers).eraseToAnyPublisher().compactMap{ $0 }.eraseToAnyPublisher()
    }
    
    static func deleteSelectedTodosWithPublisherMerge(selectedTodoIds: [Int]) -> AnyPublisher<Int, Never> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallPublishers: [AnyPublisher<Int?, Never>] = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteATodoWithPublisher(id: id)
                .map { $0.data?.id }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(apiCallPublishers).eraseToAnyPublisher().compactMap{ $0 }.eraseToAnyPublisher()
    }
    
    static func deleteSelectedTodosWithPublisherZip(selectedTodoIds: [Int]) -> AnyPublisher<[Int], Never> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallPublishers: [AnyPublisher<Int?, Never>] = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteATodoWithPublisher(id: id)
                .map { $0.data?.id }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return apiCallPublishers.zip().map{ $0.compactMap{ $0 } }.eraseToAnyPublisher()
    }
    
    
    /// 선택된 할 일들 가져오기 - Rx 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> AnyPublisher<[Todo], Never> {
        
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Todo?, Never> in
            return self.fetchATodoWithPublisher(id: id)
                .map { $0.data } // Todo?
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return apiCallPublishers.zip().map { $0.compactMap{ $0 } }.eraseToAnyPublisher()
    }
    
    static func fetchSelectedTodosWithPublisherMerge(selectedTodoIds: [Int]) -> AnyPublisher<Todo, Never> {
        
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Todo?, Never> in
            return self.fetchATodoWithPublisher(id: id)
                .map { $0.data } // Todo?
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(apiCallPublishers).compactMap{ $0 }.eraseToAnyPublisher()
    }
}
