import Foundation
import RxSwift
import RxCocoa

class CalculatorViewModel {
    //1.BehaviorRelay:
    //BehaviorRelay는 RxCocoa 라이브러리에 포함된 클래스로, 에러 및 완료 이벤트를 방출하지 않습니다. 대신에 가장 최근의 이벤트를 저장하고 새 구독자에게 방출해줍니다. 따라서 BehaviorRelay는 초기 값을 가지며, 언제든지 현재 값을 가져올 수 있습니다. 주로 UI 상태 관리에 사용됩니다.
    //2/PublishRelay:
    //PublishRelay는 역시 RxCocoa 라이브러리에 포함되어 있으며, 에러 및 완료 이벤트를 방출하지 않습니다. PublishRelay는 가장 최근의 값을 저장하지 않고, 구독 시점 이후에 발생하는 이벤트만 전달합니다. 따라서 PublishRelay는 초기 값을 가지지 않습니다.
    //3.PublishSubject:
    //PublishSubject는 RxSwift 라이브러리에 포함된 클래스로, 에러와 완료 이벤트를 처리할 수 있습니다. PublishSubject는 구독 이후에 발생하는 이벤트만 전달하며, 가장 최근의 값을 저장하지 않습니다. 초기 값을 가지지 않고, 주로 다양한 이벤트를 처리할 때 사용됩니다.
    //4.BehaviorSubject:
    //BehaviorSubject는 RxSwift 라이브러리에 포함되어 있으며, 에러와 완료 이벤트를 처리할 수 있습니다. BehaviorSubject는 가장 최근의 값을 저장하고 새 구독자에게 전달합니다. 초기 값을 가지며, 주로 초기 값이 필요한 상태 관리에 사용됩니다.
    
    // 위의 4개이외에도 더 다양하게 많다 우선은 이 정도만 정리하고 나중에 싹 모아서 정리릃 해볼까한다 우선은 노션에 올려둔 'RxSwift기초' 을 참고하도록하자
    var displayText = BehaviorRelay<String>(value: "0")
    var operation = BehaviorRelay<String>(value: "")
    let numberButtonTapped = PublishRelay<String>()
    let operationButtonTapped = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    private var isPerformingOperation: Bool = false
    private var hasDecimalPoint: Bool = false
    private var errorState: Bool = false
    private var calculator = Calculator() // Calculator 모델 인스턴스
    
    init() {
        numberButtonTapped
            .subscribe(onNext: { [weak self] number in
                self?.inputNumber(number: number)
            })
            .disposed(by: disposeBag)

        operationButtonTapped
            .subscribe(onNext: { [weak self] operation in
                self?.inputOperation(operation: operation)
            })
            .disposed(by: disposeBag)
    }
    
    // 숫자 입력 함수
    private func inputNumber(number: String) {
        if isPerformingOperation || errorState {
            displayText.accept(number)
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = false
        } else if displayText.value.count < 9 {
            if displayText.value == "0" {
                displayText.accept(number)
            } else {
                displayText.accept(displayText.value + number)
            }
        }
    }
    
    // 연산자 입력 함수
    private func inputOperation(operation: String) {
        guard !errorState || operation == "C" else { return }
        
        switch operation {
        case "+", "-", "×", "÷":
            if !calculator.firstOperand.isZero && !calculator.operation.isEmpty {
                self.calculateResult()
                guard !errorState else { return }
            }
            
            calculator.setOperand(operand: Double(displayText.value)! ,calculateResult: false)
            calculator.setOperation(operation: operation)
            self.operation.accept(calculator.operation)
            isPerformingOperation = true
        case "C":
            // 초기화 버튼 - 모든 값을 초기화
            displayText.accept("0")
            self.calculatorPropertyInitialization()
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = false
        case "+/-":
            // 부호 변경 버튼
            let value = Double(displayText.value)!
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                displayText.accept(String(format: "%.0f", -value))
            } else {
                displayText.accept(String(-value))
            }
        case "%":
            let value = Double(displayText.value)!
            let lastValue = value / 100.0
            
            if  lastValue.truncatingRemainder(dividingBy: 1) == 0 {
                displayText.accept(String(format: "%.0f", lastValue))
                hasDecimalPoint = false
            } else {
                displayText.accept(String(lastValue))
                hasDecimalPoint = true
            }
        case ".":
            if isPerformingOperation {
                displayText.accept("0.")
                isPerformingOperation = false
            } else if displayText.value.count < 9 && !hasDecimalPoint {
                displayText.accept(displayText.value + ".")
            }
            
            hasDecimalPoint = true
        case "=":
            self.calculateResult()
        default:
            print("잘못된 버튼입니다.")
        }
    }
    
    // 결과 계산 함수
    private func calculateResult() {
        guard !calculator.operation.isEmpty else { return }
        
        calculator.setOperand(operand: Double(displayText.value)! ,calculateResult: true)
        
        if let result = calculator.calculate() {
            guard result.isFinite else { return self.stateError() }
            
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                displayText.accept(String(format: "%.0f", result))
            } else {
                displayText.accept(String(result))
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
        self.operation.accept(calculator.operation)
    }
    
    private func stateError() {
        displayText.accept("Error")
        self.calculatorPropertyInitialization()
        isPerformingOperation = false
        hasDecimalPoint = false
        errorState = true
    }
}
