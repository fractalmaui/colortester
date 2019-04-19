//
//    ____                _     __     ______
//   / ___|_ __ ___  __ _| |_ __\ \   / / ___|
//  | |   | '__/ _ \/ _` | __/ _ \ \ / / |
//  | |___| | |  __/ (_| | ||  __/\ V /| |___
//   \____|_|  \___|\__,_|\__\___| \_/  \____|
//
//
//  CreateViewController.h
//  pix
//
//  Created by Dave Scruton on 1/16/17.
//  Copyright © 2017 Huedoku Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "AppDelegate.h"
#import "CCColorCube.h"
#import "ColorNamer.h"
#import "MagnifierView.h"
#import "UIImageExtras.h"
#import "UIViewWithBorder.h"

#define ALERT_GAMUT 1001
#define ALERT_LOCATION 1002

//DHS 5/2: add size params for autoboxes (color select swatches)
#define AUTOBOX_SIZE 48
#define AUTOBOX_SIZE2 24
#define AUTOBOX_SELECTSIZE 60
#define AUTOBOX_SELECTSIZE2 30

#define CREATEVC_INITIAL_UPDATE 1001
#define CREATEVC_FULL_UPDATE    1002
#define CREATEVC_COLOR_UPDATE   1003

#define FOUNDBOXCOUNT 32
@interface CreateViewController : UIViewController <UINavigationControllerDelegate,  UIImagePickerControllerDelegate>
{
    int viewWid,viewHit,viewW2,viewH2;
    int buttonWid,buttonHit;
    
    int captop,capbot,capleft,capright,capinset,capwidth,capheight;
    
    int selectedColor;
    int oldSelectedColor;
    
    int cr,cg,cb; //Current selected rgb components

    int alertIndex;
    
    int orderedIndices[4];
    UIColor *orderedColor1;
    UIColor *orderedColor2;
    UIColor *orderedColor3;
    UIColor *orderedColor4;
    
    MagnifierView *magView;
    ColorNamer *colorNamer;
    
    BOOL needEffects;
    BOOL dragging;
    
    int photoPixWid,photoPixHit;
    int photoScreenWid,photoScreenHit;
    float photoToUIX,photoToUIY;
    
    CGPoint touchLocation;
    float touchX,touchY;
    UIView *autoBoxes[4];
    UIView *foundBoxes[256];
    CIImage *coreImage;
    UIImage *originalImage;
    UIImage *processedImage;
    UIImage *scaledSamplingImage;
    
    NSArray *extractedColors;

    UIColor *color1;
    UIColor *color2;
    UIColor *color3;
    UIColor *color4;
    
    UIColor *latestColor;
    NSString *latestColorName;
    
    CGRect tlr,trr,blr,brr;

    double tetraVolume;
    
    BOOL firstTimeUp;
    
    int imageScale;

    float sampleXPercentConvert,sampleYPercentConvert;
    float threshold;
    double rgbtoler;
    int whichAlgo;
    int colorSize;
    
    //DHS 5/23
    AppDelegate *cappd;
    
    CGPoint colorPoint1;
    CGPoint colorPoint2;
    CGPoint colorPoint3;
    CGPoint colorPoint4;
    NSString *colorName1;
    NSString *colorName2;
    NSString *colorName3;
    NSString *colorName4;
    
}



@property (nonatomic , strong) UIImage *photo;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *TLButton;
@property (weak, nonatomic) IBOutlet UIButton *TRButton;
@property (weak, nonatomic) IBOutlet UIButton *BLButton;
@property (weak, nonatomic) IBOutlet UIButton *BRButton;
@property (weak, nonatomic) IBOutlet UIView *TLSwatch;
@property (weak, nonatomic) IBOutlet UIView *TRSwatch;
@property (weak, nonatomic) IBOutlet UIView *BLSwatch;
@property (weak, nonatomic) IBOutlet UIView *BRSwatch;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel2;
@property (strong, nonatomic) CCColorCube *colorCube;
@property (weak, nonatomic) IBOutlet UIView *bkgdView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *obscura;
@property (weak, nonatomic) IBOutlet UIButton *algoButton;
@property (weak, nonatomic) IBOutlet UIView *topColorsView;

@property (nonatomic , assign) BOOL needProcessedImage;
@property (nonatomic , assign) BOOL virgin;
@property (nonatomic , assign) BOOL returningFromPuzzle;
- (IBAction)colorSizeSelect:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *colorSizeButton;

//DHS 5/23
@property (nonatomic , assign) BOOL needToLoadImage;
@property (weak, nonatomic) IBOutlet UISlider *tolerSlider;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UILabel *tLabel;
@property (weak, nonatomic) IBOutlet UILabel *rLabel;

- (IBAction)thresholdChanged:(id)sender;
- (IBAction)tolerChanged:(id)sender;

- (IBAction)TLSelect:(id)sender;
- (IBAction)TRSelect:(id)sender;
- (IBAction)BLSelect:(id)sender;
- (IBAction)BRSelect:(id)sender;
- (IBAction)loadSelect:(id)sender;
- (IBAction)resetSelect:(id)sender;
- (IBAction)algoSelect:(id)sender;

@end

