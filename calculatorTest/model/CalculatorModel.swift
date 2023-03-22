//
//  CalculatorModel.swift
//  calculatorTest
//
//  Created by 조웅희 on 2023/03/17.
//

import Foundation

// 계산기 모델 구조체
struct Calculator {
    var firstOperand: Double = 0
    var secondOperand: Double = 0
    var operation: String = ""
    
    // 피연산자 설정 함수
    mutating func setOperand(operand: Double, calculateResult: Bool) {
        if calculateResult {
            secondOperand = operand
        } else {
            firstOperand = operand
        }
    }
    
    // 연산자 설정 함수
    mutating func setOperation(operation: String) {
        self.operation = operation
    }
    
    // 계산 함수
    func calculate() -> Double? {
        switch operation {
        case "+":
            return firstOperand + secondOperand < 10 ? decimalCalculate() : firstOperand + secondOperand
            
        case "-":
            return firstOperand - secondOperand
        case "×":
            return firstOperand * secondOperand
        case "÷":
            if secondOperand == Double.zero {
                return nil
            }
            return firstOperand / secondOperand
        default:
            return nil
        }
    }
    
    private func decimalCalculate() -> Double {
        return NSDecimalNumber(value: firstOperand).adding(NSDecimalNumber(value: secondOperand)).doubleValue
    }
}
