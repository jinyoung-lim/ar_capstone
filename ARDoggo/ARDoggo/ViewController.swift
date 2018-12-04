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
    // MARK: - global variables
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var comeHereButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var wolf_fur: ColladaRig?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var trackerNode: SCNNode!
    var wolfIsPlaced = false
    var planeIsDetected = false
    let WOLF_SCALE = 0.6
    var wolf: SCNNode!
    var userPos: SCNVector3!
    var cameraYaw: Float!
    
    //MARK: - game state variables
    var isSeekMode: Bool!
    @IBOutlet weak var gameModeLabel: UILabel!
    
    //MARK: - timer variables
    @IBOutlet weak var timerLabel: UILabel!
    let DEFAULT_ROUND_TIME = 100
    var remainingSeconds: Int!
    var timer: Timer!
    
    
    // MARK: - ARSCNViewDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set the debuging options
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Enable lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        // Start the timer
        remainingSeconds = DEFAULT_ROUND_TIME
        runTimer()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Horizontal plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Hide comeHereButton and done button at first
        comeHereButton.isEnabled = false
        comeHereButton.isHidden = true
        doneButton.isEnabled = false
        doneButton.isHidden = true
        // Hide mode first and then seek mode
        isSeekMode = false
        gameModeLabel.text = "Hide the doggo!"
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
            guard isSeekMode else { return }
//            detectTapCollisionWithWolf()
        }
        else {
            guard planeIsDetected else { return }
            trackerNode.removeFromParentNode()
            addModelToSceneView()
            // Unhide comeHereButton once the wolf is added
            comeHereButton.isEnabled = true
            comeHereButton.isHidden = false
            doneButton.isEnabled = true
            doneButton.isHidden = false
            
            wolfIsPlaced = true
        }
    }
    
    //MARK: - timer related classes
    //referrence: https://medium.com/libertyit/ar-madness-our-open-source-arkit-game-tutorial-part-five-game-management-64234225289b
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if remainingSeconds == 0 {
            // this state would be reached twice
            // - once when hide mode is over and
            // - another time when the seek mode is over
            if (!isSeekMode) {
                gameChangeHideToSeek()
            }
            else {
                timer.invalidate() // remove timer from RunLoop
                gameOver()
            }
        }
        else {
            remainingSeconds -= 1
            timerLabel.text = "\(remainingSeconds ?? DEFAULT_ROUND_TIME)"
        }
        
    }
    
    func resetTimer(){
        timer.invalidate()
        remainingSeconds = DEFAULT_ROUND_TIME
        timerLabel.text = "\(remainingSeconds ?? DEFAULT_ROUND_TIME)"
        runTimer()
    }
    
    //MARK: - buttons
    @IBAction func onComeHereButton(_ sender: UIButton) {
        //        let centerPos = getUserPosVec()
        let deltaX = userPos.x - wolf.position.x
        let deltaZ = userPos.z - wolf.position.z
        let dist = sqrt(deltaX*deltaX + deltaZ*deltaZ)
        walk(to: userPos, duration: Double(dist))
    }
    @IBAction func onDoneButton(_ sender: Any) {
        remainingSeconds = 0
    }
    
    //Mark: - renderers
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
        //TODO: time is not used! replace renderer that doesn't use time
        // Referred: Anyone Can Code ARKit Game Tutorial - Part 1 of 3
        // Update worldPos and cameraYaw constantly
        guard let hitTest = sceneView.hitTest(
            CGPoint(x: sceneView.frame.midX, y: sceneView.frame.midY),
            types: [.featurePoint, .existingPlane]
            )
            .first
            else { return }
        let transMat = SCNMatrix4(hitTest.worldTransform)
        userPos = SCNVector3Make(transMat.m41, transMat.m42, transMat.m43)
        cameraYaw = sceneView.session.currentFrame?.camera.eulerAngles.y
        
        // Run below only if wolf is not placed
        guard !wolfIsPlaced else { return }
        if !planeIsDetected { // only runs once
            let trackerPlane = SCNPlane(width: 0.5, height: 0.5)
            trackerPlane.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "corgiTracker")
            trackerNode = SCNNode(geometry: trackerPlane)
            
            trackerNode.eulerAngles.x = -.pi/2.0 // make tracker horizontal
            planeIsDetected = true
        }
        trackerNode.position = userPos
        trackerNode.eulerAngles.y = cameraYaw!
        sceneView.scene.rootNode.addChildNode(trackerNode)
        
    }
    
    //MARK: - wolf actions
    func walk(to: SCNVector3, duration: Double) {
//        print("cameraYaw: ", cameraYaw)
//        print("wolf euler: ", wolf.eulerAngles)
        let glkToVec = SCNVector3ToGLKVector3(to)
        let glkWolfPosVec = SCNVector3ToGLKVector3(wolf.position)
        let toDir = SCNVector3FromGLKVector3(GLKVector3Subtract(glkToVec, glkWolfPosVec))
        let startAngle = wolf.eulerAngles.y
        let moveAngle: Float = cameraYaw - .pi/4.0
//        if (startAngle < moveAngle) {
//            moveAngle *= -1
//        }
        let interAngle = startAngle + moveAngle
        let walkAction = SCNAction.sequence([
            SCNAction.customAction(
                duration: duration*0.2,
                action: {(node, elapsedTime) in
//                    let percentage: Float = Float(elapsedTime) / Float(duration*0.2)
//                    node.eulerAngles.y = startAngle + moveAngle * percentage
//                    node.eulerAngles.y = moveAngle
                node.eulerAngles.y = toDir.y
            }),
            SCNAction.move(
                to: to,
                duration: duration*0.6
            ),
            SCNAction.customAction(
                duration: duration*0.2,
                action: {(node, elapsedTime) in
                    let percentage: Float = Float(elapsedTime) / Float(duration*0.2)
//                    node.eulerAngles.y = interAngle - startAngle * percentage
                    node.eulerAngles.y = self.cameraYaw

            })]
        )
        wolf.runAction(walkAction, forKey: "walk_to")
    }
    
    func walk(direction: SCNVector3, duration: Float) {
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
    }
    
    //Mark: - using .scn model
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
        wolf.scale = SCNVector3(WOLF_SCALE, WOLF_SCALE, WOLF_SCALE) // scale down the wolf
        wolf.rotation = SCNVector4(0, 1, 0, cameraYaw)
        wolf.position = userPos
        // Place the wolf a bit "behind" where the user taps
        wolf.localTranslate(by: SCNVector3(0, 0, 0.17*WOLF_SCALE))
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
        
        // Let wolf affected by physics
        wolf.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        wolf.physicsBody?.isAffectedByGravity = false
    }
    

    //MARK: - hit test and tapping
    func getUserPosVec() -> SCNVector3 {
        print("worldPos: ", userPos)
        guard let hitTest = sceneView.hitTest(
            CGPoint(x: CGFloat(userPos.x), y: CGFloat(userPos.z)),
            types: [.featurePoint, .existingPlane]
        )
        .first
        else { return SCNVector3(0, 0, 0) }
        let translation = hitTest.worldTransform.columns.3
        return SCNVector3(translation.x, translation.y, translation.z)
    }
    
    func detectTapCollisionWithWolf(withGestureRecognizer recognizer: UIGestureRecognizer) -> Bool {
        // Use the tap location to determine if on a plane
        let tapLocation = recognizer.location(in: sceneView)
//        sceneView.hitTest(tapLocation, options: [SCNHitTestOption : Any]?)
        return false
    }
    
//    @objc func getScreenTapPosVec(withGestureRecognizer recognizer: UIGestureRecognizer) -> SCNVector3 {
//        // Use the tap location to determine if on a plane
//        let tapLocation = recognizer.location(in: sceneView)
//        guard let hitTest = sceneView.hitTest(
//            tapLocation,
//            types: .existingPlaneUsingExtent
//        ).first
//        else { return SCNVector3(0,0,0) } //TODO: think about failure return behavior
//        let translation = hitTest.worldTransform.columns.3
//        return SCNVector3(translation.x, translation.y, translation.z)
//    }
    
    func getTapGestureRecognizer() -> UITapGestureRecognizer {
        return tapGestureRecognizer!
    }
    
    
    //MARK: - session handlers
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    //MARK: - game state change and game over
    func gameChangeHideToSeek() {
        isSeekMode = true
        resetTimer()
        gameModeLabel.text = "Where's my doggo?"
        
        // Hide the comeHereButton and doneButton!
        comeHereButton.isEnabled = false
        comeHereButton.isHidden = true
        doneButton.isEnabled = false
        doneButton.isHidden = true
    }
    
    func gameOver(){
        //go back to the Home View Controller
        self.dismiss(animated: true, completion: nil)
    }
}
