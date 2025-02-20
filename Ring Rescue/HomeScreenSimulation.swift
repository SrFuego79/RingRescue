import SwiftUI

struct HomeScreenSimulation: View {
    var onExitHomeScreen: () -> Void

    let icons = ["house.fill", "message.fill", "phone.fill", "camera.fill", "clock.fill", "gearshape.fill"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Home")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            Spacer()
            
            // Simulated App Icons in a Grid Layout
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(icons, id: \.self) { iconName in
                    VStack {
                        Image(systemName: iconName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("App")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding()

            Spacer()

            // Exit Button to return to main screen
            Button(action: {
                onExitHomeScreen()
            }) {
                Text("Exit Home Screen")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
        .background(Color.black.opacity(0.9).ignoresSafeArea())
    }
}
