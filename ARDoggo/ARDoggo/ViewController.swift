//
//  ViewController.swift
//  ARDoggo
//
//  Created by LimJJ on 10/30/18.
//  Copyright © 2018 JJ Lim. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    // Set up global variables
    @IBOutlet var sceneView: ARSCNView!
    var wolf_fur: ColladaRig?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var trackerNode: SCNNode!
    var wolfIsPlaced = false
    var planeIsDetected = false
    var wolf: SCNNode!
    var wolfScale = 0.6
    var worldPos: SCNVector3!
    var cameraYaw: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set the debuging options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Enable lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        // Recognize tap gesture
//        addTapGestureToSceneView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Horizontal plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Referred: Anyone Can Code ARGame Tutorial - Part 2 of 3 (www.youtube.com/watch?v=mOTrialE85Q)
        // Return if plane is not detected
        if wolfIsPlaced {
            //do things with wolf
        }
        else {
            guard planeIsDetected else { return }
            trackerNode.removeFromParentNode()
            addModelToSceneView()
            wolfIsPlaced = true
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////                            Renderers                                /////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Override to create and configure nodes for anchors added to the view's session.
    // Visualize horizontal planes refer: https://www.appcoda.com/arkit-horizontal-plane/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Unwrap the anchor as an ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Get the anchor dimension
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // Set the color of the plane
        plane.materials.first?.diffuse.contents = UIColor.magenta
        
        // Initialize a SCNNode with the geometry we got
        let planeNode = SCNNode(geometry: plane)
        
        // Initialize coordinates of the plane
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        planeNode.isHidden = true
        
        // Add the plane node as a SceneKit
        node.addChildNode(planeNode)
    }
    
    // Renderer to expand the horizontal planes
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1) Unwrap the plane anchor as ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first, // 2) Unwrap the first plane node
            let plane = planeNode.geometry as? SCNPlane // 3) Unwrap the node geometry
            else { return }
        
        // 2) Update plane geometry
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3) Update plane coordinates
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    // Look for a surface to place wolf
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Referred: Anyone Can Code ARKit Game Tutorial - Part 1 of 3
        guard !wolfIsPlaced else { return }
        
        // Do the hit test in the middle of the screen and get the closest hit test result if pass
        guard let hitTest = sceneView.hitTest(
            CGPoint(x: view.frame.midX, y: view.frame.midY),
            types: [.featurePoint, .existingPlane]
            )
            .first
            else { return }
        
        
        
        
        if !planeIsDetected { // only runs once
            let trackerPlane = SCNPlane(width: 0.5, height: 0.5)
            trackerPlane.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "corgiTracker")
            trackerNode = SCNNode(geometry: trackerPlane)
            
//            trackerNode.rotation = SCNVector4(0, yaw ?? 0, 0, 0)
            trackerNode.eulerAngles.x = -.pi/2.0 // make tracker horizontal
            planeIsDetected = true
        }
        
        // runs constantly
        // With the farthest hit test result, get the transformation matrix
        let transMat = SCNMatrix4(hitTest.worldTransform)
        worldPos = SCNVector3Make(transMat.m41, transMat.m42, transMat.m43)
        trackerNode.position = worldPos
        cameraYaw = sceneView.session.currentFrame?.camera.eulerAngles.y
        trackerNode.eulerAngles.y = cameraYaw!
        sceneView.scene.rootNode.addChildNode(trackerNode)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////                          Move wolf                                  /////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    func walk(to: SCNVector3, duration: Float) {
        let toVec = SCNVector3(wolf.position.x+3.0, wolf.position.y, wolf.position.z+3.0)
        let walkAction = SCNAction.sequence([
            SCNAction.rotateTo(
                x:0.0, y:CGFloat(toVec.x), z:0,
                duration: 2.0
            ),
            SCNAction.move(
                to: toVec,
                duration: TimeInterval(duration)
            )]
        )
        wolf.runAction(walkAction, forKey: "walk_to")
    }
    
    func walk(direction: SCNVector3, duration: Float) {
//        wolf.look(at: direction)
//        wolf.physicsBody?.applyForce(SCNVector3(0.0, 0.0, 5.0), asImpulse: true)
        //        wolf.look(at: SCNVector3(0, 0, cameraYaw))
        //        sceneView.scene.rootNode.addChildNode(wolf)
        let walkAction = SCNAction.sequence([
            SCNAction.rotateBy(
                x: 0.0, y: 1.0, z: 0.0,
                duration: 2.0
            ),
            SCNAction.move(
                by: SCNVector3(1.0, 0.0, 0.0),
                duration: TimeInterval(duration)
            )]
        )
        wolf.runAction(walkAction, forKey: "walk_dir")
        
//        Timer.scheduledTimer(timeInterval: 5.0, target: <#T##Any#>, selector: <#T##Selector#>, userInfo: <#T##Any?#>, repeats: <#T##Bool#>)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////                       Using .scn model                              /////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    @objc func addModelToSceneView() {
        // Use the tap location to determine if on a plane
        
        // Extract wolf scene from .scn file and set up wolf node
        let wolfScene = SCNScene(named: "art.scnassets/wolf.scn")!
        wolf = wolfScene.rootNode.childNode(withName: "wolf", recursively: true)!
        wolf.removeAllAnimations()
        wolf.removeAllActions()
        
        // Rotate the node according to camera (only horizontally)
        // referred: https://stackoverflow.com/questions/46390019/how-to-change-orientation-of-a-scnnode-to-the-camera-with-arkit
        // place right behind where the user tapped
        wolf.scale = SCNVector3(wolfScale, wolfScale, wolfScale) // scale down the wolf
        wolf.rotation = SCNVector4(0, 1, 0, cameraYaw)
        wolf.position = worldPos
        // Place the wolf a bit "behind" where the user taps
        wolf.localTranslate(by: SCNVector3(0, 0, 0.17*wolfScale))
        // Display wolf with "normal" orientation. After changing wolf.scn's node
        // names, 90 degrees x-rotation happened (by accident?) and this "fixes" it.
        // If model is fixed to have horizontal orientation, could delete this line.
        if wolf.eulerAngles.x > 0 {
            // prevent wolf to be upside down when adding to left to initial camera position
            wolf.eulerAngles.x = -.pi/2.0
        }
        else {
            wolf.eulerAngles.x = .pi/2.0
        }
        
        // Add wolf to the sceneView so that it is displayed
        wolf.isHidden = false
        sceneView.scene.rootNode.addChildNode(wolf)
//        walk(to: SCNVector3(0, -50, 0))
        
        // Let wolf affected by physics
        wolf.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        wolf.physicsBody?.isAffectedByGravity = false
        
//        walk(direction: SCNVector3(0.0, 1.0, 0.0), duration: 5.0)
        walk(to: SCNVector3(0,0,0), duration:5.0)
//        wolf.removeAction(forKey: "walk")
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////                     Hit Test and Tapping                            /////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    @objc func getHitTestPosVec(withGestureRecognizer recognizer: UIGestureRecognizer) -> SCNVector3 {
        // Use the tap location to determine if on a plane
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first else { return SCNVector3(0,0,0) } //TODO: think about failure return behavior
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        //        print("hitTest coord: (",x, y, z, ")") // DEBUG
        
        // Rotate the node according to camera (only horizontally)
        // referred: https://stackoverflow.com/questions/46390019/how-to-change-orientation-of-a-scnnode-to-the-camera-with-arkit
        //        let yaw = sceneView.session.currentFrame?.camera.eulerAngles.y
        
        return SCNVector3(x, y, z)
    }
    
