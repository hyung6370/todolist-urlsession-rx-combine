//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/24.
//

import Foundation
import Combine

class TodosVM: ObservableObject {
    init() {
        print(#fileID, #function, #line, "- ")
        
        TodosAPI.addATodo(title: "조져 공부!", isDone: false, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let aTodoResponse):
                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
            case .failure(let failure):
                print("TodosVM addATodo - failure: \(failure)")
                self.handleError(failure)
            }
        })
        
//        TodosAPI.searchTodos(searchTerm: "network") { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let searchTodos):
//                print("TodosVM - searchTodos: \(searchTodos)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        }
        
//        TodosAPI.fetchATodo(id: 4782, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.fetchTodos { [weak self] result in
//            
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        }
    }
    
    
    
    // MARK: - 에러 처리
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.APIError {
            let apiError = err as! TodosAPI.APIError
            
            print("handleErr : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증 안됨")
            default:
                print("default")
            }
        }
    } // handleError
}
