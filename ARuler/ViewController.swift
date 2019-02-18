//
//  ViewController.swift
//  ARuler
//
//  Created by Aymeric SCHERRER on 2/18/19.
//  Copyright © 2019 Aymeric SCHERRER. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var dotNotes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Touch Method
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let materials = SCNMaterial()
        
        materials.diffuse.contents = UIColor.red
        dotGeometry.materials = [materials]

        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNotes.append(dotNode)
        
        if dotNotes.count >= 2 {
            calculate()
        }
    }
    
    // Calculate the distance between 2 dots
    
    func calculate() {
        let start = dotNotes[0]
        let end = dotNotes[1]

        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(distance)", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        let textNode = SCNNode(geometry: textGeometry)

        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
