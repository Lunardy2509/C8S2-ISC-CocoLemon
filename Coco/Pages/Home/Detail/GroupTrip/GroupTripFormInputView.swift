//
//  GroupTripFormInputView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 24/08/25.
//

import SwiftUI

struct GroupTripFormInputView: View {
    @ObservedObject var tripNameViewModel: HomeSearchBarViewModel
    @ObservedObject var calendarViewModel: HomeSearchBarViewModel
    @ObservedObject var dueDateViewModel: HomeSearchBarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Trip Name")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundStyle(Token.grayscale70.toColor())
                
                HomeSearchBarView(viewModel: tripNameViewModel)
            }
            
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Date Visit")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundStyle(Token.grayscale70.toColor())
                
                HomeSearchBarView(viewModel: calendarViewModel)
            }
            
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Due Date Group Form")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundStyle(Token.grayscale70.toColor())
                
                HomeSearchBarView(viewModel: dueDateViewModel)
            }
        }
    }
}
