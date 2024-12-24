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
    //    let playbackService = BCOVPlaybackService(withAccountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
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
    
    @objc func handleImageTapped(sender: UITapGestureRecognizer) {
        Task {
            let newTime = CMTime(value: CMTimeValue(currentTime + 10), timescale: 1)
            print(newTime)
            await playbackController.seek(to: newTime)
        }
    }
    
    func playbackController(_ controller: (any BCOVPlaybackController)!, playbackSession session: (any BCOVPlaybackSession)!, didProgressTo progress: TimeInterval) {
        print(progress)
        currentTime = progress
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controlsView = BCOVPUIBasicControlView.withVODLayout()!

        let controls = [[createPlayPauseLayoutView(), createSeek10LayoutView(), createScrubBarLayoutView() ]]
        let customLayout = BCOVPUIControlLayout.init(standardControls: controls, compactControls: controls)
        controlsView.layout = customLayout
        
        // Set up our player view. Create with a standard VOD layout.
        guard let playerView = BCOVPUIPlayerView(playbackController: self.playbackController, options: nil, controlsView: controlsView) else {
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
    
    func createSeek10LayoutView() -> BCOVPUILayoutView {
        let seek10LayoutView = BCOVPUIBasicControlView.layoutViewWithControl(
            from: BCOVPUIViewTag.viewEmpty,
            width: 88.0,
            elasticity: 1.0
        )!
        
        let seek10ImageView = UIImageView(image: UIImage(systemName: "arrow.clockwise"))
        seek10ImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        seek10ImageView.contentMode = .scaleAspectFit
        seek10ImageView.isUserInteractionEnabled = true
        seek10ImageView.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapped))
        seek10ImageView.addGestureRecognizer(tapGesture)
        
        // Add image view to our empty layout view.
        seek10LayoutView.addSubview(seek10ImageView)
        return seek10LayoutView
    }
    
    func requestContent() {
        let videoURL = URL(string: streamURLParkour)
        let source = BCOVSource(withURL: videoURL)
        let video = BCOVVideo(withSource: source, cuePoints: .none, properties: [:])
        self.playbackController.setVideos([video])
    }
}

