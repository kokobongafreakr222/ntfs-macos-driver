import SwiftUI

struct SetupView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    let steps = [
        SetupStep(
            title: "Добро пожаловать",
            description: "NTFS Driver позволяет читать и записывать файлы на NTFS диски на macOS.",
            icon: "externaldrive.badge.plus",
            action: nil
        ),
        SetupStep(
            title: "Установка macFUSE",
            description: "1. Скачайте macFUSE с https://osxfuse.github.io/\n2. Откройте .dmg и запустите установщик\n3. Перезагрузите Mac после установки",
            icon: "arrow.down.circle",
            action: "Открыть сайт macFUSE"
        ),
        SetupStep(
            title: "Готово",
            description: "После установки macFUSE приложение будет автоматически работать с NTFS дисками.",
            icon: "checkmark.circle",
            action: nil
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: steps[currentStep].icon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(steps[currentStep].title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(steps[currentStep].description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            if let action = steps[currentStep].action {
                Button(action: {
                    if action.contains("macFUSE") {
                        NSWorkspace.shared.open(URL(string: "https://osxfuse.github.io/")!)
                    }
                }) {
                    Label(action, systemImage: "arrow.up.forward")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button("Назад") {
                        currentStep -= 1
                    }
                }
                
                Button(currentStep == steps.count - 1 ? "Готово" : "Далее") {
                    if currentStep == steps.count - 1 {
                        isPresented = false
                    } else {
                        currentStep += 1
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 400)
    }
}

struct SetupStep {
    let title: String
    let description: String
    let icon: String
    let action: String?
}
