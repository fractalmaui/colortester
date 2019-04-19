//
//   ____       _                 _____ _
//  |  _ \  ___| |__  _   _  __ _|  ___| | __ _  __ _ ___
//  | | | |/ _ \ '_ \| | | |/ _` | |_  | |/ _` |/ _` / __|
//  | |_| |  __/ |_) | |_| | (_| |  _| | | (_| | (_| \__ \
//  |____/ \___|_.__/ \__,_|\__, |_|   |_|\__,_|\__, |___/
//                          |___/               |___/
//
//  DebugFlags.h
//  Huedoku Pix
//
//  Created by Dave Scruton on 7/12/16.
//  Copyright © 2016 huedoku, inc. All rights reserved.
//
//  Put across-the-app flags here to turn on/off debug features
//    add the #import statement right above object's #import in the .m file
//  12/10 Removed OFFLINE_ENABLED: defunct

#ifndef DebugFlags_h
#define DebugFlags_h



#define FEED_IS_MAINVC //DHS 6/12/18


// Disable/Enable sfx loading/playing
#define USE_SFX

//sets up round portraits throughout the app: 50% makes a nice circle...
#define PORTRAIT_PERCENT 50

// Unset this to show IB UI element backgrounds in bright colors,
//   this is useful to make sure everything fits and doesn't collide
#define CLEAR_BACKGROUNDS

//For testing at karls
#define NOLOW_BANDWIDTH

//This turns on things like version numbers in UI's
#define NODEBUG_VERSION
#define NODEBUG_VERBOSE

//Switch this on to use the new AWS/Mongo stuff...
#define NOMONGODB_VERSION
#define SASHIDODB_VERSION


#define NORECORD_PLAY

//DHS 8/6 Add followig
#define NOFOLLOWING_ON

//This switch affects feedVC, and feedCell
#define FACEBOOK_ADVERTISING_ON
#define NOBENJAMIN_ADVERTISING_ON

//Controls "smoosh" animation in puzzleVC and gameVC
#define SMOOSH_ON


#define USEAWS

#define NODUMPPREFSBUNDLE

#define NOUSELOCALDATASTORE

#endif /* DebugFlags_h */
