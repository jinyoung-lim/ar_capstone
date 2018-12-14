<img align="right" width="130" height="130" src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/Assets.xcassets/AppIcon.appiconset/Icon-180.png">

# Where Is My Doggo     

This is an iOS app that two players to play hide and seek with an AR dog interactively. It is a final project for COMP465: Interactive Computer Graphics at Macalester College.

## Instllation
Please fork this repository and use XCode to build. The app requires iOS 11.4 or later and uses ARKit, SceneKit, and Swift.
Swift version is unspecified but you might need XCode 10.1 or later.

Doggo ate all the treats that your friend hid in the cabinet! Your friend is coming back soon. You do not want Doggo to get yelled at because you LOVE Doggo! You have no choice but to hide Doggo before your friend comes back!


## Premise & How to Play
Doggo ate all the treats that your friend hid in the cabinet!
Let's start the game by pressing the start button.

### Hide


<p align="center">
  <img src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/HowToPlayGifs/1_press_start.gif" width="200"/>
</p>
<p align="center">
  Press "START" to start the game
<p align="center">

The alert explains the premise of the game and also why you are trying to hide Doggo. It goes like this... Your friend is coming back soon. You do not want Doggo to get yelled at because you LOVE Doggo! You have no choice but to hide Doggo before your friend comes back!

Press "Yes!" to start hiding Doggo. Notice that the timer goes off. The default time is 100 seconds. You have to hide Doggo before the time runs out! The square tracker node shows you where Doggo would be placed. When you are ready, tap on the screen to place Doggo. If the tracker node is not showing or too big/small, move your phone toward you and then away from you slowly a few times. This helps detecting horizontal planes.

<p align="center">
  <img src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/HowToPlayGifs/2_place_doggo.gif" width="200"/>
</p>
<p align="center">
  Tap on the screen to place Doggo
<p align="center">

Once you place Doggo, use the left button ("Come Here button") to hide Doggo. Come Here button moves Doggo come in front of you. As of now, Where Is My Doggo does not support occlusion. Even if you hide Doggo behind a wall, Doggo can be seen through the wall. Be aware of this when you hide Doggo!

<p align="center">
  <img src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/HowToPlayGifs/4_hide_with_comeherebutton.gif" width="200"/>
</p>
<p align="center">
  Use Come Here Button to hide Doggo
<p align="center">

If you finish hiding Doggo before the time runs out, press the right button (Done Button) to end the hide mode. Then, give your phone to your friend!

### Seek

You come home to find out that Doggo ate all the treats that you hid in the cabinet. You have to teach Doggo that it is not ok to steal things! As a dog person, you know you have to teach dogs as soon as possible after they do something wrong because dogs forget what they did wrong if you are too late! Start looking for Doggo by pressing "Yes!"

<p align="center">
  <img src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/HowToPlayGifs/5_ready_to_seek.gif" width="200"/>
</p>
<p align="center">
  Press "Yes!" to start finding Doggo
<p align="center">

Once you get into the seek mode, you will have the same amount of time to find Doggo. The default time is 100 seconds. If you find Doggo, tap on it to win the game!

<p align="center">
  <img src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/HowToPlayGifs/6_found_doggo.gif" width="200"/>
</p>
<p align="center">
  Find and tap Doggo to win the game
<p align="center">
  
  
If time runs out before you find Doggo AND TAP it, you loose the game!
<p align="center">
  <img src="https://github.com/jlim2/ar_capstone/blob/master/ARDoggo/ARDoggo/HowToPlayGifs/7_didnt_find_doggo.gif" width="200"/>
</p>
<p align="center">
  Lose game if time runs out before you find and tap Doggo
<p align="center">


## Architecture

## Issues
### Will Fix

## Won't Fix
