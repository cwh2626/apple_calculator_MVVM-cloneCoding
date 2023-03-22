//
//  ViewController.swift
//  calculatorTest
//
//  Created by 조웅희 on 2023/03/10.
//

import UIKit
import Combine

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
    
    private var viewModel = CalculatorViewModel() // 뷰 모델 인스턴스
    // Published를 구독후에 반환되는 Cancellable을 저장하는 변수
    private var cancellables = Set<AnyCancellable>()
    // combine은 KVO처럼 과거의 값을 가져올수없기에 view단에서 따로 이전값을 설정
    private var activatedButton: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        
        // ViewModel의 displayText가 변경될 때마다 클로저 함수 발생
        // $displayText: 발행자(publisher)
        // .sink : 구독자(Subscriber)가 클로저형태로 발행자와 연결하는거
        // .store : 구독을 관리하는 Cancellable이라는 객체를 저장하는 느낌 이렇게 set이라는 변수에 저장하는 이유는
        //          저장하지않으면 즉시 구독이 취소되어 클로저가 실행이 안되기 떄문이다
        //          그래서 set객체가 수명이 다하면 자동으로 구독이 다 취소되는듯하다 나의 생각 ㅎ
        viewModel.$displayText
                    .sink { [weak self] value in
                        self?.resultLabel.text = value
                    }
                    .store(in: &cancellables)
        
        viewModel.$operation
                    .sink { [weak self] value in
                        guard let _self = self else{ return }
                        _self.operationButtonToggle(new: false,value: _self.activatedButton)
                        _self.operationButtonToggle(new: true,value: value)
                    }
                    .store(in: &cancellables)
    }
    
    
    /// 사칙연산버튼 터치시 컬러변경처리
    /// - Parameters:
    ///   - new: new,old구분토글
    ///   - value: 사칙연산
    func operationButtonToggle(new: Bool, value: String) {
        let red: CGFloat = 230
        let green: CGFloat = 148
        let blue: CGFloat = 42
        let alpha: CGFloat = 1.0
        // 사칙연산자버튼의 기본컬러 설정
        let buttonColor = UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
        
        var buttonItem: UIButton? = nil
        
        switch value {
        case "+" :
            buttonItem = self.plusButton
        case "-" :
            buttonItem = self.minusButton
        case "×" :
            buttonItem = self.multiplyButton
        case "÷" :
            buttonItem = self.divideButton
        default : break
        }
        
        guard let button = buttonItem else { return }

        UIView.animate(withDuration: 0.3) {
            if new {
                button.backgroundColor = .white
                button.setTitleColor(buttonColor, for: .normal)
                self.activatedButton = button.currentTitle!
            } else {
                button.backgroundColor = buttonColor
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
        
    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.7
        }
    }

    @objc func buttonTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
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
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)

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
        viewModel.inputNumber(number: number)
    }
    
    // 즉발성 부호 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func operationButtonTouch(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }
        viewModel.inputOperation(operation: operation)
    }
    
    // 연산자 부호 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func arithmeticButtonTouch(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }
        viewModel.inputOperation(operation: operation)
    }
}
