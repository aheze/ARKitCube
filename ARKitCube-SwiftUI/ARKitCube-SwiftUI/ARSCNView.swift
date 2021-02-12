//
//  ARSCNView.swift
//  ARKitCube-SwiftUI
//
//  Created by Zheng on 2/12/21.
//

import SwiftUI
import ARKit

/**
 This is the SwiftUI version of the ARKitCube project.
 This is file 2 of 2 used. This is not the main file. This file contains the code for the ARKit Scene View, which is native to UIKit.
 To use the ARKit Scene View in SwiftUI, you must wrap it in an UIViewRepresentable, which is what the code in this file does.
 The other file, ContentView.swift, contains the main code for the interface.
 */

struct SwiftUIARSCNView: UIViewRepresentable {

    /// Make an ARKit scene view
    let arKitSceneView = ARSCNView()
    
    /// The main method required by UIViewRepresentable. Defines what the view should be.
    func makeUIView(context: Context) -> ARSCNView {
        
        /// Make voiceover allow directly tapping the scene view.
        arKitSceneView.isAccessibilityElement = true
        arKitSceneView.accessibilityTraits = .allowsDirectInteraction
        arKitSceneView.accessibilityLabel = "Use the rotor to enable Direct Touch"
        
        /// Configure the AR Session
        /// This will make ARKit track the device's position and orientation
        let worldTrackingConfiguration = ARWorldTrackingConfiguration()
        
        /// Run the configuration
        arKitSceneView.session.run(worldTrackingConfiguration)
        
        /// Return the ARKit Scene View to the UIViewRepresentable.
        return arKitSceneView
    }

    /// No need for this, but UIViewRepresentable requires it
    func updateUIView(_ uiView: ARSCNView, context: Context) {

    }
}
