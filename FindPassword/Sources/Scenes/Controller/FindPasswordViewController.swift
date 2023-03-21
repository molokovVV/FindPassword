//
//  ViewController.swift
//  FindPassword
//
//  Created by Виталик Молоков on 12.03.2023.
//

import UIKit

class FindPasswordViewController: UIViewController {
    
    //MARK: - Properties
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
                findPasswordLabel.textColor = .white
                backgroundButton.tintColor = .white
                passwordButton.tintColor = .white
                stopSearchButton.tintColor = .white
                activityIndicator.color = .white
            } else {
                self.view.backgroundColor = .white
                findPasswordLabel.textColor = .black
                backgroundButton.tintColor = .black
                passwordButton.tintColor = .black
                stopSearchButton.tintColor = .black
                activityIndicator.color = .black
            }
        }
    }
    
    var timerForShadowOfPassword = Timer()
    
    //MARK: - UI Elements
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.boldSystemFont(ofSize: 25)
        textField.textAlignment = .center
        textField.tintColor = .black
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var findPasswordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private lazy var backgroundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Background", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(buttonBackgroundStarted), for: .touchUpInside)
        return button
    }()
    
    private lazy var passwordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Password", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(buttonFindPasswordStarted), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop Search", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        return indicator
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        setupHideKeyboard()
    }
    
    //MARK: - Setups
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubview(passwordTextField)
        view.addSubview(findPasswordLabel)
        view.addSubview(passwordButton)
        view.addSubview(backgroundButton)
        view.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(view).offset(300)
            make.centerX.equalTo(view)
            make.width.equalTo(100)
        }
        
        findPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField).offset(50)
            make.centerX.equalTo(view)
        }
        
        passwordButton.snp.makeConstraints { make in
            make.top.equalTo(findPasswordLabel).offset(100)
            make.centerX.equalTo(view)
        }
        
        backgroundButton.snp.makeConstraints { make in
            make.top.equalTo(passwordButton).offset(150)
            make.centerX.equalTo(view)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(findPasswordLabel).offset(50)
            make.centerX.equalTo(view)
        }
    }
    
    private func setupHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func bruteForce(passwordToUnlock: String) {
        
        let ALLOWED_CHARACTERS: [String] = String().letters.map { String($0) }
        
        var password: String = ""
        
        while password != passwordToUnlock {
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            print(password)
            DispatchQueue.main.async {
                self.findPasswordLabel.text = password
                
                if password == passwordToUnlock {
                    self.activityIndicator.stopAnimating()
                    self.passwordTextField.isSecureTextEntry = false
                }
            }
        }
    }
    
    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }
    
    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
        : Character("")
    }
    
    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string
        
        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
            
            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }
        
        return str
    }
    

    
    //MARK: - Actions
    
    @objc private func buttonBackgroundStarted() {
        isBlack.toggle()
    }
    
    @objc private func buttonFindPasswordStarted() {
        DispatchQueue.main.async { [self] in
            let password = passwordTextField.text ?? ""
            
            activityIndicator.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.bruteForce(passwordToUnlock: password)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Hiding the password in a TextField
        timerForShadowOfPassword.invalidate()
        timerForShadowOfPassword = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (_) in
            textField.isSecureTextEntry = true
        })
        textField.isSecureTextEntry = false
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}

extension FindPasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Character limit
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let newLength = newString.length
        
        // Character type limit
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let characterSet = CharacterSet(charactersIn: string)
        
        return newLength <= maxLength && allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordTextField.becomeFirstResponder()
    }
}


