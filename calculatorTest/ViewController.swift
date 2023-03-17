//
//  ViewController.swift
//  calculatorTest
//
//  Created by 조웅희 on 2023/03/10.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var percentButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var decimalButton: UIButton!
    @IBOutlet weak var resultButton: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var firstOperand: Double = 0
    var secondOperand: Double = 0
    var sum: Double = 0
    var operation: String = ""
    var isPerformingOperation: Bool = false
    var hasDecimalPoint: Bool = false
    var errorState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
    }
    
    // 버튼 디자인 설정 함수
    func setButton() {
        let buttonList:[UIButton] = [clearButton,
                                  negativeButton,
                                  percentButton,
                                  divideButton,
                                  sevenButton,
                                  eightButton,
                                  nineButton,
                                  multiplyButton,
                                  fourButton,
                                  fiveButton,
                                  sixButton,
                                  minusButton,
                                  oneButton,
                                  twoButton,
                                  threeButton,
                                  plusButton,
                                  zeroButton,
                                  decimalButton,
                                  resultButton]
        
        for button in buttonList {
            if button.title(for: .normal) == "0"  {
                button.layer.cornerRadius = button.frame.size.width / 4
                continue
            }
            button.layer.cornerRadius = button.frame.size.width / 2
            button.clipsToBounds = true
        }
    }

    // 숫자 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func numberTouch(_ sender: UIButton) {
        guard let number = sender.currentTitle else { return }
                
        if isPerformingOperation || errorState {
            resultLabel.text = number
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = false
        } else if (resultLabel.text?.count)! < 9 {
            if resultLabel.text == "0" {
                resultLabel.text?.removeAll()
            }
            
            resultLabel.text = resultLabel.text! + number
        }
    }
    
    // 즉발성 부호 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func operationButtonTouch(_ sender: UIButton) {
        
        // 눌린 버튼의 타이틀 가져오기
        let buttonTitle = sender.title(for: .normal)!
        guard !errorState || buttonTitle == "C" else {
            return
        }
        
        // 눌린 버튼에 따라 계산 수행
        switch buttonTitle {
        case "C":
            // 초기화 버튼 - 모든 값을 초기화
            resultLabel.text = "0"
            firstOperand = 0
            secondOperand = 0
            operation = ""
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = false
            
        case "+/-":
            // 부호 변경 버튼
            let value = Double(resultLabel.text!)!
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                resultLabel.text = String(format: "%.0f", -value)
                
            } else {
                resultLabel.text = String(-value)
            }
            
        case "%":
            let value = Double(resultLabel.text!)!
            let lastValue = value / 100.0
            
            if  lastValue.truncatingRemainder(dividingBy: 1) == 0 {
                resultLabel.text = String(format: "%.0f", lastValue)
                hasDecimalPoint = false
            } else {
                resultLabel.text = String(lastValue)
                hasDecimalPoint = true
            }
            
        case "=":
            equalsCalculation()
        case ".":
            
            if isPerformingOperation {
                resultLabel.text = "0."
                isPerformingOperation = false
            } else if (resultLabel.text?.count)! < 9 && !hasDecimalPoint {
                resultLabel.text! += "."
            }
            
            hasDecimalPoint = true
        default:
            print("잘못된 버튼입니다.")
        }
    }
    
    // 계산 함수
    func equalsCalculation() {
        
        secondOperand = Double(resultLabel.text!)!
        sum = 0

        switch operation {
        case "+":
            sum = firstOperand + secondOperand
            if sum < 10 {
                let number1 = NSDecimalNumber(value: firstOperand)
                let number2 = NSDecimalNumber(value: secondOperand)
                var result: NSDecimalNumber
                result = number1.adding(number2)
                sum = result.doubleValue
            }
        case "-":
            sum = firstOperand - secondOperand
        case "×":
            sum = firstOperand * secondOperand
            
        case "÷":
            guard secondOperand != Double.zero else {
                resultLabel.text = "Error"
                firstOperand = 0
                secondOperand = 0
                operation = ""
                isPerformingOperation = false
                hasDecimalPoint = false
                errorState = true
                return
            }
            
            sum = firstOperand / secondOperand
        default:
            return
        }
        
        if !sum.isFinite {
            resultLabel.text = "Error"
            firstOperand = 0
            secondOperand = 0
            operation = ""
            isPerformingOperation = false
            hasDecimalPoint = false
            errorState = true
            return
        }
        
        if sum.truncatingRemainder(dividingBy: 1) == 0 {
            resultLabel.text = String(format: "%.0f", sum)
        } else {
            resultLabel.text = String(sum)
        }

        firstOperand = 0
        secondOperand = 0
        operation = ""
        isPerformingOperation = true
    }
    
    // 연산자 부호 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func arithmeticButtonTouch(_ sender: UIButton) {
        
        if !firstOperand.isZero && !operation.isEmpty && !errorState {
            equalsCalculation()
        }
        
        guard !errorState else {
            return
        }
        
        // 눌린 버튼의 타이틀 가져오기
        operation = sender.currentTitle!
        firstOperand = Double(resultLabel.text!)!
        isPerformingOperation = true
    }
}

