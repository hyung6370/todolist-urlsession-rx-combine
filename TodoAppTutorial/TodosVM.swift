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
        TodosAPI.fetchTodos { result in
            switch result {
            case .success(let todosResponse):
                print("TodosVM - todosResponse: \(todosResponse)")
            case .failure(let failure):
                print("TodosVM - failure: \(failure)")
            }
        }
    }
}
