//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/24.
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxRelay

class TodosVM: ObservableObject {
    
    // Rx 찌꺼기 담는 용도
    var disposeBag = DisposeBag()
    
    // Combine 찌꺼기 담는 용도
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        print(#fileID, #function, #line, "- ")
        
        TodosAPI.fetchTodosWithPublisherResult()
            .sink { result in
                switch result {
                case .failure(let failure):
                    self.handleError(failure)
                case .success(let baseListTodoResponse):
                    print("TodosVM - fetchTodosWithPublisherResult: baseListTodoResponse: \(baseListTodoResponse)")
                }
            }.store(in: &subscriptions)
        
        
//        TodosAPI.deleteSelectedTodosWithObservableMerge(selectedTodoIds: [4780, 4719, 4782])
//            .subscribe(onNext: { deletedTodo in
//                print("TodosVM - deleteSelectedTodosWithObservable: deletedTodo: \(deletedTodo)")
//            }, onError: { err in
//                print("TodosVM - deleteSelectedTodosWithObservable: err: \(err)")
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteSelectedTodosWithObservable(selectedTodoIds: [4789, 4788, 4787])
//            .subscribe(onNext: { deletedTodos in
//                print("TodosVM - deleteSelectedTodosWithObservable: deletedTodos: \(deletedTodos)")
//            }, onError: { err in
//                print("TodosVM - deleteSelectedTodosWithObservable: err: \(err)")
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.addATodoAndFetchTodosWithObservable(title: "오늘은 추석, 내가 추가함!") // [Todo]
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (response: [Todo]) in
//                print("TodosVM - addATodoAndFetchTodosWithObservable: response: \(response)")
//            }).disposed(by: disposeBag)
        
//        TodosAPI.fetchTodosWithObservable()
//            .observe(on: MainScheduler.instance)
//            .compactMap {$0.data}
//            .catch({ err in
//                print("TodosVM - catch: err: \(err)")
//                return Observable.just([])
//            }) // []
//            .subscribe(onNext: { [weak self] (response: [Todo]) in
//                print("TodosVM - fetchTodosWithObservable: response: \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            }).disposed(by: disposeBag)
        
//        TodosAPI.fetchTodosWithObservableResult()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .success(let response):
//                    print("TodosVM - fetchTodosWithObservable: response: \(response)")
//                }
//            }).disposed(by: disposeBag)
        
        
//        TodosAPI.fetchSelectedTodos(selectedTodoIds: [4799, 4782], completion: { result in
//            switch result {
//            case .success(let data):
//                print("TodosVM - fetchSelectedTodos: data: \(data)")
//            case .failure(let failure):
//                print("TodosVM - fetchSelectedTodos: failure: \(failure)")
//            }
//        })
        
//        TodosAPI.deleteSelectedTodos(selectedTodoIds: [4783, 4782, 4784], completion: { [weak self] deletedTodos in
//            print("TodosVM deleteSelectedTodos - deletedTodos: \(deletedTodos)")
//        })
        
//        TodosAPI.addATodoAndFetchTodos(title: "hj가 추가함111", completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let todolistResponse):
//                print("TodosVM addATodo - todolistResponse: \(todolistResponse.data?.count)")
//            case .failure(let failure):
//                print("TodosVM todolistResponse - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
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
