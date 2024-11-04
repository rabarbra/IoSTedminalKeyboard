import UIKit

var bck = 0
var frw = 0

var direction = 0
var oldDir = -1
var pos = 0



let controlSequences: [String] = [
    "\u{1b}OD", // Back
    "\u{1b}OC", // Forward
    "\u{1b}OA", // Up
    "\u{1b}OB", // Down
]

class KeyboardViewController: UIInputViewController {

    private var ctrl: Bool = false
    private var shift: Bool = false
    private var spaceScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    func setupKeyboard() {
        let keyboardStackView = UIStackView()
        keyboardStackView.axis = .vertical
        keyboardStackView.alignment = .fill
        keyboardStackView.distribution = .fillEqually
        keyboardStackView.spacing = 5
        keyboardStackView.translatesAutoresizingMaskIntoConstraints = false

        let buttonTitles = [
            ["ESC", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "+"],
            ["TAB", "A", "S", "D", "F", "G", "H", "J", "K", "L", ":", "\\"],
            ["Shift", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "["],
            ["Ctrl", "Alt", "Up", "Down", "<==", "Del", "Return"],
        ]

        for row in buttonTitles {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 5

            for title in row {
                let button = UIButton(type: .system)
                button.setTitleColor(.white, for: .normal)
                button.setTitle(title, for: .normal)
                button.backgroundColor = .darkGray
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(keyReleased(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchDown)
                rowStackView.addArrangedSubview(button)
            }

            keyboardStackView.addArrangedSubview(rowStackView)
        }
        // Space
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        rowStackView.distribution = .fillEqually
        let spaceButton = UIButton(type: .system)
        spaceButton.setTitle(" ", for: .normal)
        spaceButton.backgroundColor = .darkGray
        spaceButton.layer.cornerRadius = 5
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        spaceButton.addGestureRecognizer(panGesture)
        spaceButton.addTarget(self, action: #selector(handleSpace(_:)), for: .touchUpInside)
        // Add the space button to the view
        self.view.addSubview(spaceButton)
        rowStackView.addArrangedSubview(spaceButton)
        keyboardStackView.addArrangedSubview(rowStackView)

        self.view.addSubview(keyboardStackView)

        NSLayoutConstraint.activate([
            keyboardStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            keyboardStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            keyboardStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            keyboardStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc func handleSpace(_: UIButton) {
        if !self.spaceScroll {
            self.textDocumentProxy.insertText(" ")
        }
        self.spaceScroll = false
    }
    
    func endControl(){
        if direction != -1 && pos > 0 {
            while pos < 3 {
                self.textDocumentProxy.insertText("\(controlSequences[direction][String.Index(encodedOffset: pos)])")
                pos += 1
            }
        }
        pos = 0
    }
    
    func processControl(){
        var dir = direction
        if oldDir >= 0 {
            dir = oldDir
        }
        self.textDocumentProxy.insertText("\(controlSequences[dir][String.Index(encodedOffset: pos)])")
        pos += 1
        if pos == 3 {
            oldDir = -1
            pos = 0
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        switch gesture.state {
        case .began:
            print("Begin \(translation)")
            self.spaceScroll = true
        case .changed:
            self.spaceScroll = true
            if translation.x > 0 && direction != 1 {
                print("changed", direction, 1, "pos: ", pos)
//                self.endControl()
                oldDir = direction
                direction = 1
            } else if translation.x < 0 && direction != 0 {
                print("changed", direction, 0, "pos: ", pos)
//                self.endControl()
                oldDir = direction
                direction = 0
            } else {
                print("moved", direction, "pos: ", pos)
            }
            self.processControl()
        case .ended:
            print("End", "pos: ", pos)
            self.endControl()
            oldDir = -1
            direction = -1
        default:
            break
        }
    }

    @objc func keyPressed(_ sender: UIButton) {
        guard let keyTitle = sender.titleLabel?.text else { return }
        switch keyTitle {
        case "TAB":
            self.textDocumentProxy.insertText("\t")
        case "ESC":
            self.textDocumentProxy.insertText("\u{1B}")
        case "Return":
            self.textDocumentProxy.insertText("\n")
        case "Del":
            self.textDocumentProxy.insertText("\u{007F}")
        case "Shift":
            return
        case "Ctrl":
            self.ctrl = true
        case "<==":
            self.textDocumentProxy.insertText("\u{08}")
        case "Up":
            return
        case "Down":
            return
        case " ":
            return
        default:
            self.handleKey(key: keyTitle)
        }
    }
    
    @objc func keyReleased(_ sender: UIButton) {
        guard let keyTitle = sender.titleLabel?.text else { return }
        switch keyTitle {
        case "Shift":
            self.shift = !self.shift
        case "Ctrl":
            self.ctrl = false
        default:
            return
        }
    }
    
    func handleKey(key: String) {
        if self.shift {
            self.textDocumentProxy.insertText(key.uppercased())
        } else if self.ctrl {
            switch key {
            case "A":
                self.textDocumentProxy.insertText("\u{0001}")
            case "B":
                self.textDocumentProxy.insertText("\u{0002}")
            case "C":
                self.textDocumentProxy.insertText("\u{0003}")
            case "D":
                self.textDocumentProxy.insertText("\u{0004}")
            case "E":
                self.textDocumentProxy.insertText("\u{0005}")
            case "F":
                self.textDocumentProxy.insertText("\u{0006}")
            case "G":
                self.textDocumentProxy.insertText("\u{0007}")
            case "H":
                self.textDocumentProxy.insertText("\u{0008}")
            case "I":
                self.textDocumentProxy.insertText("\u{0009}")
            case "J":
                self.textDocumentProxy.insertText("\u{000A}")
            case "K":
                self.textDocumentProxy.insertText("\u{000B}")
            case "L":
                self.textDocumentProxy.insertText("\u{000C}")
            case "M":
                self.textDocumentProxy.insertText("\u{000D}")
            case "N":
                self.textDocumentProxy.insertText("\u{000E}")
            case "O":
                self.textDocumentProxy.insertText("\u{000F}")
            case "P":
                self.textDocumentProxy.insertText("\u{0010}")
            case "Q":
                self.textDocumentProxy.insertText("\u{0011}")
            case "R":
                self.textDocumentProxy.insertText("\u{0012}")
            case "S":
                self.textDocumentProxy.insertText("\u{0013}")
            case "T":
                self.textDocumentProxy.insertText("\u{0014}")
            case "U":
                self.textDocumentProxy.insertText("\u{0015}")
            case "V":
                self.textDocumentProxy.insertText("\u{0016}")
            case "W":
                self.textDocumentProxy.insertText("\u{0017}")
            case "X":
                self.textDocumentProxy.insertText("\u{0018}")
            case "Y":
                self.textDocumentProxy.insertText("\u{0019}")
            case "Z":
                self.textDocumentProxy.insertText("\u{001A}")
            default:
                self.textDocumentProxy.insertText(key.lowercased())
            }
        } else {
            self.textDocumentProxy.insertText(key.lowercased())
        }
    }
}
