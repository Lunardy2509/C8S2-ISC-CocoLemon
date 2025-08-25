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
    @ObservedObject var GroupViewModel: GroupTripActivityDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Trip Name")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                TextField("Enter Trip's Name", text: $GroupViewModel.tripName)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                    )
                    .font(.jakartaSans(forTextStyle: .body, weight: .regular))
            }
            
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Date Visit")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                HStack {
                    Text(GroupViewModel.dateVisitString)
                        .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                        )
                        .onTapGesture {
                            GroupViewModel.presentDateVisitCalendar()
                        }
                    
                    Button {
                        GroupViewModel.presentDateVisitCalendar()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(Token.grayscale70.toColor())
                            .font(.system(size: 20))
                            .padding(.trailing, 16)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Due Date Group Form")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                HStack {
                    Text(GroupViewModel.deadlineString)
                        .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                        )
                        .onTapGesture {
                           GroupViewModel.presentDeadlineCalendar()
                        }
                    
                    Button {
                        GroupViewModel.presentDeadlineCalendar()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(Token.grayscale70.toColor())
                            .font(.system(size: 20))
                            .padding(.trailing, 16)
                    }
                }
            }
        }
    }
}
