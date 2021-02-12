//
//  ViewController.swift
//  ARKitCube
//
//  Created by Zheng on 2/10/21.
//


/// This project showcases how to make a cube appear 20 centimeters in front of the camera's initial position. It works best in an open area.
/// Each face of the cube is a different color, and each face emits a different sound when it is tapped.
///
/// Here is a description of which faces correspond with which colors and sounds:
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

class ViewController: UIViewController {

    var arKitSceneView: ARSCNView!
    var soundEffectPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /// Make an ARKit scene view
        let arKitSceneView = ARSCNView()
        
        /// Make voiceover allow directly tapping the scene view.
        arKitSceneView.isAccessibilityElement = true
        arKitSceneView.accessibilityTraits = .allowsDirectInteraction
        arKitSceneView.accessibilityLabel = "Use the rotor to enable Direct Touch"
        
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
        let audioSource = SCNAudioSource(fileNamed: "1Mono.mp3")!
        
        /// As an environmental sound layer, audio should play indefinitely
        audioSource.loops = true
        audioSource.isPositional = true
    
        /// Decode the audio from disk ahead of time to prevent a delay in playback
        audioSource.load()
        
        /// Add the audio player now
        cubeNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        
        /// Set up a gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hitTestCube))
        arKitSceneView.addGestureRecognizer(tapGestureRecognizer)
        
        /// Just in case you need to access the ARKit scene view later
        self.arKitSceneView = arKitSceneView
        
