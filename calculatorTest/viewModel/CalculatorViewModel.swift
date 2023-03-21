import Foundation
// 계산기 뷰 모델 클래스
class CalculatorViewModel: NSObject {
    
    @objc dynamic var displayText: String = "0" // 화면에 표시할 텍스트
    @objc dynamic var operation: String = ""
    private var isPerformingOperation: Bool = false
    private var hasDecimalPoint: Bool = false
    private var errorState: Bool = false
    private var calculator = Calculator() // Calculator 모델 인스턴스
    
    // 숫자 입력 함수
    func inputNumber(number: String) {
        if isPerformingOperation || errorState {
            displayText = number
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = false
        } else if displayText.count < 9 {
            if displayText == "0" {
                displayText.removeAll()
            }
            displayText += number
        }
    }
    
    // 연산자 입력 함수
    func inputOperation(operation: String) {
        guard !errorState || operation == "C" else { return }
        
        switch operation {
        case "+", "-", "×", "÷":
            if !calculator.firstOperand.isZero && !calculator.operation.isEmpty {
                self.calculateResult()
                guard !errorState else { return }
            }
            
            calculator.setOperand(operand: Double(displayText)! ,calculateResult: false)
            calculator.setOperation(operation: operation)
            self.operation = calculator.operation
            isPerformingOperation = true
        case "C":
            // 초기화 버튼 - 모든 값을 초기화
            displayText = "0"
            self.calculatorPropertyInitialization()
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = false
        case "+/-":
            // 부호 변경 버튼
            let value = Double(displayText)!
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                displayText = String(format: "%.0f", -value)
                
            } else {
                displayText = String(-value)
            }
        case "%":
            let value = Double(displayText)!
            let lastValue = value / 100.0
            
            if  lastValue.truncatingRemainder(dividingBy: 1) == 0 {
                displayText = String(format: "%.0f", lastValue)
                hasDecimalPoint = false
            } else {
                displayText = String(lastValue)
                hasDecimalPoint = true
            }
        case ".":
            if isPerformingOperation {
                displayText = "0."
                isPerformingOperation = false
            } else if displayText.count < 9 && !hasDecimalPoint {
                displayText += "."
            }
            
            hasDecimalPoint = true
        case "=":
            self.calculateResult()
        default:
            print("잘못된 버튼입니다.")
        }
    }
    
    // 결과 계산 함수
    func calculateResult() {
        guard !calculator.operation.isEmpty else { return }
        
        calculator.setOperand(operand: Double(displayText)! ,calculateResult: true)
        
        if let result = calculator.calculate() {
            guard result.isFinite else { return self.stateError() }
            
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                displayText = String(format: "%.0f", result)
            } else {
                displayText = String(result)
            }
            
            self.calculatorPropertyInitialization()
            isPerformingOperation = true
            
        } else {
            self.stateError()
        }
        
    }
    
    private func calculatorPropertyInitialization() {
        calculator.firstOperand = 0
        calculator.secondOperand = 0
        calculator.operation = ""
        self.operation = calculator.operation
    }
    
    private func stateError() {
        displayText = "Error"
        self.calculatorPropertyInitialization()
        isPerformingOperation = false
        hasDecimalPoint = false
        errorState = true
    }
}
