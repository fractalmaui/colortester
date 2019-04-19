//
//   ____  _      _   _ _   _ _
//  |  _ \(_)_  _| | | | |_(_) |___
//  | |_) | \ \/ / | | | __| | / __|
//  |  __/| |>  <| |_| | |_| | \__ \
//  |_|   |_/_/\_\\___/ \__|_|_|___/
//
//  PixUtils.m
//  Huedoku Pix
//
//  Created by Dave Scruton on 9/29/15.
//  Copyright (c) 2015 huedoku, inc. All rights reserved.
//
//  Miscellaneous functions used all over the place...
//    (should this be a singleton?)
//  5/3: add nil checks in getHexFromColor
//  DHS 7/16 Add getColorBrightness
//  DHS 7/20 Added createSystemButton
//  DHS 7/31 Added localization getHowLongAgo
//  DHS 2/17 Added getPressedColorNameWithRecognizer from feedVC
//  DHS 7/19 Modified pixAlert to handle nil parent
//  DHS 10/19: Updated NSLocalization strings...
//  DHS 2/15/18 Added offlineAlert
//  DHS 2/25  Added flipit from lilbitmap
#import "DebugFlags.h"
#import "PixUtils.h"
#import "PlixaKeys.h"
@implementation PixUtils

#define INV255 0.00392156


//============================================================================
// math stuff...
double drand(double lo_range,double hi_range ); // defined in SynthDave.m

//======(PixUtils)==========================================
// PuzzleID is stored on parse. There must be one unique ID per puzzle, across all platforms.
-(instancetype) init
{
    if (self = [super init])
    {
    }
    return self;
} //end init

//======(PixUtils)==========================================
-(void) offlineAlert:(UIViewController *)parent
{
    [self pixAlert:parent : NSLocalizedString(@"Cannot find Internet", nil) :
     NSLocalizedString(@"It Looks like the Network is Down, Please Try Again Later", nil) : false];
    return;
}

//======(PixUtils)==========================================
//This should really be in PFUTils
-(void) mailit : (UIViewController *) parent : (NSString *) subjectLine :
                  (NSString *) sendToAddress : (NSString *) sendToAddress2 :
                    (NSString *) messageBody : (UIImage *)attachedPhoto
{
    // NSLog(@" mailit  parent %@",shakerParent);
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    //DHS 5/8 need version for email subject line...
    NSString *bv =   [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    // which delegate to use??
    mailController.mailComposeDelegate = parent;
    if ([MFMailComposeViewController canSendMail])
    {
        //ok get current date and use it in the subject line....
        NSString* subject;
        [mailController setToRecipients:[NSArray arrayWithObjects:sendToAddress,nil]];
        if (sendToAddress2 != nil) //DHS 7/20 add 2nd addy...
            [mailController setToRecipients:[NSArray arrayWithObjects:sendToAddress,sendToAddress2,nil]];
        else
            [mailController setToRecipients:[NSArray arrayWithObjects:sendToAddress,nil]];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:MM:SS"];
        //Set subject line...
        subject = [NSString stringWithFormat : @"%@ [%@]",subjectLine,bv]; //DHS 5/8
        //subject = [subject stringByAppendingString: datestr];
        [mailController setSubject:subject];
        [mailController setMessageBody:messageBody isHTML:NO];
        
        if (attachedPhoto != nil)
        {
            // Create NSData object as PNG image data from camera image
            NSData *data = UIImagePNGRepresentation(attachedPhoto);
            // Attach image data to the email
            [mailController addAttachmentData:data mimeType:@"image/png" fileName:@"PuzzleImage"];
        }
        
        
        [parent presentViewController:mailController animated:YES completion:nil];
    }
} //end  mailit

//======(PixUtils)==========================================
-(void) pixAlert : (UIViewController *) parent : (NSString *) title : (NSString *) message : (BOOL) yesnoOption
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    if (yesnoOption)
    {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
        [alert addAction:yesButton];
        [alert addAction:noButton];
    }
    else //Just put up OK?
    {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
       
        [alert addAction:yesButton];
    }
    if (parent == nil) //Invoked from a non-UI object?
    {
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alert animated:YES completion:nil];
    }
    else
        [parent presentViewController:alert animated:YES completion:nil];
    
}

//=====lilBitmap============================
- (UIImage *)flipit:(MVImageFlip)axis : (UIImage *) inputImg
{
    UIGraphicsBeginImageContext(inputImg.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(axis == MVImageFlipXAxis){
        // Do nothing, X is flipped normally in a Core Graphics Context
    } else if(axis == MVImageFlipYAxis){
        // fix X axis
        CGContextTranslateCTM(context, 0, inputImg.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        // then flip Y axis
        CGContextTranslateCTM(context, inputImg.size.width, 0);
        CGContextScaleCTM(context, -1.0f, 1.0f);
    } else if(axis == MVImageFlipXAxisAndYAxis){
        // just flip Y
        CGContextTranslateCTM(context, inputImg.size.width, 0);
        CGContextScaleCTM(context, -1.0f, 1.0f);
    }
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, inputImg.size.width, inputImg.size.height), [inputImg CGImage]);
    
    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flipedImage;
} //end flipit



