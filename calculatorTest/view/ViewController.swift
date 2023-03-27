//
//  ViewController.swift
//  calculatorTest
//
//  Created by 조웅희 on 2023/03/10.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    // conbine의.store(in: &cancellables) 와 비슷한기능이다 disposeBag 담아 두었다가 해당 변수가 deinit 타이밍에 dispose 하는 구조이다.
    // Observable의 메모리 누수 방지를 위한 자동 구독해지 기능이라고 생각하면 편할듯
    private let disposeBag = DisposeBag()
    
    private var activatedButton: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        bindViewModel()
    }
   
    
    func bindViewModel() {
        // displayText 과 self.resultLabel.text를 바인딩하는 코드
        // .bind : viewModel.displayText의 값이 변경될떄 마다 self.resultLabel.rx.text도 같은 값으로 변경됨 (rx란 UIkit컴포넌트에 Observable 구조체와 연결하게 해주는 역할)
        // .disposed: 바인드후 Disposable을 방출하는데 이걸 disposeBag 에 담아주는 역할 _ 메모리 자동 해지를 위해 (자동구독해지)
        viewModel.displayText
            .bind(to: self.resultLabel.rx.text)
            .disposed(by: disposeBag)
        
        // operation를 구독하는 기능
        // .subscribe: operation을 구독해 해당 값이 변경될때마다 클로저함수가 발생 onNext는 바뀐값을 인자로 받아서 클로저를 실행함 이외에도 onError 등등 있음
        viewModel.operation
            .subscribe(onNext:{ [weak self] value in
                guard let _self = self else{ return }
                _self.operationButtonToggle(new: false,value: _self.activatedButton)
                _self.operationButtonToggle(new: true,value: value)
            })
            .disposed(by: disposeBag)
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
        viewModel.numberButtonTapped.accept(number)
    }
    
    // 즉발성 부호 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func operationButtonTouch(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }
        viewModel.operationButtonTapped.accept(operation)
    }
    
    // 연산자 부호 버튼이 눌렸을 때 호출되는 엑션이벤트
    @IBAction func arithmeticButtonTouch(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }
        viewModel.operationButtonTapped.accept(operation)
    }
}
