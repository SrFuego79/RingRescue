import SwiftUI

struct InCallScreen: View {
    var callerName: String
    var onEndCall: () -> Void
    @State private var callDuration = 0

    var body: some View {
        VStack(spacing: 20) {
            Text(callerName)
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)
            
            Text("In Call")
                .font(.title2)
                .foregroundColor(.gray)
            
            // Display call duration in MM:SS format
            Text("\(callDuration / 60):\(String(format: "%02d", callDuration % 60))")
                .font(.system(size: 30))
                .monospacedDigit()
                .padding(.bottom, 50)
            
            Spacer()
            
            // End Call Button
            Button(action: {
                onEndCall() // Call the end call action
            }) {
                Text("End Call")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            // Start call duration timer when the screen appears
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                callDuration += 1
            }
        }
        .background(Color.black.opacity(0.9).ignoresSafeArea())
    }
}
