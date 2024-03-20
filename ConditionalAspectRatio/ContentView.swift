import SwiftUI

extension CGSize {
    var aspectRatio: CGFloat {
        width / height
    }
}

struct ConditionalAspectRatioLayout: Layout {
    var ratio: CGFloat?
    var contentMode: ContentMode
    var enabled: Bool

    func childProposal(proposal: ProposedViewSize, child: Subviews.Element) -> ProposedViewSize {
        guard enabled else {
            return proposal
        }
        let aspectRatio = ratio ?? child.sizeThatFits(.unspecified).aspectRatio
        switch (proposal.width, proposal.height) {
        case (nil, nil): 
            return proposal
        case (let width?, nil): 
            return .init(width: width, height: width/aspectRatio)
        case (nil, let height?): 
            return .init(width: height*aspectRatio, height: height)
        case (let width?, let height?):
            let combine: (CGFloat, CGFloat) -> CGFloat = contentMode == .fit ? min : max
            let width = combine(width, height * aspectRatio)
            return .init(width: width, height: width/aspectRatio)
        }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1)
        let s = subviews[0]
        return s.sizeThatFits(childProposal(proposal: proposal, child: s))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let s = subviews[0]
        s.place(at: bounds.origin, proposal: childProposal(proposal: proposal, child: s))
    }
}

extension View {
    @ViewBuilder
    func conditionalAspectRatio(_ ratio: CGFloat? = nil, contentMode: ContentMode, enabled: Bool = true) -> some View {
        ConditionalAspectRatioLayout(ratio: ratio, contentMode: contentMode, enabled: enabled) {
            self
        }
    }
}

struct TestView: View {
    var body: some View {
        Color.teal
            .overlay {
                Image(systemName: "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolVariant(.fill)
                    .foregroundColor(.red)
                    .frame(width: 150, height: 150)
                    .phaseAnimator([0.5, 1], content: { view, phase in
                        view.scaleEffect(phase)
                    }) { _ in
                        Animation.easeInOut(duration: 1)
                    }
                    .opacity(0.5)
            }
    }
}

struct ContentView: View {
    @State var enabled = true
    var body: some View {
        ScrollView {
            VStack {
                TestView()
                    .border(.red)
                    .conditionalAspectRatio(16/9, contentMode: .fill, enabled: enabled)
                Toggle("Aspect Ratio", isOn: $enabled)
            }
        }
        .animation(.default.speed(0.2), value: enabled)
    }
}

#Preview {
    ContentView()
}
