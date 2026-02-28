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
                VStack(spacing: AppSpacing.l) {
                    functionHeader
                    
                    parametersSection
                    
                    actionButtons
                    
                    if showResult {
                        resultSection
                    }
                }
                .padding(AppSpacing.m)
            }
            .background(AppColors.background)
            .navigationTitle("Function Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.cancel()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.error)
                }
            }
        }
    }
    
    private var functionHeader: some View {
        VStack(spacing: AppSpacing.m) {
            Image(systemName: "function")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.primary)
            
            Text(functionCall.name)
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(functionCall.status.rawValue.capitalized)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, AppSpacing.m)
    }
    
    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("Parameters")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if functionCall.parameters.isEmpty {
                Text("No parameters")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, AppSpacing.s)
            } else {
                VStack(spacing: AppSpacing.s) {
                    ForEach(Array(functionCall.parameters.keys.sorted()), id: \.self) { key in
                        if let value = functionCall.parameters[key] {
                            ParameterRow(key: key, value: value)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.m)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.medium)
    }
    
    private var actionButtons: some View {
        HStack(spacing: AppSpacing.m) {
            Button {
                viewModel.cancel()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("Cancel")
                }
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.m)
                .background(AppColors.error)
                .foregroundColor(.white)
                .cornerRadius(AppCornerRadius.medium)
            }
            
            Button {
                viewModel.execute()
                withAnimation(AppAnimation.standard) {
                    showResult = true
                }
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Execute")
                }
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.m)
                .background(viewModel.isExecuting ? AppColors.textTertiary : AppColors.connected)
                .foregroundColor(.white)
                .cornerRadius(AppCornerRadius.medium)
            }
            .disabled(viewModel.isExecuting)
        }
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            HStack {
                Text("Result")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    copyResultToClipboard()
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy")
                    }
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.primary)
                }
            }
            
            if viewModel.isExecuting {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textSecondary))
                    Text("Executing...")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, AppSpacing.l)
            } else if let result = viewModel.result {
                Text(result)
                    .font(AppTypography.monospace)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.m)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.small)
            } else if let error = viewModel.error {
                Text(error)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.m)
                    .background(AppColors.error.opacity(0.1))
                    .cornerRadius(AppCornerRadius.small)
            }
        }
        .padding(AppSpacing.m)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.medium)
    }
    
    private var statusColor: Color {
        switch functionCall.status {
        case .pending:
            return AppColors.warning
        case .executing:
            return AppColors.primary
        case .success:
            return AppColors.connected
        case .error:
            return AppColors.error
        case .cancelled:
            return AppColors.textTertiary
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
        HStack(alignment: .top, spacing: AppSpacing.m) {
            Text(key)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(parameterValue)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, AppSpacing.xs)
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

#Preview {
    FunctionCallView(
        functionCall: FunctionCall(
            id: "1",
            name: "sendMessage",
            parameters: ["to": AnyCodable("John"), "message": AnyCodable("Hello!")],
            status: .pending
        ),
        viewModel: FunctionCallViewModel(functionCall: FunctionCall(
            id: "1",
            name: "sendMessage",
            parameters: [:],
            status: .pending
        ))
    )
}
