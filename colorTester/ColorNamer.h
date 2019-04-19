//
//    ____      _            _   _
//   / ___|___ | | ___  _ __| \ | | __ _ _ __ ___   ___ _ __
//  | |   / _ \| |/ _ \| '__|  \| |/ _` | '_ ` _ \ / _ \ '__|
//  | |__| (_) | | (_) | |  | |\  | (_| | | | | | |  __/ |
//   \____\___/|_|\___/|_|  |_| \_|\__,_|_| |_| |_|\___|_|
//
//
//  ColorNamer.h
//  HuedokuPix
//
//  Created by Zachary Tousignant on 7/29/15.
//  Copyright (c) 2015 Zachary Tousignant. All rights reserved.
//  DHS 7/31/15: Made into independent object

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PixUtils.h"
@interface ColorNamer : NSObject
{
    NSString *dbhome;
    NSString *home;
    int stride;
    int linecount;
    PixUtils *putils;

}
- (NSString *)getNameFromUIColor: (UIColor *) colorin;
- (NSString *)getNameFromHex:     (NSString*) hex;
- (UIColor*) getColorFromName : (NSString *) input;

//DHS 5/23 make a singleton...
+ (id)sharedInstance;


@end

