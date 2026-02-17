import SwiftUI

struct ProgressRingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            // Background ring — ocean teal tint
            Circle()
                .stroke(Color(red: 0.28, green: 0.79, blue: 0.89).opacity(0.12), lineWidth: 10)

            // Progress arc — sunset coral-to-gold gradient
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 0.96, green: 0.52, blue: 0.37),
                            Color(red: 0.98, green: 0.65, blue: 0.32),
                            Color(red: 0.91, green: 0.76, blue: 0.44),
                            Color(red: 0.28, green: 0.79, blue: 0.89),
                            Color(red: 0.96, green: 0.52, blue: 0.37)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)

            // Percentage text
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 28, weight: .heavy, design: .serif))
                    .foregroundStyle(Color(red: 1.0, green: 0.96, blue: 0.90))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ProgressRingView(progress: 0.6)
            .frame(width: 120, height: 120)
    }
}
