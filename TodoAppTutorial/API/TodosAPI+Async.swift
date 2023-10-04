//
//  TodosAPI+Async.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/10/03.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa
import Combine
import CombineExt

extension TodosAPI {
    // 모든 할 일 목록 가져오기
    static func fetchTodosWithAsyncResult(page: Int = 1) async -> Result<BaseListResponse<Todo>, APIError> {
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return .failure(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            let todos = listResponse.data
              print("todosResponse: \(listResponse)")
              
              guard let todos = todos,
                    !todos.isEmpty else {
                  return .failure(APIError.noContent)
              }
              
              return .success(listResponse)
        }
        catch {
            
            if let decodingErr = error as? DecodingError {
                return .failure(APIError.decodingError)
            }
            
            return .failure(APIError.unknown(error))
        }
    }
    
    
    static func fetchTodosWithAsync(page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            let todos = listResponse.data
              print("todosResponse: \(listResponse)")
              
              guard let todos = todos,
                    !todos.isEmpty else {
                  throw APIError.noContent
              }
              

              return listResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }
    }
    
    
    // 특정 할 일 가져오기
    static func fetchATodoWithAsync(id: Int) async throws -> BaseResponse<Todo> {
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
              print("baseResponse: \(baseResponse)")
              
              guard let _ = aTodo else {
                  throw APIError.noContent
              }
              

              return baseResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }
    }
    
    // 할 일 검색하기
    static func searchTodosWithAsync(searchTerm: String, page: Int = 1) async throws -> BaseListResponse<Todo> {
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query": searchTerm, "page": "\(page)"])

        
        guard let url = requestUrl else {
            throw APIError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            let todos = listResponse.data
              print("todosResponse: \(listResponse)")
              
              guard let todos = todos,
                    !todos.isEmpty else {
                  throw APIError.noContent
              }
              

              return listResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }
    }
    
    // 할 일 추가하기
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoWithAsync(title: String, isDone: Bool = false) async throws -> BaseResponse<Todo> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos"
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
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
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
              print("baseResponse: \(baseResponse)")
              
              guard let _ = aTodo else {
                  throw APIError.noContent
              }
              

              return baseResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }
    }
    
    
    // 할 일 추가하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithAsync(title: String, isDone: Bool = false) async throws -> BaseResponse<Todo> {
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos-json"
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
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
            throw APIError.jsonEncoding
        }
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
              print("baseResponse: \(baseResponse)")
              
              guard let _ = aTodo else {
                  throw APIError.noContent
              }
              

              return baseResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }
    }
    
    
    
    // 할 일 수정하기 - JSON 방식
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJsonWithAsync(id: Int, title: String, isDone: Bool = false) async throws -> BaseResponse<Todo> {
        
        let urlString = baseURL + "/todos-json/\(id)"
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
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
            throw APIError.jsonEncoding
        }

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
              print("baseResponse: \(baseResponse)")
              
              guard let _ = aTodo else {
                  throw APIError.noContent
              }
              

              return baseResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }

    }
    
    
    
    // 할 일 수정하기 - PUT urlEncoded
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editTodoWithAsync(id: Int, title: String, isDone: Bool = false) async throws -> BaseResponse<Todo> {
        
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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

            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
              print("baseResponse: \(baseResponse)")
              
              guard let _ = aTodo else {
                  throw APIError.noContent
              }
              

              return baseResponse
        }
        catch {
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }

    }
    
    
    
    // 할 일 삭제하기 - DELETE
    
    /// <#Description#>
    /// - Parameters:
    ///   - id : 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    static func deleteATodoWithAsync(id: Int) async throws -> BaseResponse<Todo> {
        
        print(#fileID, #function, #line, "- deleteATodo 호출 됨 / id: \(id)")
        
        // 1. urlRequest를 만든다
        let urlString = baseURL + "/todos/\(id)"
        guard let url = URL(string: urlString) else {
            throw APIError.notAllowedUrl
            
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")

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

            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
              print("baseResponse: \(baseResponse)")
              
              guard let _ = aTodo else {
                  throw APIError.noContent
              }
              

              return baseResponse
        }
        catch {
            if let myError = error as? APIError {
                throw myError
            }
            
            if let apiError = error as? URLError {
                
                throw APIError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw APIError.decodingError
            }
            
            throw APIError.unknown(error)
        }
    }
    
    
    // 할 일 추가 -> 모든 할 일 가져오기 - 에러가 있는 버전
    static func addATodoAndFetchTodosWithAsyncWithError(title: String, isDone: Bool = false) async throws -> [Todo] {
        
        // 1
        let firstResult = try await addATodoWithAsync(title: title)
        // 2
        let secondResult = try await fetchTodosWithAsync()
        
        guard let finalResult = secondResult.data else {
            return []
        }
        
        return finalResult
        
    }
    
    // 할 일 추가 -> 모든 할 일 가져오기 - 에러가 없는 버전
    static func addATodoAndFetchTodosWithAsyncNoError(title: String, isDone: Bool = false) async -> [Todo] {
        
        do {
            // 1
            let firstResult = try await addATodoWithAsync(title: title)
            // 2
            let secondResult = try await fetchTodosWithAsync()
            
            guard let finalResult = secondResult.data else {
                return []
            }
            return finalResult
        }
        catch {
            if let _ = error as? URLError {
                return []
            }
            
            if let _ = error as? APIError {
                return []
            }
            return []
        }
    }
    
    
    // 할 일 추가 -> 모든 할 일 가져오기 - 에러가 없는 버전 - switchToLatest
    static func addATodoAndFetchTodosWithAsyncNoErrorSwitchToLatest(title: String, isDone: Bool = false) -> AnyPublisher<[Todo], Never> {
        
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
    
    
    /// 선택된 할 일들 삭제하기  Async 기반
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodosWithAsyncNoError(selectedTodoIds: [Int]) async -> [Int] {
        
        async let firstResult = self.deleteATodoWithAsync(id: 4809)
        async let secondResult = self.deleteATodoWithAsync(id: 4808)
        async let thirdResult = self.deleteATodoWithAsync(id: 4644)
        
        do {
            let results: [Int?] = try await[firstResult.data?.id, secondResult.data?.id, thirdResult.data?.id]
            
            return results.compactMap { $0 }
        }
        catch {
            
            if let urlErr = error as? URLError {
                return []
            }
            
            if let err = error as? APIError {
                return []
            }
            
            return []
        }
    }
    
    
    /// 선택된 할 일들 삭제하기  Async 기반
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodosWithAsyncWithError(selectedTodoIds: [Int]) async throws -> [Int] {
        
        async let firstResult = self.deleteATodoWithAsync(id: 4645)
        async let secondResult = self.deleteATodoWithAsync(id: 4646)
        async let thirdResult = self.deleteATodoWithAsync(id: 4647)
        
        let results: [Int?] = try await[firstResult.data?.id, secondResult.data?.id, thirdResult.data?.id]
        
        return results.compactMap{ $0 }
    }
    
    /// 선택된 할 일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodosWithAsyncTaskGroupWithError(selectedTodoIds: [Int]) async throws -> [Int] {
        
        try await withThrowingTaskGroup(of: Int?.self) { (group: inout ThrowingTaskGroup<Int?, Error>) -> [Int] in
            
            // 각각 자식 async 태스크를 그룹에 넣기
            for aTodoId in selectedTodoIds {
                group.addTask(operation: {
                    // 단일 API 쏘기
                    let childTaskResult = try await self.deleteATodoWithAsync(id: aTodoId)
                    return childTaskResult.data?.id
                })
            }
            
            var deleteTodoIds: [Int] = []
            
            for try await singleValue in group {
                if let value = singleValue {
                    deleteTodoIds.append(value)
                }
            }
            
            return deleteTodoIds
        }
    }
    
    /// 선택된 할 일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 실제 삭제가 완료된 ID들
    static func deleteSelectedTodosWithAsyncTaskGroupWithNoError(selectedTodoIds: [Int]) async -> [Int] {
        
        await withTaskGroup(of: Int?.self) { (group: inout TaskGroup<Int?>) -> [Int] in
            
            // 각각 자식 async 태스크를 그룹에 넣기
            for aTodoId in selectedTodoIds {
                group.addTask(operation: {
                    
                    do {
                        // 단일 API 쏘기
                        let childTaskResult = try await self.deleteATodoWithAsync(id: aTodoId)
                        return childTaskResult.data?.id
                    }
                    catch {
                        return nil
                    }
                })
            }
            
            var deleteTodoIds: [Int] = []
            
            for await singleValue in group {
                if let value = singleValue {
                    deleteTodoIds.append(value)
                }
            }
            
            return deleteTodoIds
        }
    }
    

    
    
    /// 선택된 할 일들 가져오기 - async 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosAsyncNoError(selectedTodoIds: [Int]) async -> [Todo] {
        
        await withTaskGroup(of: Todo?.self) { (group: inout TaskGroup<Todo?>) -> [Todo] in
            
            // 각각 자식 async 태스크를 그룹에 넣기
            for aTodoId in selectedTodoIds {
                group.addTask(operation: {
                    do {
                        // 단일 API 쏘기
                        let childTaskResult = try await self.fetchATodoWithAsync(id: aTodoId)
                        return childTaskResult.data
                    }
                    catch {
                        return nil
                    }
                })
            }
            
            var fetchedTodos: [Todo] = []
            
            for await singleValue in group {
                if let value = singleValue {
                    fetchedTodos.append(value) // Todo
                }
            }
            
            return fetchedTodos
        }
        
    }
    
    /// 선택된 할 일들 가져오기 - async 기반 API 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 ID들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosAsyncWithError(selectedTodoIds: [Int]) async throws -> [Todo] {
        
        try await withThrowingTaskGroup(of: Todo?.self) { (group: inout ThrowingTaskGroup<Todo?, Error>) in
            for aTodoId in selectedTodoIds {
                group.addTask(operation: {
                    let childTaskResult = try await self.fetchATodoWithAsync(id: aTodoId)
                    return childTaskResult.data
                })
            }
            var fetchedTodos: [Todo] = []
            
            for try await singleValue in group {
                if let value = singleValue {
                    fetchedTodos.append(value) // Todo
                }
            }
            
            return fetchedTodos
        }
    }
}