//======(PixUtils)==========================================
- (int) getPackedIntFromColor : (UIColor *) colorin
{
    int packedColor = 0;
    if (colorin == nil) return packedColor;
    const CGFloat* components = CGColorGetComponents(colorin.CGColor);
    if (components == nil) return packedColor;
    packedColor = ((int)(255.0*components[0])<<16) + ((int)(255.0*components[1])<<8) + ((int)(255.0*components[2]));
    return packedColor;
} //end getPackedIntFromColor

//======(PixUtils)==========================================
- (NSString *) getHexFromColor : (UIColor *) colorin
{
    if (colorin == nil) return @"000000"; //DHS 5/3: Try to address crash
    const CGFloat* components = CGColorGetComponents(colorin.CGColor);
    if (components == nil) return @"000000"; //DHS 5/3: Try to address crash
    //NSLog(@"Red: %f", components[0]);
    //NSLog(@"Green: %f", components[1]);
    //NSLog(@"Blue: %f", components[2]);
    NSString *hexout = [NSString stringWithFormat:@"%2.2x%2.2x%2.2x",  //CRASHLYTICS: Crash here: invalid address
                        (int)(256.0*components[0]),
                        (int)(256.0*components[1]),
                        (int)(256.0*components[2])
                        ];
    
    return hexout;
} //end getHexFromColor

//======(PixUtils)==========================================
- (float) getColorBrightness :  (UIColor *) colorin
{
    if (colorin == nil) return 0.0;
    const CGFloat* components = CGColorGetComponents(colorin.CGColor);
    float brightness =  0.33333*(components[0]+components[1]+components[2]);
    return brightness;
} //end getColorBrightness


//======(PixUtils)==========================================
-(UIImage *)getScreenshot
{
    //NSLog(@" PixUtils: getSS");
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef lcontext = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:lcontext];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
} //end getScreenshot

