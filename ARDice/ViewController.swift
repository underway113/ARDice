//
//  ViewController.swift
//  ARDice
//
//  Created by Jeremy Adam on 09/06/19.
//  Copyright © 2019 Underway. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//
//        cube.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = cube
//        sceneView.scene.rootNode.addChildNode(node)
//
        
        
        sceneView.autoenablesDefaultLighting = true
        
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        print("Supported AR World Tracking Config: \( ARWorldTrackingConfiguration.isSupported)")
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchLoc, types: .existingPlaneUsingExtent)
            
            if let hitResult = result.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
                // Set the scene to the view
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
        
                   roll(diceNode)
                }
            }
            
        }
        
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice)
            }
        }
    }
    
    func roll(_ dice: SCNNode) {
        let randomX = CGFloat(arc4random_uniform(4) + 1) * CGFloat(Float.pi/2)
        let randomZ = CGFloat(arc4random_uniform(4) + 1) * CGFloat(Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: (randomX * 3), y: 0, z: (randomZ * 3), duration: 0.5))
        
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("Anchor Detected")
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            //Make Plane (Bidang datar)
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            //Make PlaneNode (Variabel penampung untuk peletakan Plane)
            let planeNode = SCNNode()
            
            //penentuan posisi planeNode
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            //Rotate planenode (awalnya vertical, yang kita mau horizontal)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            
            //variable grid material (material/warna untuk plane
            let gridMaterial = SCNMaterial()
            
            //gridMaterial = gambar grid
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            //plane memiliki material/warna gridMaterial
            plane.materials = [gridMaterial]
            
            //planeNode adalah plane
            planeNode.geometry = plane
            
            //node yang di dapat dari ARWorldTracking Horizontal. di add child node berupa planeNode (bidang datar dengan grid)
            node.addChildNode(planeNode)
            
        }
        else {
            return
        }
    }
    
}
