//
//  PreviewAudioView.swift
//  RocketChatViewController
//
//  Created by Matheus Cardoso on 11/01/2019.
//

import UIKit
import AVFoundation

public protocol PreviewAudioViewDelegate: class {
    func previewAudioView(_ view: PreviewAudioView, didConfirmAudio url: URL)
    func previewAudioView(_ view: PreviewAudioView, didDiscardAudio url: URL)
}

public class PreviewAudioView: UIView, ComposerLocalizable {
    public weak var composerView: ComposerView?
    public weak var delegate: PreviewAudioViewDelegate?

    public let audioView = tap(AudioView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    public let discardButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.addConstraints([
            $0.heightAnchor.constraint(equalToConstant: Consts.discardButtonHeight),
            $0.widthAnchor.constraint(equalToConstant: Consts.discardButtonWidth),
        ])

        $0.setBackgroundImage(ComposerAssets.discardButtonImage, for: .normal)
        $0.addTarget(self, action: #selector(touchUpInsideDiscardButton), for: .touchUpInside)
    }

    public let separatorView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = #colorLiteral(red: 0.7960784314, green: 0.8078431373, blue: 0.8196078431, alpha: 1)

        $0.addConstraints([
            $0.heightAnchor.constraint(equalToConstant: Consts.separatorViewHeight),
            $0.widthAnchor.constraint(equalToConstant: Consts.separatorViewWidth),
        ])
    }

    public let sendButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.addConstraints([
            $0.heightAnchor.constraint(equalToConstant: Consts.discardButtonHeight),
            $0.widthAnchor.constraint(equalToConstant: Consts.discardButtonWidth),
        ])

        $0.setBackgroundImage(ComposerAssets.sendButtonImage, for: .normal)
        $0.addTarget(self, action: #selector(touchUpInsideSendButton), for: .touchUpInside)
    }

    public var player: AVAudioPlayer?
    public var timer: Timer?
    public var url: URL?

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let transformX = frame.width - (Consts.sendButtonWidth +
                         Consts.sendButtonLeading +
                         Consts.sendButtonTrailing +
                         Consts.separatorViewWidth +
                         Consts.separatorViewLeading +
                         Consts.discardButtonWidth +
                         Consts.discardButtonLeading)

        audioView.transform = CGAffineTransform(translationX: transformX, y: 0)

        sendButton.alpha = 0
        separatorView.alpha = 0
        discardButton.alpha = 0

        UIView.animate(withDuration: 0.25) {
            self.audioView.transform = CGAffineTransform(translationX: 0, y: 0)

            self.sendButton.alpha = 1
            self.separatorView.alpha = 1
            self.discardButton.alpha = 1
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        backgroundColor = .white
        clipsToBounds = true

        timer = .scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(timerTick),
            userInfo: nil,
            repeats: true
        )

        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })

        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(audioView)
        addSubview(discardButton)
        addSubview(separatorView)
        addSubview(sendButton)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            audioView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Consts.audioViewLeading),
            audioView.topAnchor.constraint(equalTo: topAnchor, constant: Consts.audioViewTop),
            audioView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Consts.audioViewBottom),

            discardButton.leadingAnchor.constraint(equalTo: audioView.trailingAnchor, constant: Consts.discardButtonLeading),
            discardButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            separatorView.leadingAnchor.constraint(equalTo: discardButton.trailingAnchor, constant: Consts.separatorViewLeading),
            separatorView.centerYAnchor.constraint(equalTo: centerYAnchor),

            sendButton.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: Consts.sendButtonLeading),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Consts.sendButtonTrailing),
            sendButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    /**
     Starts playing
     */
    func startPlaying() {

    }

    /**
     Stops playing
     */
    func stopPlaying() {

    }

    struct Consts {
        static let audioViewLeading: CGFloat = 10
        static let audioViewTop: CGFloat = 6
        static let audioViewBottom: CGFloat = -6

        static let discardButtonLeading: CGFloat = 20
        static let discardButtonHeight: CGFloat = 20
        static let discardButtonWidth: CGFloat = 20

        static let separatorViewLeading: CGFloat = 20
        static let separatorViewHeight: CGFloat = 24
        static let separatorViewWidth: CGFloat = 1

        static let sendButtonLeading: CGFloat = 20
        static let sendButtonTrailing: CGFloat = -20
        static let sendButtonHeight: CGFloat = 24
        static let sendButtonWidth: CGFloat = 24
    }
}

// MARK: Events

extension PreviewAudioView {
    @objc func timerTick() {
        // time += 0.5
    }

    @objc func touchUpInsideDiscardButton() {
        guard let url = url else {
            return
        }

        delegate?.previewAudioView(self, didDiscardAudio: url)
    }

    @objc func touchUpInsideSendButton() {
        guard let url = url else {
            return
        }

        delegate?.previewAudioView(self, didConfirmAudio: url)
    }
}

// MARK: SwipeIndicatorView

public class AudioView: UIView {
    public let playButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(ComposerAssets.playButtonImage, for: .normal)

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: Consts.playButtonWidth),
            $0.heightAnchor.constraint(equalToConstant: Consts.playButtonHeight)
        ])
    }

    public let progressSlider = tap(UISlider()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.value = 0
        $0.setThumbImage(ComposerAssets.sliderThumbImage, for: .normal)
    }

    public let timeLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = "0:00"
        $0.font = UIFont.systemFont(ofSize: Consts.timeLabelFontSize)
        $0.textColor = #colorLiteral(red: 0.3294117647, green: 0.3450980392, blue: 0.368627451, alpha: 1)
        $0.adjustsFontForContentSizeCategory = true

        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9803921569, alpha: 1)
        layer.cornerRadius = Consts.layerCornerRadius
        clipsToBounds = true

        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })

        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(playButton)
        addSubview(progressSlider)
        addSubview(timeLabel)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Consts.playButtonLeading),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            progressSlider.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: Consts.progressSliderLeading),
            progressSlider.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: Consts.progressSliderTrailing),
            progressSlider.centerYAnchor.constraint(equalTo: centerYAnchor),

            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Consts.timeLabelTrailing),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    struct Consts {
        static let layerCornerRadius: CGFloat = 4

        static let playButtonWidth: CGFloat = 24
        static let playButtonHeight: CGFloat = 24
        static let playButtonLeading: CGFloat = 10

        static let progressSliderLeading: CGFloat = 10
        static let progressSliderTrailing: CGFloat = -15

        static let timeLabelTrailing: CGFloat = -15
        static let timeLabelFontSize: CGFloat = 14
    }
}
