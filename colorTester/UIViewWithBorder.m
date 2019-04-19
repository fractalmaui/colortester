//
//   _   _ _____     ___              __        ___ _   _     ____                _
//  | | | |_ _\ \   / (_) _____      _\ \      / (_) |_| |__ | __ )  ___  _ __ __| | ___ _ __
//  | | | || | \ \ / /| |/ _ \ \ /\ / /\ \ /\ / /| | __| '_ \|  _ \ / _ \| '__/ _` |/ _ \ '__|
//  | |_| || |  \ V / | |  __/\ V  V /  \ V  V / | | |_| | | | |_) | (_) | | | (_| |  __/ |
//   \___/|___|  \_/  |_|\___| \_/\_/    \_/\_/  |_|\__|_| |_|____/ \___/|_|  \__,_|\___|_|
//
//
//  UIViewWithBorder.m
//  Huedoku Pix
//
//  Created by Dave Scruton on 8/8/15.
//  Copyright (c) 2015 huedoku, inc. All rights reserved.
//  Shows simple uiview with a border.
//    used in color select boxes ...
//  DHS 12/30 Redid border color usage in drawRect

#import "UIViewWithBorder.h"

@implementation UIViewWithBorder

@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;


//==========UIViewWithBorder=========================================================================
- (void)baseInit
{
    _borderColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    _borderWidth  = 3;
    _fborderWidth = 0.0;
    _zebra        = FALSE;
}

//==========UIViewWithBorder=========================================================================
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

//==========UIViewWithBorder=========================================================================
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}



//==========UIViewWithBorder=========================================================================
- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Set the border width
    //DHS 12/29 float width too...
    if (_fborderWidth != 0.0) //Float value set? use it
        CGContextSetLineWidth(contextRef,_fborderWidth);
    else  //udderwise use int width...
        CGContextSetLineWidth(contextRef,_borderWidth);
    
    // Set the border color...
    CGFloat red, green, blue, alpha;
    [_borderColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(contextRef, red,green,blue,alpha);

    // Draw the border along the view edge
    CGContextStrokeRect(contextRef, rect);
    //Zebra? Add contrasting inner border
    if (_zebra)
    {
        //NSLog(@" draw zebra...");
        red   = 1.0 - red;
        green = 1.0 - green;
        blue  = 1.0 - blue;
        CGContextSetRGBStrokeColor(contextRef, red,green,blue,alpha);
        CGRect rect2 = CGRectMake(rect.origin.x+_borderWidth, rect.origin.y+_borderWidth, rect.size.width-2*_borderWidth, rect.size.height-2*_borderWidth);
        CGContextStrokeRect(contextRef, rect2);
    }
    


}


@end
