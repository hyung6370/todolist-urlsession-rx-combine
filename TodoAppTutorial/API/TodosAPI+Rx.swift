//
//  TodosAPI+Rx.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/28.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa

extension TodosAPI {
    // 모든 할 일 목록 가져오기
    static func fetchTodosWithObservableResult(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, APIError>> {
        // 1. urlRequest를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(APIError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, APIError> in
                
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다

                  
                  // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
                  // we verify the that status code is in the 200 range which signals all went well with the GET request
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
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데, 파싱한 데이터에 따라서 에러 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return .failure(APIError.noContent)
                    }
                    
                    return .success(listResponse)
                } catch {
                  // decoding error
                    return .failure(APIError.decodingError)
                }
              })
    }
    
    
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        // 1. urlRequest를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다

                  
                  // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
                  // we verify the that status code is in the 200 range which signals all went well with the GET request
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

                
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데, 파싱한 데이터에 따라서 에러 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        throw APIError.noContent
                    }
                    
                    return listResponse
                } catch {
                  // decoding error
                    throw APIError.decodingError
                }
              })
    }
    
    
    
    
    
    // 특정 할 일 가져오기
    static func fetchATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos" + "/\(id)"
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
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
                
                // convert data to our swift model
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)

                    return baseResponse
                } catch {
                    throw APIError.decodingError
                }
            })
    }
    
    // 할 일 검색하기
    static func searchTodosWithObservable(searchTerm: String, page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query": searchTerm, "page": "\(page)"])

        
        guard let url = requestUrl else {
            return Observable.error(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                
                  // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
                  // we verify the that status code is in the 200 range which signals all went well with the GET request
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
                
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데, 파싱한 데이터에 따라서 에러 처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        throw APIError.noContent
                    }
                    
                    return listResponse
                } catch {
                  // decoding error
                    throw APIError.decodingError
                }

            }
    }
    
    // 할 일 추가하기
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoWithObservable(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos"
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
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
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                print("data: \(data)") // 들어오는 실제적인 데이터(JSON 데이터)
                print("urlResponse: \(urlResponse)") // 호출했을 때 들어오는 모든 내용의 데이터가 담겨있다
                  
                  // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
                  // we verify the that status code is in the 200 range which signals all went well with the GET request
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

                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)

                    return baseResponse
                } catch {
                  // decoding error
                    throw APIError.decodingError
                }
            }
    }
    
    
    // 할 일 추가하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithObservable(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos-json"
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
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
            return Observable.error(APIError.jsonEncoding)
        }

        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
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
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return baseResponse
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    
    
    // 할 일 수정하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJsonWithObservable(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos-json/\(id)"
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
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
            return Observable.error(APIError.jsonEncoding)
        }
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
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

                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)

                    return baseResponse
                } catch {
                    throw APIError.decodingError
                }
            }

    }
    
    
    
    // 할 일 수정하기 - PUT urlEncoded
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoWithObservable(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
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

                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)

                    return baseResponse
                } catch {
                    throw APIError.decodingError
                }
            }

    }
    
    
    
    // 할 일 삭제하기 - DELETE
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    static func deleteATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        
        print(#fileID, #function, #line, "- deleteATodo 호출 됨 / id: \(id)")
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            return Observable.error(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
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
                
                do {
                    // JSON -> Struct로 변경하고 있는 과정(디코딩, 데이터 파싱)
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)

                    return baseResponse
                } catch {
                    
                    throw APIError.decodingError
                }
            }
    }
    
    
    // 할 일 추가 -> 모든 할 일 가져오기
    static func addATodoAndFetchTodosWithObservable(title: String, isDone: Bool = false) -> Observable<[Todo]> {
        
        // 1
        return self.addATodoWithObservable(title: title)
            .flatMapLatest { (response: BaseResponse<Todo>) in
                self.fetchTodosWithObservable()
            }
            .compactMap {$0.data}
            .catch({ err in
                print("TodosAPI - catch: err: \(err)")
                return Observable.just([])
            })
            .share(replay: 1)
    }
    
    
    /// 선택된 할 일들 삭제하기 - RX 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodosWithObservable(selectedTodoIds: [Int]) -> Observable<[Int]> {
        
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
    
    static func deleteSelectedTodosWithObservableMerge(selectedTodoIds: [Int]) -> Observable<Int> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map { $0.data?.id }
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallObservables).compactMap{ $0 }
    }
    
    
    /// 선택된 할 일들 가져오기 - Rx 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservable(selectedTodoIds: [Int]) -> Observable<[Todo]> {
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Todo?> in
            return self.fetchATodoWithObservable(id: id)
                .map { $0.data } // Todo?
                .catchAndReturn(nil)
        }
        
        return Observable.zip(apiCallObservables).map { // Observable<[Todo?]>
            $0.compactMap{ $0 }
        } // Observable[Todo]
    }
    
    static func fetchSelectedTodosWithObservableMerge(selectedTodoIds: [Int]) -> Observable<Todo> {
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2, 배열로 단일 API들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Todo?> in
            return self.fetchATodoWithObservable(id: id)
                .map { $0.data } // Todo?
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallObservables).compactMap { $0 }
    }
}
