//
//  ContentView.swift
//  ARKitCube-SwiftUI
//
//  Created by Zheng on 2/12/21.
//

import SwiftUI
import ARKit
import AVFoundation

/**
 This is the SwiftUI version of the ARKitCube project.
 This is file 1 of 2 used. This is the main file, which lays out the interface.
 The other file, ARSCNView.swift, contains the compatibility code for the ARKit Scene View. This lets you use the ARKit Scene View, which is native to UIKit, in SwiftUI.
 
 
 This project showcases how to make a cube appear 20 centimeters in front of the camera's initial position. It works best in an open area.
 Each face of the cube is a different color, and each face emits a different sound when it is tapped.
 The cube also constantly emits a spacial sound, so when you get closer, it gets louder.
 
 There are also two buttons at the bottom of the screen.
 The left button performs hit-testing at the location (a CGPoint) at the center of the screen.
 The right button announces the angle between the camera, which is your phone, and the cube. You must have VoiceOver on for this.
 
 Here is a description of which faces correspond with which colors and sounds:
 Face 0 (front) - red - 1Do.mp3
 Face 1 (right) - orange - 2Re.mp3
 Face 2 (back) - yellow - 3Mi.mp3
 Face 3 (left) - green - 4Fa.mp3
 Face 4 (top) - blue - 5So.mp3
 Face 5 (bottom) - purple - 6La.mp3
 
 We are using ARKit and SceneKit, not RealityKit.
 The sounds are located in the PianoNotes folder.
 Also, the Camera usage permission popup description is located at the top of Info.plist
 It uses sample code from https://developer.apple.com/documentation/arkit/arscnview/providing_3d_virtual_content_with_scenekit
 */

struct ContentView: View {
    
    /// Retain a reference to the ARKit scene view
    let swiftUIARSCNView = SwiftUIARSCNView()
    
    @State var soundEffectPlayer: AVAudioPlayer?
    
    var body: some View {
        
        /// Stack views on top of each other
        ZStack {
            
            /// put ARKit scene view at the bottom
            swiftUIARSCNView
                .accessibility(label: Text("Use the rotor to enable Direct Touch"))
                .edgesIgnoringSafeArea(.all) /// make it go under the status bar
                
                /// Equivalent of a tap gesture recognizer
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global).onEnded { dragGesture in
                    hitTestAtPosition(locationInSceneView: dragGesture.location)
                })
            
            /// Overlay a VStack on top of the scene view
            VStack {
                
                /// Force the HStack down...
                Spacer()
                
                
                /// ...The HStack is now at the bottom of the screen
                HStack {
                    
                    /// The left Locator button
                    Button(action: { /// called when it is pressed
                        
                        /// Announce to VoiceOver
                        UIAccessibility.post(notification: .announcement, argument: "Hit testing at center of screen")
                        
                        /// Get the center of the ARKit scene (on-screen coordinates)
                        let centerPoint = swiftUIARSCNView.arKitSceneView.center
                        
                        /// Call the hit-test function
                        hitTestAtPosition(locationInSceneView: centerPoint)
                        
                    }) {
                        
                        /// What the button looks like
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(Color.red)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                        
                    }
                    .accessibility(label: Text("Hit-test at the center of the screen"))
                    
                    /// Force the buttons to the left and right
                    Spacer()
                    
                    /// The right button that announces the angle between the camera and the color cube
                    Button(action: {
                        for node in swiftUIARSCNView.arKitSceneView.scene.rootNode.childNodes {
                            if node.name == "ColorCube" {
                                
                                /// the camera node
                                let cameraNode = swiftUIARSCNView.arKitSceneView.pointOfView!
                                
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
                    }) {
                        
                        /// What the button looks like
                        Image(systemName: "location")
                            .font(.system(size: 24))
                            .foregroundColor(Color.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                        
                    }
                    .accessibility(label: Text("Speak location of the cube. Make sure to turn on Direct Touch"))
                }
                
            }
            
        }
        
        
        /// Equivalent of viewDidLoad from UIKit
        .onAppear {
            
            
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
            swiftUIARSCNView.arKitSceneView.scene.rootNode.addChildNode(cubeNode)
            
            /// Configure positional audio in the AR Scene view
            swiftUIARSCNView.arKitSceneView.audioEnvironmentNode.distanceAttenuationParameters.maximumDistance = 4 /// how many meters to adjust the sound in fragments
            swiftUIARSCNView.arKitSceneView.audioEnvironmentNode.distanceAttenuationParameters.referenceDistance = 0.02 /// adjust the sound every 0.02 meters
            swiftUIARSCNView.arKitSceneView.audioEnvironmentNode.renderingAlgorithm = .auto
            
            /// Make the audio source
            let audioSource = SCNAudioSource(fileNamed: "1Mono.mp3")!
            
            /// As an environmental sound layer, audio should play indefinitely
            audioSource.loops = true
            audioSource.isPositional = true
            
            /// Decode the audio from disk ahead of time to prevent a delay in playback
            audioSource.load()
            
            /// Add the audio player now
            cubeNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        }
    }
    
    /// Perform hit-testing at a location, in on-screen coordinates
    func hitTestAtPosition(locationInSceneView: CGPoint) {
        
        
        /// Perform something called "Hit-testing". This projects on-screen coordinates to the coordinates of the SCNScene.
        /// Here, we project the on-screen location of the tap into the SCNScene, and see if there are any nodes there.
        /// Imaging a beam of light projecting from the on-screen location. Any objects that the beam hits are returned with this function.
        let results = swiftUIARSCNView.arKitSceneView.hitTest(locationInSceneView, options: [SCNHitTestOption.searchMode : 1])
        
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

/// For the Xcode preview (optional, can delete)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
