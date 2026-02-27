import SwiftUI

struct FunctionCallView: View {
    let functionCall: FunctionCall
    @ObservedObject var viewModel: FunctionCallViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showResult: Bool = false
    @State private var copied: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    functionHeader
                    
                    parametersSection
                    
                    actionButtons
                    
                    if showResult {
                        resultSection
                    }
                }
                .padding(16)
            }
            .navigationTitle("Function Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.cancel()
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "FF3B30"))
                }
            }
        }
    }
    
    private var functionHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "function")
                .font(.system(size: 40))
                .foregroundStyle(Color(hex: "007AFF"))
            
            Text(functionCall.name)
                .font(.system(size: 20, weight: .semibold))
            
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(functionCall.status.rawValue.capitalized)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 16)
    }
    
    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parameters")
                .font(.system(size: 17, weight: .semibold))
            
            if functionCall.parameters.isEmpty {
                Text("No parameters")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(functionCall.parameters.keys.sorted()), id: \.self) { key in
                        if let value = functionCall.parameters[key] {
                            ParameterRow(key: key, value: value)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "F2F2F7").opacity(0.5))
        )
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.cancel()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("Cancel")
                }
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "FF3B30"))
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            
            Button {
                viewModel.execute()
                withAnimation {
                    showResult = true
                }
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Execute")
                }
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.isExecuting ? Color.gray : Color(hex: "34C759"))
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isExecuting)
        }
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Result")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                Button {
                    copyResultToClipboard()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "007AFF"))
                }
            }
            
            if viewModel.isExecuting {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Executing...")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else if let result = viewModel.result {
                Text(result)
                    .font(.system(size: 15, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "1C1C1E").opacity(0.1))
                    )
            } else if let error = viewModel.error {
                Text(error)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "FF3B30"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "FF3B30").opacity(0.1))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "F2F2F7").opacity(0.5))
        )
    }
    
    private var statusColor: Color {
        switch functionCall.status {
        case .pending:
            return Color(hex: "FFC107")
        case .executing:
            return Color(hex: "007AFF")
        case .success:
            return Color(hex: "34C759")
        case .error:
            return Color(hex: "FF3B30")
        case .cancelled:
            return Color(hex: "8E8E93")
        }
    }
    
    private func copyResultToClipboard() {
        if let result = viewModel.result {
            UIPasteboard.general.string = result
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                copied = false
            }
        }
    }
}

struct ParameterRow: View {
    let key: String
    let value: AnyCodable
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(key)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(hex: "5856D6"))
                .frame(width: 100, alignment: .leading)
            
            Text(parameterValue)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
    
    private var parameterValue: String {
        let val = value.value
        if let stringValue = val as? String {
            return "\"\(stringValue)\""
        } else if let intValue = val as? Int {
            return String(intValue)
        } else if let doubleValue = val as? Double {
            return String(doubleValue)
        } else if let boolValue = val as? Bool {
            return boolValue ? "true" : "false"
        } else if let dictValue = val as? [String: Any] {
            return formatDictionary(dictValue)
        } else if let arrayValue = val as? [Any] {
            return formatArray(arrayValue)
        } else if val is NSNull {
            return "null"
        }
        return String(describing: val)
    }
    
    private func formatDictionary(_ dict: [String: Any]) -> String {
        let pairs = dict.map { key, value in
            "\(key): \(String(describing: value))"
        }
        return "{\(pairs.joined(separator: ", "))}"
    }
    
    private func formatArray(_ array: [Any]) -> String {
        let items = array.map { String(describing: $0) }
        return "[\(items.joined(separator: ", "))]"
    }
}

class FunctionCallViewModel: ObservableObject {
    @Published var isExecuting: Bool = false
    @Published var result: String?
    @Published var error: String?
    
    private let functionCall: FunctionCall
    private let onExecute: ((FunctionCall) -> Void)?
    private let onCancel: ((FunctionCall) -> Void)?
    
    init(functionCall: FunctionCall, onExecute: ((FunctionCall) -> Void)? = nil, onCancel: ((FunctionCall) -> Void)? = nil) {
        self.functionCall = functionCall
        self.onExecute = onExecute
        self.onCancel = onCancel
    }
    
    func execute() {
        isExecuting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.isExecuting = false
            self.result = "Function '\(self.functionCall.name)' executed successfully"
            self.onExecute?(self.functionCall)
        }
    }
    
    func cancel() {
        isExecuting = false
        error = "Execution cancelled by user"
        onCancel?(functionCall)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    FunctionCallView(
        functionCall: FunctionCall(
            id: "123",
            name: "example_function",
            parameters: ["param1": AnyCodable("value1"), "param2": AnyCodable(42)]
        ),
        viewModel: FunctionCallViewModel(
            functionCall: FunctionCall(id: "123", name: "test", parameters: [:])
        )
    )
}
