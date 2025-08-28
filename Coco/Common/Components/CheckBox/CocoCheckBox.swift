import SwiftUI

struct CocoCheckBox: View {
    @ObservedObject var viewModel: CocoCheckBoxViewModel
    var style: CocoCheckBoxStyle
    
    var body: some View {
        Button(action: {
            viewModel.toggle()
        }, label: {
            HStack {
                Image(systemName: viewModel.isChecked ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: style.size, height: style.size)
                    .foregroundColor(viewModel.isChecked ? style.checkedColor : style.uncheckedColor)
                
                Text(viewModel.label)
                    .font(style.font)
                
                Spacer()
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - HostingController for UIKit
final class CocoCheckBoxHostingController: UIHostingController<CocoCheckBox> {
    init(viewModel: CocoCheckBoxViewModel, style: CocoCheckBoxStyle = CocoCheckBoxStyle()) {
        let view = CocoCheckBox(viewModel: viewModel, style: style)
        super.init(rootView: view)
    }
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
