import SwiftUI

struct PopupView: View {
    @ObservedObject private var timerManager = TimerManager.shared
    @State private var sliderValue: Double = 25
    
    var body: some View {
        VStack(spacing: 20) {
            switch timerManager.state {
            case .idle:
                idleView
            case .running:
                runningView
            case .paused:
                pausedView
            }
        }
        .padding(20)
        .frame(width: 300, height: 400)
        .onAppear {
            sliderValue = Double(timerManager.selectedMinutes)
        }
    }
    
    private var idleView: some View {
        VStack(spacing: 24) {
            Text("集中タイマー")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Text("\(Int(sliderValue))分")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Slider(
                    value: $sliderValue,
                    in: 1...120,
                    step: 5
                ) {
                    Text("時間")
                } minimumValueLabel: {
                    Text("1分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("120分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onChange(of: sliderValue) { newValue in
                    timerManager.selectedMinutes = Int(newValue)
                }
            }
            .padding(.vertical)
            
            Button(action: {
                timerManager.start(minutes: Int(sliderValue))
            }) {
                Text("開始")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    private var runningView: some View {
        VStack(spacing: 24) {
            Text("集中中")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(timerManager.formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
                .padding(.vertical)
            
            VStack(spacing: 12) {
                Button(action: {
                    timerManager.pause()
                }) {
                    Text("一時停止")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button(action: {
                    timerManager.stop()
                }) {
                    Text("キャンセル")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
    
    private var pausedView: some View {
        VStack(spacing: 24) {
            Text("一時停止中")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(timerManager.formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.secondary)
                .padding(.vertical)
            
            VStack(spacing: 12) {
                Button(action: {
                    timerManager.resume()
                }) {
                    Text("再開")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: {
                    timerManager.stop()
                }) {
                    Text("キャンセル")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}

