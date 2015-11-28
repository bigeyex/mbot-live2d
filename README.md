# mbot-live2d

This iOS App will display a virtual avartar which you can talk to. It can also connect to a Makeblock mBot (via bluetooth): 
Upon hearing specific command such as "forward", "backward" and "turn", it will command mBot to perform corresponding actions.

This XCode project includes:
- a mBot bluetooth control program
- a live-2d virtual avatar
- a voice-based dialog engine powered by iFlytech API and SimSimi/Tuling Robot.


## How To Build

- open mbot-live2d.xcworkspace, that's the main project.
- register a [iFlyTech](http://www.xfyun.cn/) api account; download tts and iat sdk, 
replace the one in /sample/mbot-live2d/iflyMSC.framework with what you just downloaded.
- replace iFlyTech api key in MainViewController/ViewController.mm
- register a [SimSimi](http://developer.simsimi.com/) api account.
- replace url and json parse code in SimSimi/MBSimSimiRequestDelegate.m

## Project Structure

- MainViewController: the primary view controller and Live2D related code/resource files.
- iFlytechVoice: related to voice recognition and text-to-speech. You may be interested in MBTTSDelegate.m / MBRecognizerDelegate.m.
- SimSimi: related to AI dialog apis.
- MBotLibrary: library related with bluetooth and mBot controlling.
- MBotController: actual code used to control a mbot.
