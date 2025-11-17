import SwiftUI

struct PopupView: View {
    @ObservedObject private var timerManager = TimerManager.shared
    @State private var sliderValue: Double = 25
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            if showingSettings {
                settingsView
            } else {
                switch timerManager.state {
                case .idle:
                    idleView
                case .running:
                    runningView
                case .paused:
                    pausedView
                case .shortBreak, .longBreak:
                    breakView
                }
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
            
            // モード選択タブ
            Picker("モード", selection: Binding(
                get: { timerManager.mode },
                set: { newMode in
                    if timerManager.state == .idle {
                        timerManager.mode = newMode
                    }
                }
            )) {
                Text("通常タイマー").tag(TimerMode.normal)
                Text("ポモドーロ").tag(TimerMode.pomodoro)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if timerManager.mode == .pomodoro {
                pomodoroIdleView
            } else {
                normalIdleView
            }
        }
    }
    
    private var normalIdleView: some View {
        VStack(spacing: 24) {
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
    
    private var pomodoroIdleView: some View {
        VStack(spacing: 24) {
            // セッション情報
            VStack(spacing: 8) {
                HStack {
                    Text("今日のセッション")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(timerManager.todaySessionCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("累計セッション")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(timerManager.totalSessionCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
            // 設定表示
            VStack(spacing: 8) {
                HStack {
                    Text("作業時間")
                    Spacer()
                    Text("\(timerManager.pomodoroWorkMinutes)分")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("短い休憩")
                    Spacer()
                    Text("\(timerManager.pomodoroShortBreakMinutes)分")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("長い休憩")
                    Spacer()
                    Text("\(timerManager.pomodoroLongBreakMinutes)分")
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)
            .padding(.vertical, 8)
            
            VStack(spacing: 12) {
                Button(action: {
                    timerManager.startPomodoro()
                }) {
                    Text("ポモドーロ開始")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: {
                    showingSettings = true
                }) {
                    Text("設定")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
    
    private var runningView: some View {
        VStack(spacing: 24) {
            if timerManager.isPomodoroMode {
                pomodoroRunningView
            } else {
                normalRunningView
            }
        }
    }
    
    private var normalRunningView: some View {
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
    
    private var pomodoroRunningView: some View {
        VStack(spacing: 24) {
            Text("作業中")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(timerManager.formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
                .padding(.vertical)
            
            // セッション情報
            VStack(spacing: 8) {
                HStack {
                    Text("今日のセッション")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(timerManager.todaySessionCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
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
            Text(timerManager.currentStateDescription)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(timerManager.formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.secondary)
                .padding(.vertical)
            
            if timerManager.isPomodoroMode {
                VStack(spacing: 8) {
                    HStack {
                        Text("今日のセッション")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(timerManager.todaySessionCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            
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
    
    private var breakView: some View {
        VStack(spacing: 24) {
            Text(timerManager.currentStateDescription)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(timerManager.formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.blue)
                .padding(.vertical)
            
            // セッション情報
            VStack(spacing: 8) {
                HStack {
                    Text("今日のセッション")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(timerManager.todaySessionCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
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
    
    private var settingsView: some View {
        VStack(spacing: 24) {
            Text("ポモドーロ設定")
                .font(.title2)
                .fontWeight(.semibold)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 作業時間設定
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作業時間: \(timerManager.pomodoroWorkMinutes)分")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(timerManager.pomodoroWorkMinutes) },
                                set: { timerManager.pomodoroWorkMinutes = Int($0) }
                            ),
                            in: 5...60,
                            step: 5
                        )
                    }
                    
                    // 短い休憩設定
                    VStack(alignment: .leading, spacing: 8) {
                        Text("短い休憩: \(timerManager.pomodoroShortBreakMinutes)分")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(timerManager.pomodoroShortBreakMinutes) },
                                set: { timerManager.pomodoroShortBreakMinutes = Int($0) }
                            ),
                            in: 1...15,
                            step: 1
                        )
                    }
                    
                    // 長い休憩設定
                    VStack(alignment: .leading, spacing: 8) {
                        Text("長い休憩: \(timerManager.pomodoroLongBreakMinutes)分")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(timerManager.pomodoroLongBreakMinutes) },
                                set: { timerManager.pomodoroLongBreakMinutes = Int($0) }
                            ),
                            in: 10...30,
                            step: 5
                        )
                    }
                    
                    // 長い休憩までのセッション数
                    VStack(alignment: .leading, spacing: 8) {
                        Text("長い休憩までのセッション数: \(timerManager.sessionsUntilLongBreak)")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(timerManager.sessionsUntilLongBreak) },
                                set: { timerManager.sessionsUntilLongBreak = Int($0) }
                            ),
                            in: 2...8,
                            step: 1
                        )
                    }
                }
                .padding(.vertical)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    timerManager.savePomodoroSettings()
                    showingSettings = false
                }) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: {
                    showingSettings = false
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
