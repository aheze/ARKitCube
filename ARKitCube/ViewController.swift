//
//  ViewController.swift
//  ARKitCube
//
//  Created by Zheng on 2/10/21.
//


/// This project showcases how to make a red cube appear 20 centimeters in front of the cameras initial position. It works best in an open area.
/// Each face of the cube is a different color, and each face emits a different sound when it is tapped.
///
/// Here is a table of which faces correspond with which colors and sounds:
/// Face 0 (front) - red - 1Do.mp3
/// Face 1 (right) - orange - 2Re.mp3
/// Face 2 (back) - yellow - 3Mi.mp3
/// Face 3 (left) - green - 4Fa.mp3
/// Face 4 (top) - blue - 5So.mp3
/// Face 5 (bottom) - purple - 6La.mp3
///
/// We are using ARKit and SceneKit, not RealityKit.
/// All code is located in this file and the storyboard is not used. The sounds are located in the PianoNotes folder.
/// Also, the Camera usage permission popup description is located at the top of Info.plist
/// It uses sample code from https://developer.apple.com/documentation/arkit/arscnview/providing_3d_virtual_content_with_scenekit


import UIKit
import ARKit
import AVFoundation

class ViewController: UIViewController {

    var arKitSceneView: ARSCNView!
    var soundEffectPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /// Make an ARKit scene view
        let arKitSceneView = ARSCNView()
        
        /// Add the ARKIT scene view as a subview
        view.addSubview(arKitSceneView)
        
        /// Positioning constraints
        arKitSceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arKitSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            arKitSceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            arKitSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arKitSceneView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        
        
        /// Configure the AR Session
        /// This will make ARKit track the device's position and orientation
        let worldTrackingConfiguration = ARWorldTrackingConfiguration()
        
        /// Run the configuration
        arKitSceneView.session.run(worldTrackingConfiguration)
        
        
        /// Make the cube
        /// SceneKit and ARKit coordinates are in meters
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        /// Make the cube have a different color for each face
        let front = SCNMaterial()
        let right = SCNMaterial()
        let back = SCNMaterial()
        let left = SCNMaterial()
        let top = SCNMaterial()
        let bottom = SCNMaterial()
        front.diffuse.contents = UIColor.red
        right.diffuse.contents = UIColor.orange
        back.diffuse.contents = UIColor.yellow
        left.diffuse.contents = UIColor.green
        top.diffuse.contents = UIColor.blue
        bottom.diffuse.contents = UIColor.purple
        
        cube.materials = [front, right, back, left, top, bottom]
        
        /// Add the cube object to a node, which is how you do it in SceneKit
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(0, 0, -0.2) /// 20 cm in front of the camera
        cubeNode.name = "ColorCube"
        
        /// Then, add the node to the ARKit scene
        arKitSceneView.scene.rootNode.addChildNode(cubeNode)
        
        /// Configure positional audio in the AR Scene view
        arKitSceneView.audioEnvironmentNode.distanceAttenuationParameters.maximumDistance = 4 /// how many meters to adjust the sound in fragments
        arKitSceneView.audioEnvironmentNode.distanceAttenuationParameters.referenceDistance = 0.02 /// adjust the sound every 0.02 meters
        arKitSceneView.audioEnvironmentNode.renderingAlgorithm = .auto
        
        /// Make the audio source
        var audioSource = SCNAudioSource(fileNamed: "1Mono.mp3")!
        
        /// As an environmental sound layer, audio should play indefinitely
        audioSource.loops = true
        audioSource.isPositional = true
    
        /// Decode the audio from disk ahead of time to prevent a delay in playback
        audioSource.load()
        
        /// add the audio player now
        cubeNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        
        /// Set up a gesture recognizer.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hitTestCube))
        arKitSceneView.addGestureRecognizer(tapGestureRecognizer)
        
        /// In case you need to access the scene view later
        self.arKitSceneView = arKitSceneView
    }
    
    /// Handles the gesture recognizer, and plays a sound if the location of the tap is on top of the red cube.
    @objc func hitTestCube(sender: UITapGestureRecognizer) {
        
        /// Make sure the user's finger lifted from the screen
        guard sender.state == .ended else { return }
        
        /// Get the location of the tap. This is in on-screen coordinates.
        let locationOfTap = sender.location(in: arKitSceneView)
        
        /// Perform something called "Hit-testing". This projects on-screen coordinates to the coordinates of the SCNScene.
        /// Here, we project the on-screen location of the tap into the SCNScene, and see if there are any nodes there.
        /// Imaging a beam of light projecting from the on-screen location. Any objects that the beam hits are returned with this function.
        let results = arKitSceneView.hitTest(locationOfTap, options: [SCNHitTestOption.searchMode : 1])
        
        /// See if the beam hit the red box
        for result in results.filter( { $0.node.name == "ColorCube" }) {
            let cubeNode = result.node
            
            /// Get the face of the cube that was hit
            let material = cubeNode.geometry!.materials[result.geometryIndex]
            
            /// Make that face's color animate to white and back
            let colorAnimation = CABasicAnimation(keyPath: #keyPath(SCNMaterial.diffuse.contents))
            colorAnimation.toValue = UIColor.white
            colorAnimation.duration = 0.2
            colorAnimation.autoreverses = true
            colorAnimation.isRemovedOnCompletion = true
            material.addAnimation(colorAnimation, forKey: nil)
            
            /// Play a different sound depending on which side is pressed
            switch result.geometryIndex {
            case 0:
                playSound(fileName: "1Do.mp3")
            case 1:
                playSound(fileName: "2Re.mp3")
            case 2:
                playSound(fileName: "3Mi.mp3")
            case 3:
                playSound(fileName: "4Fa.mp3")
            case 4:
                playSound(fileName: "5So.mp3")
            case 5:
                playSound(fileName: "6La.mp3")
            default:
                break
            }
        }
    }
    
    /// Play a sound
    func playSound(fileName: String) {
        DispatchQueue.global().async {
            let path = Bundle.main.path(forResource: fileName, ofType:nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
                self.soundEffectPlayer?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }
}

