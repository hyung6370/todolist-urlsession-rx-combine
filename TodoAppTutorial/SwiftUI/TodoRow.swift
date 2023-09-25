//
//  TodoRow.swift
//  TodoAppTutorial
//
//  Created by KIM Hyung Jun on 2023/09/21.
//

import Foundation
import SwiftUI

struct TodoRow: View {
    
    @State var isSelected: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("id: 123 / 완료여부: 미완료")
                Text("오늘도 빡코딩!")
            }.frame(maxWidth: .infinity)
            
            VStack(alignment: .trailing) {
                actionButtons
                Toggle(isOn: $isSelected, label: {
                    EmptyView()
                })
                .frame(width: 80)
            }
            
            
        }
        .frame(maxWidth: .infinity)
//        .background(Color.yellow)
    }
    
    fileprivate var actionButtons: some View {
        HStack {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("수정")
            })
            .buttonStyle(MyDefaultBtnStyle())
            .frame(width: 80)
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("삭제")
            })
            .buttonStyle(MyDefaultBtnStyle(bgColor: .purple))
            .frame(width: 80)
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        TodoRow()
    }
}
