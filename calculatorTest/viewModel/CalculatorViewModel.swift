import Foundation
// 계산기 뷰 모델 클래스
class CalculatorViewModel: NSObject {
    @objc dynamic var displayText: String = "0" // 화면에 표시할 텍스트
    
    private var calculator = Calculator() // Calculator 모델 인스턴스
    
    // 숫자 입력 함수
    func inputNumber(number: String) {
        if displayText == "0" {
            displayText = number
        } else {
            displayText += number
        }
    }
    
    // 연산자 입력 함수
    func inputOperation(operation: String) {
        calculator.setOperand(operand: Double(displayText)!)
        calculator.setOperation(operation: operation)
        displayText = "0"
    }
    
    // 결과 계산 함수
    func calculateResult() {
        guard let result = calculator.calculate() else { return }
        displayText = String(result)
    }
    
    // 기타 필요한 함수들을 작성합니다.
}
