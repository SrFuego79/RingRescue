import SwiftUI
import UserNotifications
import UIKit
import AVFoundation

struct ContentView: View {
    // State variables for timer and contact
    @State private var selectedTime: Int = UserDefaults.standard.integer(forKey: "selectedTime")
    @State private var selectedContact: String = UserDefaults.standard.string(forKey: "selectedContact") ?? "Wife"
    @State private var isTimerRunning = false
    @State private var timeRemaining = 0
    @State private var showCallScreen = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var ringtonePlayer: AVAudioPlayer?
    @State private var showInCallScreen = false
    @State private var showHomeScreen = false

    // Available options for timer and contact
    let timeOptions = [1, 2, 5, 10, 15, 30]
    let contactOptions = ["Wife", "Husband", "Partner", "Boss", "Friend"]

    // Timer and background task
    @State private var timer: Timer?
    @State private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // Initializer to request notification permission on launch
    init() {
        requestNotificationPermission()
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Title at the top
                Text("Ring Rescue")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Spacer()

                // Timer Picker Styled as Button
                VStack(spacing: 4) { // Minimized spacing between label and picker
                    Text("Set Timer")
                        .font(.headline)
                        .foregroundColor(.white)
                    Picker("Set Timer", selection: $selectedTime) {
                        ForEach(timeOptions, id: \.self) { time in
                            Text("\(time) min")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 120, height: 40) // Further reduced height to make it narrower
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(8) // Reduced corner radius for a more compact look
                    .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1))
                    .clipped()
                    .onChange(of: selectedTime) {
                        UserDefaults.standard.set(selectedTime, forKey: "selectedTime")
                    }
                }

                // Contact Picker Styled as Button
                VStack(spacing: 4) { // Minimized spacing between label and picker
                    Text("Call From")
                        .font(.headline)
                        .foregroundColor(.white)
                    Picker("Call From", selection: $selectedContact) {
                        ForEach(contactOptions, id: \.self) { contact in
                            Text(contact)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 120, height: 40) // Further reduced height to make it narrower
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(8) // Reduced corner radius for a more compact look
                    .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1))
                    .clipped()
                    .onChange(of: selectedContact) {
                        UserDefaults.standard.set(selectedContact, forKey: "selectedContact")
                    }
                }
                
                Spacer()

                // Start Button at the Bottom
                Button(action: { self.startTimer() }) {
                    Text(isTimerRunning ? "Cancel Rescue Call" : "Start Rescue Call")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isTimerRunning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 5)

                // Display Remaining Time below the Button
                if isTimerRunning {
                    Text("Time Left: \(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
            }
            .padding()
            .alert(isPresented: .constant(timeRemaining == 0 && isTimerRunning)) {
                Alert(
                    title: Text("Incoming Call"),
                    message: Text("Call from \(selectedContact)"),
                    dismissButton: .default(Text("Answer")) {
                        endTimer()
                    }
                )
            }
        }
        // First .sheet modifier to display IncomingCallView when showCallScreen is true
        .sheet(isPresented: $showCallScreen, onDismiss: {
            stopRingtone() // Stop ringtone when the call screen is dismissed
        }) {
            IncomingCallView(callerName: selectedContact, onAnswer: {
                self.showCallScreen = false
                self.stopRingtone() // Stop ringtone on answer
                // Add a slight delay before showing the in-call screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.showInCallScreen = true // Show in-call screen
                }
                self.showInCallScreen = true // Show in-call screen
            }, onDecline: {
                self.showCallScreen = false
                self.stopRingtone() // Stop ringtone on decline
                
                // Add a slight delay before showing the home screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.showHomeScreen = true // Show home screen
                }
                self.showHomeScreen = true // Show home screen
            })
        }

        // Second .sheet modifier to display InCallScreen when showInCallScreen is true
        .sheet(isPresented: $showInCallScreen) {
            InCallScreen(callerName: selectedContact, onEndCall: {
                self.showInCallScreen = false // Dismiss in-call screen when the call ends
            })
        }

        // Third .sheet modifier to display HomeScreenSimulation when showHomeScreen is true
        .sheet(isPresented: $showHomeScreen) {
            HomeScreenSimulation(onExitHomeScreen: {
                self.showHomeScreen = false // Dismiss home screen
            })
        }
    }

    // Function to stop ringtone
    func stopRingtone() {
        ringtonePlayer?.stop()
        ringtonePlayer = nil // Clear the player to fully stop it
    }
    
    // Function to request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    // Function to start the timer and handle background tasks
    func startTimer() {
        if isTimerRunning {
            endTimer()
        } else {
            isTimerRunning = true
            timeRemaining = selectedTime * 60 // Convert minutes to seconds

            // Start a background task to keep timer running for a short period
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "TimerTask") {
                // End the background task if time expires
                self.endBackgroundTask()
            }

            // Schedule local notification for timer completion
            let content = UNMutableNotificationContent()
            content.title = "Incoming Call"
            content.body = "Call from \(selectedContact)"
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false)
            let request = UNNotificationRequest(identifier: "RingRescueNotification", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification scheduling error: \(error)")
                }
            }

            // Start the timer countdown
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.isTimerRunning = false
                    self.timer?.invalidate()
                    self.timer = nil
                    self.showCallScreen = true // Show custom call screen instead of alert
                    self.playRingtone() // Start ringtone when call screen is shown
                    self.endBackgroundTask()
                }
            }
        }
    }

    // Function to end the timer and cancel any background tasks or notifications
    func endTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil

        // End background task
        endBackgroundTask()

        // Cancel scheduled notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RingRescueNotification"])
    }

    // Helper function to end the background task
    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // Function to play audio message
    func playAudioMessage() {
        guard let url = Bundle.main.url(forResource: "message", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play audio message: \(error)")
        }
    }

    // Function to play ringtone
    func playRingtone() {
        guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "mp3") else {
            print("Ringtone file not found")
            return
        }
        do {
            ringtonePlayer = try AVAudioPlayer(contentsOf: url)
            ringtonePlayer?.numberOfLoops = -1 // Loop indefinitely
            ringtonePlayer?.play()
        } catch {
            print("Could not play ringtone: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