        /// Set up the bottom buttons
        setUpHitTestingButton()
        setUpLocatorButton()
    }
    
    /// Handles the gesture recognizer, and plays a sound if the location of the tap is on top of the cube.
    @objc func hitTestCube(sender: UITapGestureRecognizer) {
        
        /// Make sure the user's finger lifted from the screen
        guard sender.state == .ended else { return }
        
        /// Get the location of the tap. This is in on-screen coordinates.
        let locationOfTap = sender.location(in: arKitSceneView)
        
        /// Move hit-testing logic into separate function
        hitTestAtPosition(locationInSceneView: locationOfTap)
    }
    
    func hitTestAtPosition(locationInSceneView: CGPoint) {
        
        
        /// Perform something called "Hit-testing". This projects on-screen coordinates to the coordinates of the SCNScene.
        /// Here, we project the on-screen location of the tap into the SCNScene, and see if there are any nodes there.
        /// Imaging a beam of light projecting from the on-screen location. Any objects that the beam hits are returned with this function.
        let results = arKitSceneView.hitTest(locationInSceneView, options: [SCNHitTestOption.searchMode : 1])
        
        /// See if the beam hit the cube
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
            
            /// Play a different sound depending on which face was hit
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
    
    /// Make a button that hit-tests the point at the center of the screen for you
    /// This will be at the bottom-left corner
    func setUpHitTestingButton() {
        let hitTestButton = UIButton()
        hitTestButton.setImage(UIImage(systemName: "plus"), for: .normal) /// set the image of the button to a plus icon, which kind of looks like a crosshair
        hitTestButton.tintColor = UIColor.red /// color of the image
        hitTestButton.backgroundColor = UIColor.white
        hitTestButton.layer.cornerRadius = 8 /// make some rounded corners
        
        /// Make the button call locatorButtonPressed when it is pressed
        hitTestButton.addTarget(self, action: #selector(hitTestButtonPressed), for: .touchUpInside)
        
        /// for VoiceOver
        hitTestButton.accessibilityLabel = "Hit-test at the center of the screen"
        
        view.addSubview(hitTestButton)
        
        /// position the button
        hitTestButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hitTestButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            hitTestButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hitTestButton.widthAnchor.constraint(equalToConstant: 80),
            hitTestButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    /// called when the locator button is pressed
    @objc func hitTestButtonPressed(_ sender: UIButton) {
        
        /// Announce to VoiceOver
        UIAccessibility.post(notification: .announcement, argument: "Hit testing at center of screen")
        
        /// Get the center of the ARKit scene (on-screen coordinates)
        let centerPoint = arKitSceneView.center
        
        /// Call the hit-test function
        hitTestAtPosition(locationInSceneView: centerPoint)
    }
    
    /// Make a button that tells you where the cube is
    /// This will be at the bottom-right corner
    func setUpLocatorButton() {
        let locatorButton = UIButton()
        locatorButton.setImage(UIImage(systemName: "location"), for: .normal) /// set the image of the button to the location icon, which is an arrow pointing North-East
        locatorButton.tintColor = UIColor.blue /// color of the image
        locatorButton.backgroundColor = UIColor.white
        locatorButton.layer.cornerRadius = 8 /// make some rounded corners
        
        /// Make the button call locatorButtonPressed when it is pressed
        locatorButton.addTarget(self, action: #selector(locatorButtonPressed), for: .touchUpInside)
        
        /// for VoiceOver
        locatorButton.accessibilityLabel = "Speak location of the cube. Make sure to turn on Direct Touch"
        
        view.addSubview(locatorButton)
        
        /// position the button
        locatorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locatorButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            locatorButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            locatorButton.widthAnchor.constraint(equalToConstant: 80),
            locatorButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    /// called when the locator button is pressed
    @objc func locatorButtonPressed(_ sender: UIButton) {
        for node in arKitSceneView.scene.rootNode.childNodes {
            if node.name == "ColorCube" {
                
                /// the camera node
                let cameraNode = arKitSceneView.pointOfView!
                
                /// the following code calculates the angle between the camera and the cube
                /// most code is adapted from this stack overflow answer: https://stackoverflow.com/a/57359650/14351818
                /// make a temporary node which will represent the direction of the camera
                let lookingDirectionNode = SCNNode()
                let position = SCNVector3(x: 0, y: 0, z: -2) /// put it 2 meters in front
                updatePositionAndOrientationOf(lookingDirectionNode, withPosition: position, relativeTo: cameraNode) /// set the position to 2 meters in front of camera
                
                /// get angle between looking direction node and the color cube node, with the camera node as the vertex
                let angle = calculateAngleBetween3Positions(vertex: cameraNode.position, pos2: lookingDirectionNode.position, pos3: node.position)
                let angleInDegrees = angle * 180 / .pi /// convert from radians to degrees
                
                /// make voiceover speak how far away the cube is
                UIAccessibility.post(notification: .announcement, argument: "The cube is \(Int(angleInDegrees)) degrees away")
                
            }
        }
    }
    
    /// The following 2 functions are for calculating the angle between the camera and the cube
    /// from this stack overflow answer: https://stackoverflow.com/a/57359650/14351818
    
    /// put a node in front of another node
    /// we use this to put a temporary node in front of the camera for out calculations
    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)

        /// Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z

        /// Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }
    
    /// calculate the angle between 3 positions
    /// the vertex should be the camera node
    /// pos2 and pos3 are the temporary looking node and the cube node
    func calculateAngleBetween3Positions(vertex: SCNVector3, pos2: SCNVector3, pos3: SCNVector3) -> Float {
        let v1 = SCNVector3(x: pos2.x-vertex.x, y: pos2.y-vertex.y, z: pos2.z-vertex.z)
        let v2 = SCNVector3(x: pos3.x-vertex.x, y: pos3.y-vertex.y, z: pos3.z-vertex.z)
        
        let v1Magnitude = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
        let v1Normal = SCNVector3(x: v1.x/v1Magnitude, y: v1.y/v1Magnitude, z: v1.z/v1Magnitude)
        
        let v2Magnitude = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z)
        let v2Normal = SCNVector3(x: v2.x/v2Magnitude, y: v2.y/v2Magnitude, z: v2.z/v2Magnitude)
        
        let result = v1Normal.x * v2Normal.x + v1Normal.y * v2Normal.y + v1Normal.z * v2Normal.z
        let angle = acos(result)
        
        return angle
    }
}
