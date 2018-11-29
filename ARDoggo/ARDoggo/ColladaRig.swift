//
//  ColladaRig.swift
//  ARDoggo
//
//  Created by Oliver Dew on 15/06/2016.
//  https://github.com/Utsira/RunningMan
//  Modified by JJ Lim on 11/15/18
//  Copyright © 2016 Salt Pig. All rights reserved.
import SceneKit
import Foundation

class ColladaRig {
    let modelNode: SCNNode
    var animations = [String: CAAnimation]()
    
    //TODO: take in min and max
    init(modelNamed: String, daeNamed: String, position: SCNVector3) {
        let sceneSource = ColladaRig.getSceneSource(daeNamed: daeNamed)
//        print("sceneSource: ", sceneSource)
//        print(SCNNode.self)
//        print(sceneSource.identifiersOfEntries(withClass: SCNNode.self))
        modelNode = sceneSource.entryWithIdentifier(modelNamed, withClass: SCNNode.self)!
        
        //Find and add the armature
        
        let armature = sceneSource.entryWithIdentifier("Wolf_obj_body", withClass: SCNNode.self)!
        //In some Blender output DAE, animation is child of armature, in others it has no child. Not sure what causes this. Hence:
        armature.removeAllAnimations()
        modelNode.addChildNode(armature)
        
        //store and trigger the "rest" animation
        loadAnimation(withKey:"run2", daeNamed: daeNamed)
        playAnimation(named:"rest") // do nothing if no rest
        
        //position node on ground
        var min = SCNVector3(position.x - 1.0, position.y - 1.0, position.z - 1.0)
        var max = SCNVector3(position.x + 1.0, position.y + 1.0, position.z + 1.0)
        
//        modelNode.boundingBox = (min, max) // TODO: would this work?

//        modelNode.position = SCNVector3(position.x, position.y, position.z)
        modelNode.position = position
//        print("modelNode.position: ", modelNode.position)
//        modelNode.localTranslate(by: SCNVector3(0, 0, -3)) // Place the wolf a bit "behind" where the user taps
//        modelNode.position = SCNVector3(0, -min.y, 0)

    }
    
    static func getSceneSource(daeNamed: String) -> SCNSceneSource {
        let collada = Bundle.main.url(forResource: daeNamed, withExtension: "dae", subdirectory: "art.scnassets")!
//        print(collada)
//        let collada = Bundle.main.resourceURL("art.scnassets/\(daeNamed)", withExtension: "dae")!
//        let collada = Bundle.mainBundle().URLForResource("art.scnassets/\(daeNamed)", withExtension: "dae")!
//        return SCNSceneSource(URL: collada, options: nil)!
        return SCNSceneSource(url: collada, options: nil)!
    }
    
    func loadAnimation(withKey: String, daeNamed: String, fade: CGFloat = 0.3){
        let sceneSource = ColladaRig.getSceneSource(daeNamed: daeNamed)
//        print("CAAnimation identifiers of entries ",sceneSource.identifiersOfEntries(withClass: CAAnimation.self))
        let animation = sceneSource.entryWithIdentifier("animation/1", withClass: CAAnimation.self)!
        
        // animation.speed = 1
        animation.fadeInDuration = fade
        animation.fadeOutDuration = fade
        // animation.beginTime = CFTimeInterval( fade!)
        animations[withKey] = animation
    }
    
    func playAnimation(named: String){ //also works for armature
        if let animation = animations[named] {
            modelNode.addAnimation(animation, forKey: named)
        }
    }
    
    func walk() {
        modelNode.animationPlayer(forKey: "rest")?.paused = true
//        node.pauseAnimationForKey("rest") ----> node.pauseAnimation(forKey: "rest")
//
        //  node.removeAnimationForKey("rest", fadeOutDuration: 0.3)
        playAnimation(named: "walk")
    
        let run = SCNAction.repeatForever( SCNAction.moveBy(x: 0, y: 0, z: 12, duration: 1))
        run.timingMode = .easeInEaseOut //ease the action in to try to match the fade-in and fade-out of the animation
        modelNode.runAction(run, forKey: "walk")
    }
    
    func stopWalking() {
        modelNode.animationPlayer(forKey: "rest")?.setValue(false, forKeyPath: "paused")
        
        //   node.addAnimation(animations["rest"]!, forKey: "rest")
        modelNode.removeAnimation(forKey: "walk")
        modelNode.removeAction(forKey: "walk")
        
//        node.removeAnimationForKey("walk", fadeOutDuration: 0.3)
//        node.removeActionForKey("walk")
    }
}



//gestureRecognizers: Optional([
//<UILongPressGestureRecognizer: 0x1042192f0; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handlePress:, target=<SCNCameraNavigationController 0x104218f90>)>>, <UIPanGestureRecognizer: 0x1042197d0; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handlePan:, target=<SCNCameraNavigationController 0x104218f90>)>>,
//<UITapGestureRecognizer: 0x2828fee00; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handleDoubleTap:, target=<SCNCameraNavigationController 0x104218f90>)>; numberOfTapsRequired = 2>, <UIPinchGestureRecognizer: 0x104219660; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handlePinch:, target=<SCNCameraNavigationController 0x104218f90>)>>,
//<UIRotationGestureRecognizer: 0x104219950; state = Possible; enabled = NO; cancelsTouchesInView = NO; view = <ARSCNView 0x104211f50>; target= <(action=_handleRotation:, target=<SCNCameraNavigationController 0x104218f90>)>>, <UITapGestureRecognizer: 0x2828f5b00; state = Ended; view = <ARSCNView 0x104211f50>; target= <(action=addColladaModelToSceneViewWithGestureRecognizer:, target=<ARDoggo.ViewController 0x104210110>)>>])


