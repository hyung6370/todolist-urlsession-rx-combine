//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/19.
//

import Foundation
import UIKit
import SwiftUI

class MainVC: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var dummyDataList = ["sdfksdljkf", "dsfiosdofjisd", "foiweoiw",
    "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj", "ioijfowijeiofj"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifiable)
        self.myTableView.dataSource = self
    }
}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifiable, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}

extension MainVC {
    private struct VCRepresentable: UIViewControllerRepresentable {
        
        let mainVC: MainVC
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}

extension UIViewController: StoryBoarded {}

protocol StoryBoarded {
    static func instantiate(_ storyboardName: String?) -> Self
}

extension StoryBoarded {
    
    static func instantiate(_ storyboardName: String? = nil) -> Self {
        let name = storyboardName ?? String(describing: self)
        
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}

protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed { }

protocol ReuseIdentifiable {
    static var reuseIdentifiable: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifiable: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }
