//
//   _   _ _____     ___              __        ___ _   _     ____                _
//  | | | |_ _\ \   / (_) _____      _\ \      / (_) |_| |__ | __ )  ___  _ __ __| | ___ _ __
//  | | | || | \ \ / /| |/ _ \ \ /\ / /\ \ /\ / /| | __| '_ \|  _ \ / _ \| '__/ _` |/ _ \ '__|
//  | |_| || |  \ V / | |  __/\ V  V /  \ V  V / | | |_| | | | |_) | (_) | | | (_| |  __/ |
//   \___/|___|  \_/  |_|\___| \_/\_/    \_/\_/  |_|\__|_| |_|____/ \___/|_|  \__,_|\___|_|
//
//
//  UIViewWithBorder.h
//  Huedoku Pix
//
//  Created by Dave Scruton on 8/8/15.
//  Copyright (c) 2015 huedoku, inc. All rights reserved.
//
//  DHS 12/29 Added fborderwidth

#import <UIKit/UIKit.h>


@interface UIViewWithBorder : UIView

{
    
}

@property (nonatomic, assign) int borderWidth;
@property (nonatomic, assign) int fborderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL zebra;


@end