//CAAnimation identifiers of entries  [
//  "animation/1", "keyframedAnimations/1", "keyframedAnimations/2", "keyframedAnimations/3", "keyframedAnimations/4", "keyframedAnimations/5", "keyframedAnimations/6", "keyframedAnimations/7", "keyframedAnimations/8", "keyframedAnimations/9", "keyframedAnimations/10", "keyframedAnimations/11", "keyframedAnimations/12", "keyframedAnimations/13", "keyframedAnimations/14", "keyframedAnimations/15", "keyframedAnimations/16", "keyframedAnimations/17", "keyframedAnimations/18", "keyframedAnimations/19", "keyframedAnimations/20", "keyframedAnimations/21", "keyframedAnimations/22", "keyframedAnimations/23", "keyframedAnimations/24", "keyframedAnimations/25", "keyframedAnimations/26", "keyframedAnimations/27", "keyframedAnimations/28", "keyframedAnimations/29", "keyframedAnimations/30", "keyframedAnimations/31", "keyframedAnimations/32", "keyframedAnimations/33", "keyframedAnimations/34", "keyframedAnimations/35", "keyframedAnimations/36", "keyframedAnimations/37", "keyframedAnimations/38", "keyframedAnimations/39", "keyframedAnimations/40", "keyframedAnimations/41", "keyframedAnimations/42", "keyframedAnimations/43", "keyframedAnimations/44", "keyframedAnimations/45"]

//animations:  Optional(["run2": <CAAnimationGroup:0x280569f80;
//animations = (
//"SCN_CAKeyframeAnimation 0x280a09c80 (duration=1.666667, keyPath:/Becken.transform)",
//"SCN_CAKeyframeAnimation 0x280a09ce0 (duration=1.666667, keyPath:/Bauch.transform)",
//"SCN_CAKeyframeAnimation 0x280a09d70 (duration=1.666667, keyPath:/Bauch.001.transform)",
//"SCN_CAKeyframeAnimation 0x280a09dd0 (duration=1.666667, keyPath:/Brust.transform)",
//"SCN_CAKeyframeAnimation 0x280a09e90 (duration=1.666667, keyPath:/Hals.transform)",
//"SCN_CAKeyframeAnimation 0x280a09f20 (duration=1.666667, keyPath:/Kopf.002.transform)",
//"SCN_CAKeyframeAnimation 0x280a09f80 (duration=1.666667, keyPath:/Kopf.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a040 (duration=1.666667, keyPath:/Unterkiefer.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a0d0 (duration=1.666667, keyPath:/Hals_fett.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a160 (duration=1.666667, keyPath:/Maulunten.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a1f0 (duration=1.666667, keyPath:/Mauloben.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a280 (duration=1.666667, keyPath:/MundW_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a310 (duration=1.666667, keyPath:/MundW_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a3a0 (duration=1.666667, keyPath:/Aug_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a430 (duration=1.666667, keyPath:/aug_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a4c0 (duration=1.666667, keyPath:/Ohr_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a550 (duration=1.666667, keyPath:/Ohr_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a5e0 (duration=1.666667, keyPath:/Braun_O_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a670 (duration=1.666667, keyPath:/Braun_O_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a700 (duration=1.666667, keyPath:/aug_lied_O_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a790 (duration=1.666667, keyPath:/aug_lied_O_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a820 (duration=1.666667, keyPath:/aug_lied_U_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a8b0 (duration=1.666667, keyPath:/aug_lied_U_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a940 (duration=1.666667, keyPath:/Bauch.003.transform)",
//"SCN_CAKeyframeAnimation 0x280a0a9a0 (duration=1.666667, keyPath:/Schalterplatte_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0aa60 (duration=1.666667, keyPath:/Oberarm_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0ab20 (duration=1.666667, keyPath:/Unterarm_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0abb0 (duration=1.666667, keyPath:/Vorderpfote_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0ac40 (duration=1.666667, keyPath:/Schalterplatte_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0acd0 (duration=1.666667, keyPath:/Oberarm_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0ad90 (duration=1.666667, keyPath:/Unterarm_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0ae20 (duration=1.666667, keyPath:/Vorderpfote_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0aeb0 (duration=1.666667, keyPath:/Schwanz.transform)",
//"SCN_CAKeyframeAnimation 0x280a0af40 (duration=1.666667, keyPath:/Schwanz.001.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d380 (duration=1.666667, keyPath:/Schwanz.002.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d1a0 (duration=1.666667, keyPath:/Schwanz.003.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d260 (duration=1.666667, keyPath:/Oberschenkel_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d320 (duration=1.666667, keyPath:/Unterschenkel_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d470 (duration=1.666667, keyPath:/Pfote1_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d530 (duration=1.666667, keyPath:/Pfote2_L.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d5c0 (duration=1.666667, keyPath:/Oberschenkel_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d650 (duration=1.666667, keyPath:/Unterschenkel_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d710 (duration=1.666667, keyPath:/Pfote1_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d7d0 (duration=1.666667, keyPath:/Pfote2_R.transform)",
//"SCN_CAKeyframeAnimation 0x280a0d860 (duration=1.666667, keyPath:/root.transform)"
//);
//SCNAnimationEventsKey = (null); fillMode = both; SCNAnimationAnimatesUsingSceneTimeKey = false; SCNAnimationCommitOnCompletion = false; removedOnCompletion = 1; SCNAnimationFadeOutDurationKey = 0.30000001192092896; SCNAnimationFadeInDurationKey = 0.30000001192092896; speed = 1; timeOffset = 0; beginTime = 0; autoreverses = 0; repeatCount = inf; duration = 1.66667>])
