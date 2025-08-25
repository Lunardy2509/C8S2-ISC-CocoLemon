//
//  PackageCard.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import SwiftUI

struct PackageCard: View {
    let package: TravelPackage
    
    var body: some View {
        HStack(alignment: .center, spacing: 13) {
            // Package Image
            AsyncImage(url: URL(string: package.imageUrlString)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Package Info
            VStack(alignment: .leading, spacing: 8) {
                // Package Name
                Text(package.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                // Package Description & Participants
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Text(package.participants)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                
                // Price
                Text(package.price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Arrow Icon
            Button(action: {
                // Handle package selection
            }) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(red: 0.35, green: 0.72, blue: 0.93))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 336, height: 138, alignment: .leading)
        .background(Color(red: 1, green: 1, blue: 1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color(red: 0.89, green: 0.91, blue: 0.93), lineWidth: 1)
        )
    }
}
