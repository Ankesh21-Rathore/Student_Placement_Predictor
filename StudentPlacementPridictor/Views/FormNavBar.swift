import SwiftUI

struct FormNavBar: View {
    let vm: PlacementPredictorViewModel
    @Binding var showExitAlert: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                Button {
                    vm.goToPreviousStep()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .disabled(vm.currentStep == 0)
                .accessibilityLabel("Go Back")

                Spacer()

                Text("Prediction Form")
                    .font(AppFont.subheadline(15))
                    .foregroundColor(.textSecondary)

                Spacer()

                Button {
                    showExitAlert = true
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 0))

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: 1, alignment: .bottom)
        }
        .background(Color.black.opacity(0.2))
    }
}

struct FormNavBar_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var showExitAlert = false
        let vm = PlacementPredictorViewModel()

        var body: some View {
            FormNavBar(vm: vm, showExitAlert: $showExitAlert)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
