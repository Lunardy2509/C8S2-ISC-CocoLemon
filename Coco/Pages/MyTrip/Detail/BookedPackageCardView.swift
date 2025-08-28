import SwiftUI

struct BookedPackageCardView: View {
    let package: BookingDetailDataModel.BookedPackageInfo
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: package.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(package.name)
                    .font(.jakartaSans(forTextStyle: .body, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 10))
                        .foregroundColor(Token.grayscale70.toColor())
                    
                    Text("Min. \(package.minParticipants) - Max. \(package.maxParticipants)")
                        .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                        .foregroundColor(Token.grayscale70.toColor())
                }
                
                Text("\(package.price)/Person")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                if !package.voters.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(package.voters.prefix(4), id: \.email) { voter in
                            VoterAvatarView(voter: voter)
                        }
                        
                        if package.voters.count > 4 {
                            Text("+\(package.voters.count - 4)")
                                .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                                .foregroundColor(Token.grayscale70.toColor())
                        }
                        
                        Text("\(package.totalVotes)/\(package.voters.count)")
                            .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Token.additionalColorsWhite.toColor())
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.89, green: 0.91, blue: 0.93), lineWidth: 1)
        )
    }
}
