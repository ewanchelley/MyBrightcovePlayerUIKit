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
    let playbackController: BCOVPlaybackController
    @IBOutlet weak var videoContainerView: UIView!

    required init?(coder aDecoder: NSCoder) {
        playbackController = (sharedSDKManager.createPlaybackController())

        super.init(coder: aDecoder)

        playbackController.analytics.account = kViewControllerAccountID // Optional

        playbackController.delegate = self
        playbackController.isAutoAdvance = true
        playbackController.isAutoPlay = true
    }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

      let controlsView = BCOVPUIBasicControlView.withVODLayout()
      
      let logoLayoutView1 = BCOVPUIBasicControlView.layoutViewWithControl(from: BCOVPUIViewTag.viewEmpty,
                                                                          width: 88.0,
                                                                          elasticity: 1.0)
      
      let logoImage1 = UIImage(named: "myLogo")
      let logoImageView1 = UIImageView(image: logoImage1)

      logoImageView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      logoImageView1.contentMode = .scaleAspectFit
      //logoImageView1.frame = logoLayoutView1.frame

      // Add image view to our empty layout view.
      logoLayoutView1!.addSubview(logoImageView1)

      let customLayout = BCOVPUIControlLayout.init(standardControls: [], compactControls: [])
      controlsView!.layout = customLayout
      
        
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

    func requestContent() {
        let videoURL = URL(string: streamURLBBC)
        let source = BCOVSource(withURL: videoURL)
        let video = BCOVVideo(withSource: source, cuePoints: .none, properties: [:])
        self.playbackController.setVideos([video])
    }
    
//  func requestContentFromPlaybackService() {
//    let configuration = [BCOVPlaybackService.ConfigurationKeyAssetID:kViewControllerVideoID]
//    playbackService.findVideo(withConfiguration: configuration, queryParameters: nil, completion: { [weak self] (video: BCOVVideo?, jsonResponse: Any?, error: Error?) in
//
//        if let v = video {
//            self?.playbackController.setVideos([v])
//        } else {
//            print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
//        }
//    })
//  }
}

