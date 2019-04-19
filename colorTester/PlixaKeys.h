//
//   ____  _ _           _  __
//  |  _ \| (_)_  ____ _| |/ /___ _   _ ___
//  | |_) | | \ \/ / _` | ' // _ \ | | / __|
//  |  __/| | |>  < (_| | . \  __/ |_| \__ \
//  |_|   |_|_/_/\_\__,_|_|\_\___|\__, |___/
//                                |___/
//
//  PlixaKeys
//  HuedokuPix
//
//  Created by Dave Scruton on 7/28/15.
//  Copyright (c) 2015 huedoku, inc. All rights reserved.
//
//  DHS 8/19:   Add version# meta field
//  DHS 4/1     Add game score

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

 

extern NSString *const _PversionNumberKey;
extern NSString *const _PcaptionTextKey;
extern NSString *const _PuserIDKey;
extern NSString *const _PlocationKey;
extern NSString *const _PfbIDKey;
extern NSString *const _PfbNameKey;
extern NSString *const _PfbFullNameKey;
extern NSString *const _PfbGenderKey;
extern NSString *const _PfbEmailKey;
extern NSString *const _PuniquePuzzleIDKey;
extern NSString *const _PuniquePuzzleStringIDKey;
extern NSString *const _PuserNameKey;
extern NSString *const _PcolorNameKey;
extern NSString *const _PcolorName1Key;
extern NSString *const _PcolorName2Key;
extern NSString *const _PcolorName3Key;
extern NSString *const _PcolorName4Key;
extern NSString *const _PcolorHexKey;
extern NSString *const _Pcolor1HexKey;
extern NSString *const _Pcolor2HexKey;
extern NSString *const _Pcolor3HexKey;
extern NSString *const _Pcolor4HexKey;
extern NSString *const _PcolorPoint1xKey;
extern NSString *const _PcolorPoint1yKey;
extern NSString *const _PcolorPoint2xKey;
extern NSString *const _PcolorPoint2yKey;
extern NSString *const _PcolorPoint3xKey;
extern NSString *const _PcolorPoint3yKey;
extern NSString *const _PcolorPoint4xKey;
extern NSString *const _PcolorPoint4yKey;
extern NSString *const _PuniquePuzzleIDKey;
extern NSString *const _PdifficultyLevelKey;
extern NSString *const _PpuzzleSizeKey;
extern NSString *const _PpuzzlePlayCountKey;
extern NSString *const _PpuzzleHCKey;
extern NSString *const _PpuzzleLPKey;
extern NSString *const _PpuzzleGRKey;
extern NSString *const _PpuzzleYBKey;
extern NSString *const _PimagePNGKey;
extern NSString *const _PuserPortraitKey;

//Like Mechanism...
extern NSString *const _PlikeKey;

//Comment mechanism...
extern NSString *const _PcommentKey;
extern NSString *const _PcommentCountKey;



//User keys...
extern NSString *const _PuserGameTimeKey;
extern NSString *const _PuserGameMovesKey;
extern NSString *const _PuserGameScoreKey;
extern NSString *const _PuserGameLocationKey;
extern NSString *const _PuserGameHCKey;
extern NSString *const _PuserGameLPKey;
extern NSString *const _PuserGameRGKey;
extern NSString *const _PuserGameYBKey;
extern NSString *const _PuserGameScoreKey;

extern NSString *const _PtimestampKey;

//Activity Keys...
extern NSString *const _PfromUserKey;
extern NSString *const _PtoUserKey;
extern NSString *const _PfromNameKey;
extern NSString *const _PtoNameKey;
extern NSString *const _PactivityTypeKey;
extern NSString *const _PactivityCommentKey;


//DHS 20/21: Version number for analytics tracking
extern NSString *const _PversionNumberKey;

//DHS 10/22: FB Login status key
extern NSString *const _PFBLoggedInKey;
//DHS 10/22: App Launch Count key
extern NSString *const _PappOpenedCountKey;
//DHS 10/23 new keys for counters
extern NSString *const _PplayedCountKey;
extern NSString *const _PcreatedCountKey;
extern NSString *const _PphotoCountKey;
extern NSString *const _PfeedCountKey;
extern NSString *const _PsharedCountKey;
extern NSString *const _PsessionPlayedCountKey;
extern NSString *const _PsessionCreatedCountKey;
extern NSString *const _PsessionPhotoCountKey;
extern NSString *const _PsessionFeedCountKey;
extern NSString *const _PsessionSharedCountKey;

//DHS 10/22: Date Installed
extern NSString *const _PinstallDateKey;

//DHS 10/23: Amplitude UUID
extern NSString *const _PampUserIDKey;

