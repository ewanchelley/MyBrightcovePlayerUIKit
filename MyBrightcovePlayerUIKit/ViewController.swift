//
//  ViewController.swift
//  MyBrightcovePlayerUIKit
//
//  Created by Ewan Chelley on 23/12/2024.
//

import UIKit
import BrightcovePlayerSDK

let kViewControllerPlaybackServicePolicyKey = "BCpkADawqM0T8lW3nMChuAbrcunBBHmh4YkNl5e6ZrKQwPiK_Y83RAOF4DP5tyBF_ONBVgrEjqW6fbV0nKRuHvjRU3E8jdT9WMTOXfJODoPML6NUDCYTwTHxtNlr5YdyGYaCPLhMUZ3Xu61L"
let kViewControllerAccountID = "5434391461001"
let kViewControllerVideoID = "6140448705001"

let streamURLParkour = "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
let streamURLBBC = "https://vs-hls-push-uk-live.akamaized.net/x=4/i=urn:bbc:pips:service:bbc_one_london/mobile_wifi_main_sd_abr_v2.m3u8"

class ViewController: UIViewController, BCOVPlaybackControllerDelegate {
    
    let sharedSDKManager = BCOVPlayerSDKManager.sharedManager()
    let sessionProvider: BCOVPlaybackSessionProvider
    let playbackController: BCOVPlaybackController
    @IBOutlet weak var videoContainerView: UIView!
    
    private var currentTime: TimeInterval = 0
    
    required init?(coder aDecoder: NSCoder) {
        sessionProvider = sharedSDKManager.createBasicSessionProvider(withOptions: BCOVBasicSessionProviderOptions())
        playbackController = (sharedSDKManager.createPlaybackController(withSessionProvider: sessionProvider, viewStrategy: .none))
        
        super.init(coder: aDecoder)
        
        playbackController.analytics.account = kViewControllerAccountID // Optional
        
        playbackController.delegate = self
        playbackController.isAutoAdvance = true
        playbackController.isAutoPlay = true
    }
    
    @objc func handleJumpToStartImageTapped(sender: UITapGestureRecognizer) {
        Task {
            let newTime = CMTime(value: CMTimeValue(0), timescale: 1)
            await playbackController.seek(to: newTime)
        }
    }
    
    @objc func handleBack10ImageTapped(sender: UITapGestureRecognizer) {
        Task {
            let newTime = CMTime(value: CMTimeValue(currentTime - 10), timescale: 1)
            await playbackController.seek(to: newTime)
        }
    }
    
    @objc func handleForward10ImageTapped(sender: UITapGestureRecognizer) {
        Task {
            let newTime = CMTime(value: CMTimeValue(currentTime + 10), timescale: 1)
            await playbackController.seek(to: newTime)
        }
    }
    
    @objc func handleJumpLiveImageTapped(sender: UITapGestureRecognizer) {
        Task {
            let newTime = CMTime(value: CMTimeValue(5000), timescale: 1)
            await playbackController.seek(to: newTime)
        }
    }
    
    func playbackController(_ controller: (any BCOVPlaybackController)!, playbackSession session: (any BCOVPlaybackSession)!, didProgressTo progress: TimeInterval) {
        print("Progress: \(progress)")
        currentTime = progress
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controlsView = BCOVPUIBasicControlView.withLiveLayout()!

        let controls = [
            [
                createCurrentTimeLayoutView(),
                createScrubBarLayoutView()
            ],
            [
                createJumpToStartLayoutView(),
                createSeekBack10LayoutView(),
                createPlayPauseLayoutView(),
                createSeekForward10LayoutView(),
                createJumpLiveLayoutView()
            ]
        ]
        let customLayout = BCOVPUIControlLayout.init(standardControls: controls, compactControls: controls)
        controlsView.layout = customLayout
        
        // Set up our player view. Create with a standard VOD layout.
        guard let playerView = BCOVPUIPlayerView(playbackController: self.playbackController, options: nil, controlsView: .withLiveDVRLayout()) else {
            return
        }
        
        // Install in the container view and match its size.
        self.videoContainerView.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: self.videoContainerView.topAnchor),
            playerView.rightAnchor.constraint(equalTo: self.videoContainerView.rightAnchor),
            playerView.leftAnchor.constraint(equalTo: self.videoContainerView.leftAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.videoContainerView.bottomAnchor)
        ])
        
        // Associate the playerView with the playback controller.
        playerView.playbackController = playbackController
        requestContent()
    }
    
    func createCurrentTimeLayoutView() -> BCOVPUILayoutView {
        return BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.labelCurrentTime,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 0.0)
    }
    
    func createPlayPauseLayoutView() -> BCOVPUILayoutView {
        return BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.buttonPlayback,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 0.0)
    }
    
    func createScrubBarLayoutView() -> BCOVPUILayoutView {
        return BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.sliderProgress,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 1.0)
    }
    
    func createJumpToStartLayoutView() -> BCOVPUILayoutView {
        let layoutView = BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.viewEmpty,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 1.0
        )!
        
        let imageView = UIImageView(image: UIImage(systemName: "backward.end.alt.fill"))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleJumpToStartImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        // Add image view to our empty layout view.
        layoutView.addSubview(imageView)
        return layoutView
    }
    
    func createSeekBack10LayoutView() -> BCOVPUILayoutView {
        let layoutView = BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.viewEmpty,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 1.0
        )!
        
        let imageView = UIImageView(image: UIImage(systemName: "arrow.counterclockwise"))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBack10ImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        // Add image view to our empty layout view.
        layoutView.addSubview(imageView)
        return layoutView
    }
    
    func createSeekForward10LayoutView() -> BCOVPUILayoutView {
        let layoutView = BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.viewEmpty,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 1.0
        )!
        
        let imageView = UIImageView(image: UIImage(systemName: "arrow.clockwise"))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleForward10ImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        // Add image view to our empty layout view.
        layoutView.addSubview(imageView)
        return layoutView
    }
    
    func createJumpLiveLayoutView() -> BCOVPUILayoutView {
        let layoutView = BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.viewEmpty,
            width: kBCOVPUILayoutUseDefaultValue,
            elasticity: 1.0
        )!
        
        let imageView = UIImageView(image: UIImage(systemName: "forward.end.alt.fill"))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleJumpLiveImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        // Add image view to our empty layout view.
        layoutView.addSubview(imageView)
        return layoutView
    }
    
    func requestContent() {
        let videoURL = URL(string: streamURLBBC)
        let source = BCOVSource(withURL: videoURL)
        print("Source properties: \(source.properties)")
        let video = BCOVVideo(withSource: source, cuePoints: .none, properties: [BCOVVideo.PropertyKeyName:"BBC One"])
        
        let movieTitle = video.properties[BCOVVideo.PropertyKeyName] as? String ?? "<Title Unavailable>"
        print("Properties: \(video.properties)")
        self.playbackController.setVideos([video])
    }
}

