//
//   ____  _      _   _ _   _ _
//  |  _ \(_)_  _| | | | |_(_) |___
//  | |_) | \ \/ / | | | __| | / __|
//  |  __/| |>  <| |_| | |_| | \__ \
//  |_|   |_/_/\_\\___/ \__|_|_|___/
//
//
//  PixUtils.h
//  Huedoku Pix
//
//  Created by Dave Scruton on 9/29/15.
//  Copyright (c) 2015 huedoku, inc. All rights reserved.
//
//  DHS 7/20 Added createSystemButton

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#ifdef USE_BRANCH
#import <Branch/Branch.h>
#endif

typedef enum { MVImageFlipXAxis, MVImageFlipYAxis, MVImageFlipXAxisAndYAxis } MVImageFlip;


@interface PixUtils : NSObject
{

}

-(void) pixAlert : (UIViewController *) parent : (NSString *) title : (NSString *) message : (BOOL) yesnoOption;
-(void) offlineAlert : (UIViewController *) parent;
- (UIImage *) getScreenshot;
- (NSString *) getHowLongAgo : (NSDate *) createdAt;
- (unsigned int)intFromHexString:(NSString *) hexStr;
- (UIColor *)colorFromHexString : (NSString *)hexStr;
- (UIImage *)flipit:(MVImageFlip)axis : (UIImage *) inputImg;
- (int) getPackedIntFromColor : (UIColor *) colorin;
- (NSDictionary *) getPressedColorNameWithRecognizer : (UIGestureRecognizer*)recognizer;
- (NSString *) getHexFromColor : (UIColor *) colorin;
- (float) getColorBrightness :  (UIColor *) colorin;
//- (void) showMessage:(NSString*)message withTitle:(NSString *)title;
-(void) mailit : (UIViewController *) parent : (NSString *) subjectLine :
                  (NSString *) sendToAddress : (NSString *) sendToAddress2 :
                    (NSString *) messageBody : (UIImage *)attachedPhoto;


//- (NSString *) breakUpLine : (NSString *)input : (int)columnWidth;
-(UIButton *) createSystemButton : (int) xi : (int) yi : (int) xs : (int) ys :
            (NSString *) fontName : (int)fontSize :
            (UIColor *)tintColor : (UIColor *)bkgdColor :
            (NSString *) labelText;
-(UILabel *) createSystemLabel : (int) xi : (int) yi : (int) xs : (int) ys :
            (NSString *) fontName : (int)fontSize :
            (UIColor *)textColor : (UIColor *)bkgdColor :
            (NSString *) labelText;
-(UIButton *) createCustomButtonBkgd : (int) xi : (int) yi : (int) xs : (int) ys :
            (UIImage *) normal : (UIImage *) highlighted;
-(UIButton *) createCustomButton : (int) xi : (int) yi : (int) xs : (int) ys :
            (UIImage *) normal : (UIImage *) highlighted;

@end