//DHS 10/23: Puzzle play counts (local / global?) TbD
extern NSString *const _PpuzzleLocalPlayCountKey;
extern NSString *const _PpuzzleGlobalPlayCountKey;


//DHS 10/23 Filter keys
extern NSString *const _PfilterNameKey;
extern NSString *const _PfilterTypeKey;

//DHS 10/23 CameraVC new keys for analytics
extern NSString *const _PpuzzleSwatchTouchCountKey;
extern NSString *const _PcolorSampleEventCountKey;
extern NSString *const _Pcolor1DecimalKey;
extern NSString *const _Pcolor2DecimalKey;
extern NSString *const _Pcolor3DecimalKey;
extern NSString *const _Pcolor4DecimalKey;

//DHS 10/23 Action key for puzzleVC
extern NSString *const _PpuzzleActionKey;
extern NSString *const _PcommentActionKey;

//DHS 10/23 Size/Diff button touch counts for puzzleVC
extern NSString *const _PsizeButtonTouchCountKey;
extern NSString *const _PdifficultyButtonTouchCountKey;

//DHS 10/23: Counts used by gameVC
extern NSString *const _PpuzzleLocalScrambleCountKey;
extern NSString *const _PpuzzleGlobalScrambleCountKey;
extern NSString *const _PpuzzleLocalFinishCountKey;
extern NSString *const _PpuzzleGlobalFinishCountKey;

//DHS 10/24: Puzzle play scramble counts (local / global?) TBD
extern NSString *const _PpuzzleLocalScrambleCountKey;
extern NSString *const _PpuzzleGlobalScrambleCountKey;

//DHS 10/24: Puzzle play finish counts (local / global?) TBD
extern NSString *const _PpuzzleLocalFinishCountKey;
extern NSString *const _PpuzzleGlobalFinishCountKey;

//DHS 10/24: Puzzle play finish counts (local / global?) TBD
extern NSString *const _PpuzzleLocalCommentCountKey;
extern NSString *const _PpuzzleGlobalCommentCountKey;

//DHS 10/24: Need other arguments for certain events
extern NSString *const _PwhichVCKey;
extern NSString *const _PdotsActionKey;
extern NSString *const _PshakeActionKey;

//DHS 11/9: Add keys for new columns in collection table
extern NSString *const _PcollectionNameKey;
extern NSString *const _PuniqueCollectionIDKey;
extern NSString *const _PcollectionCreationCountKey;
extern NSString *const _PcuratorAmpUserIDKey;
extern NSString *const _PcuratorFbIDKey;
extern NSString *const _PcuratorFbNameKey;
extern NSString *const _PcuratorFbFullNameKey;
extern NSString *const _PcuratorProfileImageKey;

//DHS 12/22: Private column in plixa table
extern NSString *const _PprivateKey;

//DHS 4/4 New activity column
extern NSString *const _PpuzzleInfoKey;

//DHS 11/11: New keys for keeping track of user collection play

extern NSString *const _PpuzzleNumberKey;
extern NSString *const _PbestTimeKey;
extern NSString *const _PworstTimeKey;
extern NSString *const _PbestMovesKey;
extern NSString *const _PworstMovesKey;
extern NSString *const _PbestScoreKey;
extern NSString *const _PworstScoreKey;
extern NSString *const _PscoreKey;
extern NSString *const _PfastestMoveKey;
extern NSString *const _PfirstMoveKey;
extern NSString *const _PfastestColorHexKey;
extern NSString *const _PfastestColorRGBKey;
extern NSString *const _PfirstColorHexKey;
extern NSString *const _PlastColorHexKey;
extern NSString *const _PfirstColorTimeKey;
extern NSString *const _PslowestColorHexKey;


//DHS 6/11: New columns for game statistics
extern NSString *const _PlatestGameObjIDKey;
extern NSString *const _PbestGameTimeObjIDKey;
extern NSString *const _PbestGameMovesObjIDKey;
extern NSString *const _PbestGameScoreObjIDKey;
extern NSString *const _PbestGameTimeKey;
extern NSString *const _PbestGameMovesKey;
extern NSString *const _PbestGameScoreKey;
extern NSString *const _PbestMovesfbNameKey;
extern NSString *const _PbestTimefbNameKey;
extern NSString *const _PbestScorefbNameKey;
extern NSString *const _PbestTimeUserIDAsciiKey;
extern NSString *const _PbestMovesUserIDAsciiKey;
extern NSString *const _PbestScoresUserIDAsciiKey;
extern NSString *const _PlatestUserIDAsciiKey;

//DHS 6/23: Tetrahedron volume (for create analytics in PIX)
extern NSString *const _PtetraVolumeKey;

//DHS 8/6: Debug String for plixa troubleshooting
extern NSString *const _PdebugStringKey;

