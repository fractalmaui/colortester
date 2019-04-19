//
//   __  __                   _  __ _         __     ___
//  |  \/  | __ _  __ _ _ __ (_)/ _(_) ___ _ _\ \   / (_) _____      __
//  | |\/| |/ _` |/ _` | '_ \| | |_| |/ _ \ '__\ \ / /| |/ _ \ \ /\ / /
//  | |  | | (_| | (_| | | | | |  _| |  __/ |   \ V / | |  __/\ V  V /
//  |_|  |_|\__,_|\__, |_| |_|_|_| |_|\___|_|    \_/  |_|\___| \_/\_/
//                |___/
//
//
//  MagnifierView.m
//
//  DHS 4/20 Cut and paste-coded from stackoverflow in the best DHS tradition
//

#import "MagnifierView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MagnifierView
@synthesize viewToMagnify;
@dynamic touchPoint;

//=======<Magnifying Glass (from web)>==================================
- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame radius:70];
} //end initWithFrame

//=======<Magnifying Glass (from web)>==================================
- (id)initWithFrame:(CGRect)frame radius:(int)r {
    int radius = r;
    //NSLog(@" init with radius %d",r);
    
    if ((self = [super initWithFrame:CGRectMake(0, 0, radius, radius)])) {
        //Make the layer circular.
        self.layer.cornerRadius = radius *0.5;
        self.layer.masksToBounds = YES;
        _xoff = _yoff = 0;
    }
    
    return self;
} //end initWithFrame

//=======<Magnifying Glass (from web)>==================================
- (void)setTouchPoint:(CGPoint)pt {
    //NSLog(@" set touchpoint %f %f",pt.x,pt.y);
    touchPoint = pt;
    // whenever touchPoint is set, update the position of the magnifier (to just above what's being magnified)
    // WTF? THIS is being ignored!!
    // The horizontal and vertical offsets are WEIRD,
    //   don't understand what's going on!
    // They are based on the parent view,
    //   NOT the photo view in the center of the UI!
    if (_gotiPad)
        self.center = CGPointMake(pt.x+130, pt.y+60);
    else
        self.center = CGPointMake(pt.x+9, pt.y+50);
    
} //end setTouchPoint

//=======<Magnifying Glass (from web)>==================================
- (CGPoint)getTouchPoint {
    return touchPoint;
} //end getTouchPoint

//=======<Magnifying Glass (from web)>==================================
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGImageRef mask = [UIImage imageNamed: @"loupe-mask@2x.png"].CGImage;
    UIImage *glass  = [UIImage imageNamed: @"magtarg.png"];
    
    //NSLog(@" drawrect center xy %f %f",self.center.x,self.center.y);
    CGContextSaveGState(context);
    CGContextClipToMask(context, bounds, mask);
    CGContextFillRect(context, bounds);
    CGContextScaleCTM(context, 3, 3); //DHS was 1.2,1.2
//    CGContextScaleCTM(context, 5, 5); //DHS was 1.2,1.2
    
    //draw your subject view here
    float xxf = 1*(self.frame.size.width*0.45);
    float yyf = 1*(self.frame.size.height*0.45);
    
    //NSLog(@" context trans xy %f %f",self.frame.size.width*0.45,self.frame.size.height*0.45);
    CGContextTranslateCTM(context,xxf,yyf);
//    CGContextTranslateCTM(context,1*(self.frame.size.width*0.45),1*(self.frame.size.height*0.45));
    //CGContextScaleCTM(context, 1.5, 1.5);
    //DHS WHY ARE THESE TWO SO SQUIRRELEY???
    //X -1.25: Magnifying glass is 2 pixels to left of point  -1.2 it's 5 pixels left -1.15 its to the right now

    float xf,yf;
    //CLUGE! This probably is H/W dependent!!
    xf = -1.0*(touchPoint.x) - 25.0f + (float)_xoff;
    yf = -1.0*(touchPoint.y) - 25.0f + (float)_yoff;
   //NSLog(@" xyf adjust %f %f",xf,yf);
    //    xf = -1.0*(touchPoint.x) - 49.0f;
//    yf = -1.0*(touchPoint.y) - 49.0f;
    //NSLog(@" magglass xf yf %f %f",xf,yf);
    CGContextTranslateCTM(context,xf,yf);
//    CGContextTranslateCTM(context,-1*(touchPoint.x),-1*(touchPoint.y));
    [self.viewToMagnify.layer renderInContext:context];
    
    CGContextRestoreGState(context);
    [glass drawInRect: bounds];
} //end drawRect

//=======<Magnifying Glass (from web)>==================================
- (void)dealloc {
   // [viewToMagnify release];
   // [super dealloc];
}

@end
