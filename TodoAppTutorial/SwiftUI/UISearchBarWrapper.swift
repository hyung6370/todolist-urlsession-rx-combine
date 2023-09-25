//
//  UISearchBarWrapper.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/21.
//

import Foundation
import SwiftUI
import UIKit

struct UISearchBarWrapper: UIViewRepresentable {
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeUIView(context: Context) -> some UIView {
        return UISearchBar()
    }
}
