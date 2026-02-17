import SwiftUI

struct ProgressRingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.1), lineWidth: 10)

            // Progress arc — orange to green
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 1.0, green: 0.369, blue: 0.2),
                            Color(red: 0.718, green: 0.812, blue: 0.31),
                            Color(red: 0.102, green: 0.0, blue: 0.537),
                            Color(red: 1.0, green: 0.369, blue: 0.2)
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
                    .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.937, green: 0.906, blue: 0.827)
        ProgressRingView(progress: 0.6)
            .frame(width: 120, height: 120)
    }
}