//    func addTapGestureToSceneView() {
//        // Detect tap gesture
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addModelToSceneView(withGestureRecognizer:)))
//        sceneView.addGestureRecognizer(tapGestureRecognizer!)
//    }
    
    func getTapGestureRecognizer() -> UITapGestureRecognizer {
        return tapGestureRecognizer!
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////                            Others                                   /////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}


//ColladaRig stuff
//gestureRecognizers: Optional([
//<UILongPressGestureRecognizer: 0x1042192f0; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handlePress:, target=<SCNCameraNavigationController 0x104218f90>)>>, <UIPanGestureRecognizer: 0x1042197d0; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handlePan:, target=<SCNCameraNavigationController 0x104218f90>)>>,
//<UITapGestureRecognizer: 0x2828fee00; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handleDoubleTap:, target=<SCNCameraNavigationController 0x104218f90>)>; numberOfTapsRequired = 2>, <UIPinchGestureRecognizer: 0x104219660; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handlePinch:, target=<SCNCameraNavigationController 0x104218f90>)>>,
//<UIRotationGestureRecognizer: 0x104219950; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handleRotation:, target=<SCNCameraNavigationController 0x104218f90>)>>, <UITapGestureRecognizer: 0x2828f5b00; state = Ended; view = <ARSCNView 0x104211f50>; target= <(action=addColladaModelToSceneViewWithGestureRecognizer:, target=<ARDoggo.ViewController 0x104210110>)>>])

//sceneSource:  <SCNSceneSource: 0x282718ba0 | URL='file:///var/containers/Bundle/Application/105AE83D-24C2-40D1-BF75-E00E75B38D39/ARDoggo.app/art.scnassets/wolf_dae.dae'>


//identifiersOfEntry
//["Becken", "Maulunten", "Braun_O_R", "Bauch", "Vorderpfote_L", "Mauloben", "Bauch_001", "aug_lied_O_L", "Brust", "Schalterplatte_R", "MundW_L", "Hals", "aug_lied_O_R", "Unterschenkel_L", "Oberarm_R", "MundW_R", "Kopf_002", "aug_lied_U_L", "Kopf", "Unterarm_R", "Aug_R", "Pfote1_L", "aug_lied_U_R", "Pfote2_L", "Vorderpfote_R", "aug_L", "Oberschenkel_R", "Bauch_003", "Schwanz", "Ohr_L", "Unterschenkel_R", "Schalterplatte_L", "Schwanz_001", "Ohr_R", "Pfote1_R", "Oberarm_L", "Schwanz_002", "Pfote2_R", "Unterarm_L", "Schwanz_003", "root", "Oberschenkel_L", "Wolf_obj_fur", "Wolf_obj_body", "Unterkiefer", "node/46", "Hals_fett", "run2", "Braun_O_L"]

