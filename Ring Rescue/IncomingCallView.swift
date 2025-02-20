import SwiftUI

struct IncomingCallView: View {
    var callerName: String
    var onAnswer: () -> Void
    var onDecline: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // Incoming Call Text
                Text("Incoming Call")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                
                // Caller Name
                Text(callerName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 2)

                Spacer()

                // Accept and Decline Buttons
                HStack(spacing: 60) {
                    // Decline Button
                    Button(action: {
                        onDecline()
                    }) {
                        VStack {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                            Text("Decline")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }

                    // Accept Button
                    Button(action: {
                        onAnswer()
                    }) {
                        VStack {
                            Image(systemName: "phone.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                            Text("Accept")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.bottom, 50) // Position closer to the bottom
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black.opacity(0.9).ignoresSafeArea()) // Fullscreen background
            .transition(.move(edge: .bottom))
        }
    }
}