//==========FeedVC=========================================================================
// SHIT! move this to utils!!!
-(NSDictionary *) getPressedColorNameWithRecognizer : (UIGestureRecognizer*)recognizer
{
    //get view
    UITextView *textView = (UITextView *)recognizer.view;
    //get location
    CGPoint location = [recognizer locationInView:textView];
    UITextPosition *tapPosition = [textView closestPositionToPoint:location];
    UITextPosition* beginning = textView.beginningOfDocument;
    UITextRange *textRange = [textView.tokenizer rangeEnclosingPosition:tapPosition withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    NSArray *colorNames;
    colorNames    = [textView.text componentsSeparatedByString:@","];
    UITextPosition * startpos = textRange.start;
    int loko = (int)[textView offsetFromPosition:beginning toPosition:startpos];
    int whichColor = -1;
    int lastcomma = 0;
    for(int loop=0;loop<colorNames.count;loop++)
    {
        int nextlen = 1 + (int)[[colorNames objectAtIndex:loop] length];
        if (loko < lastcomma + nextlen)
        {
            whichColor = loop;
            break;
        }
        lastcomma += nextlen;
    }
    if (whichColor < 0) whichColor = 0;
    if (whichColor > 3) whichColor = 3;
    NSString *colorNameFound = [colorNames objectAtIndex:whichColor];
    if (whichColor == 0)
    {
        NSString *wstr = [colorNameFound substringWithRange:NSMakeRange(0, [colorNameFound length])];
        // pull out substring from the list of color names..
        colorNameFound = [NSString stringWithFormat:@" %@",wstr] ;
        // ..clean up string, get rid of stuff at the end...
        colorNameFound = [colorNameFound stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    }
    if (whichColor == 3) //Look out for ending bracket!
    {
        colorNameFound = [colorNameFound stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:whichColor] , @"colorNameIndex",
                                 colorNameFound , @"selectedColorName",
                                                  nil];
} //end getPressedColorNameWithRecognizer



//==========FeedVC=========================================================================
-(NSString *) getHowLongAgo : (NSDate *) createdAt;
{
    
    //GET # OF DAYS since...
    NSDateFormatter *df = [NSDateFormatter new];
    //DHS 8/17 needed HH:mm:ss to get better interval calc.
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzzZ"];
    NSString *TodayString = [df stringFromDate:[NSDate date]];
    NSString *TargetDateString = [df stringFromDate:createdAt];
    //DHS 8/9: Fixed, args were backwards
    NSTimeInterval time = [[df dateFromString:TodayString] timeIntervalSinceDate:[df dateFromString:TargetDateString]];
    
    int days = time / 60 / 60/ 24;
    NSString *daysAgoString = NSLocalizedString(@"Just Now",nil);
    if (days == 0)
    {
        int hours = time / 60 / 60;
        if (hours == 0)
        {
            int minutes = time/60;
            if (minutes == 1)
                daysAgoString = NSLocalizedString(@"A minute ago",nil);
            else if (minutes > 1)
            {
                daysAgoString = [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago",nil),minutes];
            }
        }
        else if (hours == 1)
        {
            daysAgoString = NSLocalizedString(@"An hour ago",nil);
        }
        else
        {
            daysAgoString = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago",nil),hours];
        }
    }
    else if (days == 1) daysAgoString = NSLocalizedString(@"yesterday",nil);
    else if (days > 1) daysAgoString = [NSString stringWithFormat:NSLocalizedString(@"%d days ago",nil),days];
    else if (days > 30)
    {
        if (days < 60) daysAgoString = NSLocalizedString(@"a month ago",nil);
        else daysAgoString = [NSString stringWithFormat:NSLocalizedString(@"%d months ago",nil),days/30];
    }
    
    return daysAgoString;
} //end getHowLongAgo


//=====<HDKGenerate>======================================================================
- (unsigned int)intFromHexString:(NSString *) hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}   //end intFromHexString

//=====<HDKGenerate>======================================================================
- (UIColor *)colorFromHexString : (NSString *)hexStr
{
    int hexint,red,green,blue;
    hexint = [self intFromHexString:hexStr];
    red    = (hexint & 0xff0000) >> 16;
    green  = (hexint & 0x00ff00) >> 8;
    blue   = hexint & 0xff;
    UIColor *result = [UIColor colorWithRed:red*INV255 green: green*INV255 blue:blue*INV255 alpha: 1.0f];
    return result;
}   //end colorFromHexString

//==========FeedVC=========================================================================
//- (NSString *) breakUpLine : (NSString *)input : (int)columnWidth
//{
//    NSString *output;
//    int lenleft,len = input.length;
//    if (len <= columnWidth) output = input; //One liner?
//    else //Multi Lines:
//    {
//        NSString *workString = input;
//        lenleft = len;
//        while (lenleft > columnWidth)
//        {
//            NSString *nextBlock = [workString substringToIndex:columnWidth];
//        }
//    }
//    return output;
//} //end breakUpLine


//==========Putils=========================================================================
// DHS 7/20: Simplifier for creating system buttons...
-(UIButton *) createSystemButton : (int) xi : (int) yi : (int) xs : (int) ys :
            (NSString *) fontName : (int)fontSize :
            (UIColor *)tintColor : (UIColor *)bkgdColor :
            (NSString *) labelText
{
    UIButton *b  = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setFrame:CGRectMake(xi,yi,xs,ys)];
    [b setTitle:labelText forState:UIControlStateNormal];
    [b.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    b.tintColor       = tintColor;
    b.backgroundColor = bkgdColor;
    return b;
} //end createSystemButton

//==========Putils=========================================================================
// DHS 7/20: Simplifier for creating system labels...
-(UILabel *) createSystemLabel : (int) xi : (int) yi : (int) xs : (int) ys :
            (NSString *) fontName : (int)fontSize :
            (UIColor *)textColor : (UIColor *)bkgdColor :
            (NSString *) labelText
{
    UILabel *l        = [[UILabel alloc] initWithFrame:  CGRectMake(xi,yi,xs,ys)];
    [l setFont:[UIFont fontWithName:fontName size:fontSize]];
    l.text            = labelText;
    l.textColor       = textColor;
    l.backgroundColor = bkgdColor;
    l.textAlignment   = NSTextAlignmentCenter; //Assume most labels will be centered?
    return l;
} //end createSystemLabel

//==========Putils=========================================================================
// DHS 7/20: Simplifier for creating custom buttons...
//           NOTE This sets the BACKGROUND bitmaps
-(UIButton *) createCustomButtonBkgd : (int) xi : (int) yi : (int) xs : (int) ys :
            (UIImage *) normal : (UIImage *) highlighted
{
    UIButton *b  = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setFrame:CGRectMake(xi,yi,xs,ys)];
    if (normal != nil)
        [b setBackgroundImage:normal forState:UIControlStateNormal];
    if (highlighted != nil)
        [b setBackgroundImage:highlighted forState:UIControlStateHighlighted];
    return b;
} //end createCustomButton

//==========Putils=========================================================================
// DHS 7/20: Simplifier for creating custom buttons...
//           NOTE This sets the IMAGE bitmaps
-(UIButton *) createCustomButton : (int) xi : (int) yi : (int) xs : (int) ys :
                                    (UIImage *) normal : (UIImage *) highlighted
{
    UIButton *b  = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setFrame:CGRectMake(xi,yi,xs,ys)];
    if (normal != nil)
        [b setImage:normal forState:UIControlStateNormal];
    if (highlighted != nil)
        [b setImage:highlighted forState:UIControlStateHighlighted];
    return b;
} //end createCustomButton



@end
