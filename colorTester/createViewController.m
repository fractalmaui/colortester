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
//  Created by Dave Scruton on 11/24/18
//  Copyright © 2018 Huedoku Labs. All rights reserved.
//
//  Custom standalone version for testing color finding algos
//  2/11 add RGBTolerance : internal variable to colorcube
//  3/3 add new algo, HH/XX/YY to colorcube
//  4/10 get rid of new Hue/X/Y algo, was awful. clean up original algo,
//         add top 32 color swatch across image.
#import "createViewController.h"

@implementation CreateViewController

#define INV255 0.00392156
#define MAGNIFIER_ON

//Emoticon thresholds, these will be parse params soon...
double emoRanges[8] = {0.1,0.219,0.399,0.8,10,10,10};

//==========createVC=================================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
    //Objects...
    colorNamer = [ColorNamer sharedInstance];
    _colorCube = [[CCColorCube alloc] init];
//    putils     = [[PixUtils alloc] init];
#ifdef USE_SFX
    _sfx       = [soundFX sharedInstance];
#endif

    //Flags and vars...
    coreImage        = nil;
    originalImage    = nil;
    processedImage   = nil;
    needEffects      = FALSE;
    selectedColor    = 0;
    oldSelectedColor = 0;
    firstTimeUp      = TRUE;
    tetraVolume      = 0.0;
    whichAlgo        = 0;  //Builtin RR/GG/BB colorcube
    colorSize = 64; //starting count for row of colors below photo
    rgbtoler = 0.05; //Canned value
    return self;
} //end initWithCoder

//==========createVC=================================================================
// setup screen sizes, add magnifying glass, autoboxes, animation overlay
-(void) loadView
{
    [super loadView];
    CGSize csz  = [UIScreen mainScreen].bounds.size;
    viewWid     = (int)csz.width;
    viewHit     = (int)csz.height;
    viewW2      = viewWid/2;
    viewH2      = viewHit/2;
    buttonWid   = viewWid * 0.15;
    buttonHit   = buttonWid;
    
    //Init Magnifying Glass object...
    CGRect magFrame = CGRectMake(0,0,1.5*buttonWid,1.5*buttonHit);
    magView = [[MagnifierView alloc] initWithFrame:magFrame];
    [self.view addSubview:magView];
    magView.gotiPad       = FALSE; //_gotiPad; //DHS 5/8
    magView.viewToMagnify = _photoView;
    magView.hidden        = TRUE;
    
    capinset = 8;
    capwidth = capheight = viewWid - 2*capinset;
    captop   = viewH2 - capheight/2;
    capbot   = captop + capheight;
    capleft  = viewW2 - capwidth/2;
    capright = capleft + capwidth;

    //NSLog(@" add autoboxes...caps %d %d %d %d",captop,capbot,capleft,capright);
    //Autoboxes... user selected colorwells
    for (int i=0;i<4;i++)
    {
        //DHS 5/25 start autoboxes offscreen...
        autoBoxes[i] = [[UIView alloc] initWithFrame:CGRectMake(-100,0,AUTOBOX_SIZE,AUTOBOX_SIZE)];
        //Add to main view: if added to photoview magnifying glass doesn't work
        autoBoxes[i].layer.borderWidth = 2;
        autoBoxes[i].layer.borderColor = [UIColor grayColor].CGColor;
        [self.view addSubview:autoBoxes[i]];
    }

} //end loadView



//==========createVC=================================================================
// Makes sure photo view is centered and sized properly,
//   scales underlying photo bitmap to screen
- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@" createVC viewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.
    coreImage = [[CIImage alloc] init];
    
    //12/15 Moved in from viewWillAppear.. this VP stuff only needs to happen once
    int quarterWidth = viewWid/4;
    //FUCK Constraints. Lay out swatches programmatically.
    //  This ui has two overlapping views that need to snap to the screen
    //  just right AND one has to be just slightly inside the other....
    int xi,yi,xs,ys;
    
    xs = ys = viewWid;
    xi = 0;
    yi = viewH2 - ys/2;
    _bkgdView.frame  = CGRectMake(xi, yi, xs, ys);
    _photoView.frame = CGRectMake(capleft,captop,capwidth,capheight);
    
    
//DHS 5/23 DON'T NEED if we move photo picker to this VC
    //Get photo <--> screen conversion factors...
    photoPixWid = _photo.size.width;
    photoPixHit = _photo.size.height;
    photoScreenWid = _photoView.frame.size.width;
    photoScreenHit = _photoView.frame.size.height;
    photoToUIX = (float)photoScreenWid/(float)_photo.size.width;
    photoToUIY = (float)photoScreenHit/(float)_photo.size.height;
    //NSLog(@" xyc %f %f",photoToUIX,photoToUIY);
    
    //Used to get four sample colors when using emp/squid color enhance function....
    sampleXPercentConvert = 100.0 / (float)photoScreenWid;
    sampleYPercentConvert = 100.0 / (float)photoScreenHit;
    
    //Color name label is just below this central area...
    yi+=ys;
    xs = viewWid * 0.95;
    ys = _colorLabel.frame.size.height;
    xi = viewW2 - xs*0.5;
    _colorLabel.frame = CGRectMake(xi, yi, xs, ys);
    _colorLabel2.frame = CGRectMake(xi-1, yi-1, xs, ys);

    int xleft,xright;
    int xsleft,xsright;
    yi+= 1.8*ys;
    xleft = xi;
    xsleft = viewWid * 0.3;
    xright = xi + xsleft;
    xsright = viewWid * 0.65;
    _tLabel.frame = CGRectMake(xleft, yi, xsleft, ys);
    _thresholdSlider.frame = CGRectMake(xright, yi, xsright, ys);
    //Move down...
    yi += ys*1.5;
    _rLabel.frame = CGRectMake(xleft, yi, xsleft, ys);
    _tolerSlider.frame = CGRectMake(xright, yi, xsright, ys);
  
    //Line up 4 swatches above the central area...
    xs = ys = quarterWidth;
    xi = 0;
    yi = _bkgdView.frame.origin.y - quarterWidth;
    tlr             = CGRectMake(xi, yi, xs, ys);
    xi+=xs;
    trr             = CGRectMake(xi, yi, xs, ys);
    xi+=xs;
    blr             = CGRectMake(xi, yi, xs, ys);
    xi+=xs;
    //Make sure RH swatch fills in any extra X space to the right
    xs = viewWid - xi;
    brr = CGRectMake(xi, yi, xs, ys);

    CGRect rr = _photoView.frame;

    int fsize = viewWid / FOUNDBOXCOUNT;
    xi = 0;
    xs = viewWid;
    ys = fsize;
    yi = rr.origin.y + rr.size.height;
    _topColorsView.frame   = CGRectMake(xi, yi, xs, ys);
    _colorSizeButton.frame = CGRectMake(xi, yi, xs, ys); //Matching button
    //DHS 4/10 add a row of little boxes below photo...
    yi = 0;
    xi = rr.origin.x;
    xs = fsize;
    ys = xs * 3;
    for (int i=0;i<FOUNDBOXCOUNT;i++)
    {
        foundBoxes[i] = [[UIView alloc] initWithFrame:CGRectMake(xi, yi, xs,ys)];
        foundBoxes[i].backgroundColor = [UIColor colorWithRed:i/255.0 green:2 blue:(8*i)/255.0 alpha:(12*i)/255.0 ];
        [_topColorsView addSubview:foundBoxes[i]];
        xi+=xs;
    }
    [self resetSliders];

} //end viewDidLoad

//==========createVC=================================================================
-(void) resetFoundBoxes
{
    CGRect rr = _topColorsView.frame;
    int xi,yi,xs,ys;
    yi = 0;
    xi = rr.origin.x;
    int fsize = viewWid / colorSize;
    xs = fsize;
    ys = 30;
    //reset the row of little boxes below photo...
    int i;
    for (i=0;i<colorSize;i++)
    {
        foundBoxes[i].frame = CGRectMake(xi, yi, xs,ys);
        xi+=xs;
    }
    while (i <FOUNDBOXCOUNT)
    {
        i++;
        foundBoxes[i].frame = CGRectZero;
    }
}

//==========createVC=================================================================
// Handles incoming from parent or childVC, also determines if image
//   processing is needed, spawns in bkgd if so
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _photoView.image = _photo;
    
    //These frames may have been changed...
    _TLButton.frame = _TLSwatch.frame = tlr;
    _TRButton.frame = _TRSwatch.frame = trr;
    _BLButton.frame = _BLSwatch.frame = blr;
    _BRButton.frame = _BRSwatch.frame = brr;
    

    //Make sure any animated-out controls are visible...
    _TLSwatch.alpha = _TRSwatch.alpha = _BLSwatch.alpha = _BRSwatch.alpha = 1.0;
    _TLButton.alpha = _TRButton.alpha = _BLButton.alpha = _BRButton.alpha = 1.0;
    _colorLabel.alpha  = 1.0;
    _backButton.alpha  = 1.0;
    for (int i=0;i<4;i++) autoBoxes[i].hidden = FALSE;
    _createButton.enabled = TRUE;
    
    //DHS 9/20/18 Moved back to appdelegate...[cappd setupLocationManager]; //DHS 3/2/18: good enuf place?

    originalImage = _photo;
    //Coming in from either mainVC or puzzleVC?
    if (_needProcessedImage) //DHS 2/11/18 don't process if already done!
    {
        _obscura.hidden = true;
        //NSLog(@" in viewdidappear..., processing image!");
        coreImage = [coreImage initWithImage:_photo];
        //NOTE: we have to wait until image processing is done!
        [self getProcessedImageBkgd];
        [self handleProcessedResults];
        [self updateUI : CREATEVC_INITIAL_UPDATE];  //DHS 5/25 centralize UI updates
    }
    [self updateSliderLabels];

} //end viewWillAppear


//==========createVC=================================================================
// Coming in from parent? Shows photo picker as needed, shows hints if needed
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_needToLoadImage)  //DHS 5/23 test
    {
        _needToLoadImage = FALSE;
        [self displayPhotoPicker];
    }
    [self becomeFirstResponder]; //DHS 11/15 For Shake response
} //end viewDidAppear

//==========createVC=================================================================
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


//==========createVC=================================================================
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


//==========createVC=================================================================
// DHS 3/3 new
-(void) algoMenu
{
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Select Algorithm"];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Select Algorithm",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Builtin"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  self->whichAlgo = 0;
                                                  [self resetSliders];
                                                  [self handleProcessedResults];

                                                  [self updateUI : CREATEVC_INITIAL_UPDATE];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"HH/XX/YY"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  self->whichAlgo = 1;
                                                  [self resetSliders];
                                                  [self handleProcessedResults];
                                                  [self updateUI : CREATEVC_INITIAL_UPDATE];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
} //end monthMenu




//==========createVC=================================================================
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

//==========createVC=================================================================
-(void) displayPhotoPicker
{
    //NSLog(@" photo picker...");
    UIImagePickerController *imgPicker;
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = YES;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imgPicker animated:NO completion:nil];
} //end displayPhotoPicker

//==========createVC=================================================================
// OK? load / process image as needed
- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Makes poppy squirrel sound!
#ifdef USE_SFX
    [_sfx makeTicSoundWithPitchandLevel:7 :70 : 40];
#endif
    //DHS 2/13/18
    [Picker dismissViewControllerAnimated:NO completion:^{
        self->_photo = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        self->_photo = [self->_photo imageByScalingAndCroppingForSize : CGSizeMake(1280, 1280)  ];  //DHS 3/26
        self->photoPixWid = self->_photo.size.width;
        self->photoPixHit = self->_photo.size.height;
        self->photoScreenWid = self->_photoView.frame.size.width;
        self->photoScreenHit = self->_photoView.frame.size.height;
        self->photoToUIX = (float)self->photoScreenWid/(float)self->_photo.size.width;
        self->photoToUIY = (float)self->photoScreenHit/(float)self->_photo.size.height;
        self->originalImage = self->_photo;
        //OK, time to process photo!
        self->coreImage = [self->coreImage initWithImage:self->_photo];
        //NOTE: we have to wait until image processing is done!
        self->_needProcessedImage = TRUE;
        [self getProcessedImageBkgd];
    }];
} //end didFinishPickingMediaWithInfo

//==========createVC=================================================================
// Dismiss back to parent on cancel...
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)Picker
{
    [Picker dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated : YES completion:nil];

} //end imagePickerControllerDidCancel

//==========createVC=================================================================
-(void) handleProcessedResults
{
    int sx = processedImage.size.width;
    int sy = processedImage.size.height;
    scaledSamplingImage = [processedImage imageByScalingAndCroppingForSize : CGSizeMake(sx, sy)  ];
    //NSLog(@" ...scaled down imageXY %d,%d",(int)scaledSamplingImage.size.width,(int)scaledSamplingImage.size.height);
    [self computeAutoColors]; //use 3rd party colorcube stuff...
    [self resampleFourCornerColors];
    [self updateUI : CREATEVC_FULL_UPDATE];  //DHS 5/25 centralize UI updates
    // Get color 1 by default...
    int xi = colorPoint1.x ;
    int yi = colorPoint1.y ;
    [self getPhotoRGBPixel: xi  : yi]; //This sets up cr,cg,cb
    float r,g,b;
    r = INV255 * (float)cr;
    g = INV255 * (float)cg;
    b = INV255 * (float)cb;
    latestColor  = [UIColor colorWithRed : r green: g blue : b alpha: 1.0f];
    for (int i=0;i<4;i++) autoBoxes[i].hidden = FALSE;
    _createButton.hidden = FALSE;

} //end handleProcessedResults

//==========createVC=================================================================
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//==========HDKPIX=========================================================================
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//==========createVC=================================================================
- (IBAction)loadSelect:(id)sender
{
    NSLog(@" load here...");
    [self displayPhotoPicker];
}

//==========createVC=================================================================
- (IBAction)resetSelect:(id)sender
{
    NSLog(@" reset...");
    [self resetSliders];
    [self handleProcessedResults];
    
    NSString *vstr =   [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    _colorLabel.text = [NSString stringWithFormat:@"%@ ",vstr];
    _colorLabel2.text = [NSString stringWithFormat:@"%@ ",vstr];

}

//==========createVC=================================================================
// DHS 3/3 new
- (IBAction)algoSelect:(id)sender
{
    [self algoMenu];
}

//==========createVC=================================================================
// DHS 4/12 new
- (IBAction)colorSizeSelect:(id)sender
{
    colorSize*=2;
    if (colorSize > 32) colorSize = 4;
    NSLog(@"CsizeSel %d",colorSize);
    [self resetFoundBoxes];
}


//==========createVC=================================================================
-(void) resetSliders
{
    //Builtins for RGB algo
    if (whichAlgo == 0)
    {
        threshold = 0.1;
        rgbtoler = 0.05;
    }
    else //New algo, looks better w/ higher thresh
    {
        threshold = 0.8;
        rgbtoler  = 0.1;
    }
    
    
     _thresholdSlider.value = threshold;
     _tolerSlider.value = rgbtoler;

    [_colorCube setThresh:threshold];
    [_colorCube setRGBToler:rgbtoler];

    [self updateSliderLabels];
    

}

//==========creattlabelVC=================================================================
// DHS 4/10 asdf
-(void) updateFoundBoxes
{
    for (int i=0;i<FOUNDBOXCOUNT;i++)
    {
        UIColor *duhC = [_colorCube getTop64ColorByIndex:i];
        foundBoxes[i].backgroundColor = duhC;
    }
}

//==========creattlabelVC=================================================================
-(void) updateSliderLabels
{
    //NSLog(@"thresh %f toler %f",threshold,rgbtoler);
    _tLabel.text = [NSString stringWithFormat:@"Brightest %4.2f",threshold];
//asdf
    _rLabel.text = [NSString stringWithFormat:@"RGBClump %4.2f",rgbtoler];
}


//==========createVC=================================================================
- (IBAction)thresholdChanged:(id)sender
{
    UISlider *s = (UISlider*)sender;
    threshold = s.value;
    [_colorCube setThresh:threshold];
    [self handleProcessedResults];
    [self updateSliderLabels];
}

//==========createVC=================================================================
- (IBAction)tolerChanged:(id)sender
{
    UISlider *s = (UISlider*)sender;
    rgbtoler = (double)s.value;
    if (rgbtoler < 0.01) rgbtoler = 0.01; //DHS 2/19
    [_colorCube setRGBToler:rgbtoler];
    [self handleProcessedResults];
    [self updateSliderLabels];
}

//==========createVC=================================================================
- (IBAction)TLSelect:(id)sender
{
    //NSLog(@" tlselect");
    selectedColor = 1;
    [self updateUIForSelect];
    oldSelectedColor = selectedColor;

}

//==========createVC=================================================================
- (IBAction)TRSelect:(id)sender
{
    //NSLog(@" trselect");
    selectedColor = 2;
    [self updateUIForSelect];
    oldSelectedColor = selectedColor;
}

//==========createVC=================================================================
- (IBAction)BLSelect:(id)sender
{
    //NSLog(@" blselect");
    selectedColor = 3;
    [self updateUIForSelect];
    oldSelectedColor = selectedColor;
}

//==========createVC=================================================================
- (IBAction)BRSelect:(id)sender
{
    //NSLog(@" brselect");
    selectedColor = 4;
    [self updateUIForSelect];
    oldSelectedColor = selectedColor;
}



//==========cameraVC=========================================================================
-(void) resampleFourCornerColors
{
    int sr,sg,sb; //save rgb colors
    sr = cr;
    sg = cg;
    sb = cb;
    for (int loop=0;loop<4;loop++)
    {
        float xf,yf;
        float r,g,b;
        xf = yf = 0;
        //DHS 4/27 Use colorpoint storage, NOT autoboxes for XY coords
        switch(loop)
        {
            case 0:
                xf = colorPoint1.x;
                yf = colorPoint1.y;
                break;
            case 1:
                xf = colorPoint2.x;
                yf = colorPoint2.y;
                break;
            case 2:
                xf = colorPoint3.x;
                yf = colorPoint3.y;
                break;
            case 3:
                xf = colorPoint4.x;
                yf = colorPoint4.y;
                break;
        }
        [self getPhotoRGBPixel: (int)xf  : (int)yf]; // this populates cr,cg,cb
        r = INV255 * cr;
        g = INV255 * cg;
        b = INV255 * cb;
        //NSLog(@"..loop[%d]XY: %f %f:RGB %f,%f,%f",loop,xf,yf,r,g,b);
        latestColor = [UIColor colorWithRed : r green: g blue : b alpha: 1.0f];
        autoBoxes[loop].backgroundColor = latestColor;
        switch(loop)
        {
            case 0: _TLSwatch.backgroundColor = color1 = latestColor;break;
            case 1: _TRSwatch.backgroundColor = color2 = latestColor;break;
            case 2: _BLSwatch.backgroundColor = color3 = latestColor;break;
            case 3: _BRSwatch.backgroundColor = color4 = latestColor;break;
        }
    }
    cr = sr; //Restore saved colors...
    cg = sg;
    cb = sb;
    
} //end resampleFourCornerColors



//=========-createVC=========================================================================
// This is the new autoSelect, which relies on the ColorCube library...
- (void) computeAutoColors
{
    //NSLog(@" autocolor...RGBToler:%f thresh:%f",rgbtoler,threshold);
    [_colorCube setColorAlgo:whichAlgo];
    [_colorCube setXYSize:scaledSamplingImage.size.width :(int)scaledSamplingImage.size.height];
    //This does all the heavy lifting...
    extractedColors = [_colorCube extractBrightColorsFromImage:scaledSamplingImage avoidColor:nil count:4];
//DHS 4/6    extractedColors = [_colorCube extractColorsFromImage:scaledSamplingImage
//DHS 4/6                                                   flags:CCOnlyDistinctColors | CCOrderByBrightness];

    int ecount = (int)[extractedColors count];
    //NSLog(@" Extracted ColorCount %d",ecount);
    if (extractedColors != nil)
    {
        if (ecount > 0)
            color1 = [extractedColors objectAtIndex:0];
        if (ecount > 1)
            color2 = [extractedColors objectAtIndex:1];
        if (ecount > 2)
            color3 = [extractedColors objectAtIndex:2];
        if (ecount > 3)
            color4 = [extractedColors objectAtIndex:3];
    }
    
    if (ecount < 4) return; //2/11 BAIL on bogus results!
    NSArray *xyPositions;
    CGPoint imagePoint;
    CGPoint percentPoint;
    //This looks thru the image and finds XY positions for the colors found above
    
    //xyPositions = [_colorCube findColorXYPositionsFromCenterOfImage :scaledSamplingImage  : extractedColors];

    
    xyPositions = [_colorCube findColorXYPositionsInImage:scaledSamplingImage  : extractedColors];
    //Just settle on first 4 colors for now..
    if (ecount > 4) ecount = 4;
    int pcount = (int)xyPositions.count;
    if (pcount < 4)
    {
        NSLog(@" ERROR getting color position data!");
        return;
    }

    for (int i=0;i<ecount;i++)
    {
        UIColor *clc = [extractedColors objectAtIndex:i];
        NSString *colorname = [colorNamer getNameFromUIColor : clc];
        imagePoint   = [[xyPositions objectAtIndex:i] CGPointValue];
        percentPoint = CGPointMake(imagePoint.x,imagePoint.y);
        switch(i)
        {
            case 0:
                colorPoint1 = percentPoint;
                colorName1  = colorname;
                color1      = clc;
                break;
            case 1:
                colorPoint2 = percentPoint;
                colorName2  = colorname;
                color2      = clc;
                break;
            case 2:
                colorPoint3 = percentPoint;
                colorName3  = colorname;
                color3      = clc;
                break;
            case 3:
                colorPoint4 = percentPoint;
                colorName4  = colorname;
                color4      = clc;
                break;
        } //end switch
        //NSLog(@" ..autocolor[%d] %@ xy %f %f",i,clc,percentPoint.x,percentPoint.y);
        //OUCH! this has to be done here when we have the xy pixel point values!
        autoBoxes[i].backgroundColor = clc;
        imagePoint.x*=photoToUIX;
        imagePoint.y*=photoToUIY;
        imagePoint.x+=capleft;
        imagePoint.y+=captop;
        autoBoxes[i].center = imagePoint;
        //NSLog(@" autobox[%d] abcen %f,%f name %@",i,imagePoint.x,imagePoint.y,colorname);
    } //end for i
    
} //end computeAutoColors

//==========createVC=================================================================
// 5/25 Two modes? Full and color update
-(void) updateUI : (int) mode
{
    //DHS 4/10 NOT NEEDED!
//    if (mode == CREATEVC_INITIAL_UPDATE)
//    {
//        //Startup: set swatches to match window background color
//        _TLSwatch.backgroundColor = autoBoxes[0].backgroundColor = [UIColor whiteColor];
//        _TRSwatch.backgroundColor = autoBoxes[1].backgroundColor = [UIColor whiteColor];
//        _BLSwatch.backgroundColor = autoBoxes[2].backgroundColor = [UIColor whiteColor];
//        _BRSwatch.backgroundColor = autoBoxes[3].backgroundColor = [UIColor whiteColor];
//    }
//    else
    {
        //Update colors from results Plixa object...
        _TLSwatch.backgroundColor = autoBoxes[0].backgroundColor = color1;
        _TRSwatch.backgroundColor = autoBoxes[1].backgroundColor = color2;
        _BLSwatch.backgroundColor = autoBoxes[2].backgroundColor = color3;
        _BRSwatch.backgroundColor = autoBoxes[3].backgroundColor = color4;
    }
    _colorLabel.text = latestColorName; 
    _colorLabel2.text = latestColorName;

    if (whichAlgo == 0)
        [_algoButton setTitle:@"Normal " forState:UIControlStateNormal];
    else
        [_algoButton setTitle:@"H/X/Y" forState:UIControlStateNormal];

    [self updateFoundBoxes];
} //end updateUI


//=========-createVC=========================================================================
//  Needs to do some animation, so this ui update is different from full update...
-(void) updateUIForSelect
{
    
#ifdef USE_SFX
    [_sfx makeTicSoundWithPitch : 8 : 75 + selectedColor];
#endif
    //NSLog(@" updateUI: oldselect %d select %d",oldSelectedColor,selectedColor);
    UIView *vv;
    CGRect rr = tlr;
    UIView *vv2;
    CGRect rr2 = tlr;
    NSString *cname = @"";
    if (oldSelectedColor != 0) //Deselect? Return old swatch to normal
    {
        int oscm1 = oldSelectedColor-1;
        //Resize old selected autobox to smaller unselected size:
        CGPoint oap = autoBoxes[oscm1].center; //(autoboxes indexed 0..3!)
        autoBoxes[oscm1].frame = CGRectMake(oap.x-AUTOBOX_SIZE2, oap.y-AUTOBOX_SIZE2,
                                                       AUTOBOX_SIZE, AUTOBOX_SIZE);
        //12/13 Unselected color/borderwidth...
        autoBoxes[oscm1].layer.borderWidth = 2;
        autoBoxes[oscm1].layer.borderColor = [UIColor grayColor].CGColor;
        switch(oldSelectedColor)
        {
            case 1: vv = _TLSwatch;rr = tlr;break;
            case 2: vv = _TRSwatch;rr = trr;break;
            case 3: vv = _BLSwatch;rr = blr;break;
            case 4: vv = _BRSwatch;rr = brr;break;
        }
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             vv.frame = rr;
                         }
                         completion:nil
         ];
    }
    if (selectedColor != 0)  //Select? Animate swatch's top to top of window
    {
        int scm1 = selectedColor-1;
        //Resize NEW selected autobox to larger size:
        CGPoint oap = autoBoxes[selectedColor-1].center;  // (autoboxes indexed 0..3!)
        autoBoxes[scm1].frame = CGRectMake(oap.x-AUTOBOX_SELECTSIZE2, oap.y-AUTOBOX_SELECTSIZE2,
                                                       AUTOBOX_SELECTSIZE, AUTOBOX_SELECTSIZE);
        //12/13 Selected color/borderwidth...
        autoBoxes[scm1].layer.borderWidth = 4;
        autoBoxes[scm1].layer.borderColor = [UIColor whiteColor].CGColor;
        switch(selectedColor)
        {
            case 1: vv2 = _TLSwatch;rr2 = tlr;cname = colorName1;break;
            case 2: vv2 = _TRSwatch;rr2 = trr;cname = colorName2;break;
            case 3: vv2 = _BLSwatch;rr2 = blr;cname = colorName3;break;
            case 4: vv2 = _BRSwatch;rr2 = brr;cname = colorName4;break;
        }
        int oldtop = rr2.origin.y;
        rr2.origin.y = 0;
        rr2.size.height+=oldtop;
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             vv2.frame = rr2;
                         }
                         completion:nil
         ];
        
    }
    _colorLabel.text = cname;
    _colorLabel2.text = cname;
} //end UpdateUiForSelect

//=========-createVC=========================================================================
-(void) getProcessedImageBkgd
{
    _createButton.hidden = TRUE;
    _activityIndicator.hidden = FALSE;
    [_activityIndicator startAnimating];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           float cont_intensity  = 1.1f;
                           float sat_intensity   = 1.15f;
                           NSNumber *workNumCont = [NSNumber numberWithFloat:cont_intensity];
                           NSNumber *workNumSat  = [NSNumber numberWithFloat:sat_intensity];
                           CIFilter *filterCont  = [CIFilter filterWithName:@"CIColorControls"
                                                              keysAndValues: kCIInputImageKey, self->coreImage,
                                                    @"inputSaturation", workNumSat,
                                                    @"inputContrast", workNumCont,
                                                    nil];
                           CIImage *workCoreImage = [filterCont outputImage];
                           CIContext *context = [CIContext contextWithOptions:nil];
                           CGImageRef cgimage = [context createCGImage:workCoreImage fromRect:[workCoreImage extent] format:kCIFormatRGBA8 colorSpace:CGColorSpaceCreateDeviceRGB()];
                           self->processedImage = [UIImage imageWithCGImage:cgimage scale:0 orientation:[self->_photo imageOrientation]];
                           CGImageRelease(cgimage);
                           [self->_activityIndicator stopAnimating];
                           self->_activityIndicator.hidden = TRUE;
                           [self handleProcessedResults];
                           //OK we got our image, show it!
                           self->_photoView.image = self->processedImage;
                           
                           //DHS 2/11/18
                           self->_needProcessedImage = FALSE;
                       });
                       
                   }
                   ); //END outside dispatch
    
} //end getProcessedImageBkgd

//==========createVC=========================================================================
-(void) obscureIn
{
    _obscura.alpha   = 1;
    _obscura.hidden  = false;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self->_obscura.alpha       = 0;
                     }
                     completion:^(BOOL finished){
                     }
     ];

}

//==========createVC=========================================================================
// DHS 12/9 Added touch test to see if user touched near a sample box:
//   calls tlSelect..brSelect as if a swatch was selected in this case
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    dragging = YES;
    CGPoint center;
    int i,tx,ty,xoff,yoff,xytoler;
    UITouch *touch  = [[event allTouches] anyObject];
    touchLocation   = [touch locationInView:_photoView];
    touchX          = touchLocation.x;
    touchY          = touchLocation.y;
    
#ifdef MAGNIFIER_ON
    magView.touchPoint = touchLocation;
    magView.hidden = TRUE; //DHS 4/27
#endif
    tx = touchX + capleft;
    ty = touchY + captop;
    //NSLog(@" touchxy %f %f",touchX,touchY);
    int gotmatch = 0;
    xytoler = 10;
    for (i=0;i<4 && !gotmatch;i++)
    {
        center = autoBoxes[i].center;
        xoff = abs(tx-(int)center.x);
        yoff = abs(ty-(int)center.y);
        //NSLog(@"  match[%d] touchxy %d %d center %f %f xyoff %d %d",i,tx,ty,center.x,center.y,xoff,yoff);
        if (xoff < xytoler && yoff < xytoler) gotmatch = i+1;
    }
    
    if (gotmatch)
    {
        //NSLog(@" gotmatch %d",gotmatch);
        switch (gotmatch)
        {
            case 1:
                [self TLSelect:nil];
                break;
            case 2:
                [self TRSelect:nil];
                break;
            case 3:
                [self BLSelect:nil];
                break;
            case 4:
                [self BRSelect:nil];
                break;
        }
    }
} //end touchesBegan

//==========createVC=========================================================================
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (selectedColor == 0) return; //No Select? No Color change
    UITouch *touch = [[event allTouches] anyObject];
    touchLocation = [touch locationInView:_photoView];
    int   xi,yi;
    touchX = touchLocation.x;
    touchY = touchLocation.y;
    //NSLog(@" touchesMoved selectedcolor %d XY %f %f",selectedColor,touchX,touchY);
    BOOL inBounds = TRUE; //DHS 4/27 show/hide magView based on inbounds
    //DHS 8/19 keep going even if OB
    if (touchX < 0)
    {
        touchX      = 0;
        inBounds    = FALSE;
    }
    else if (touchX > capwidth)
    {
        touchX      = capwidth;
        inBounds    = FALSE;
    }
    else if (touchY < 0)
    {
        touchY      = 0;
        inBounds    = FALSE;
    }
    else if (touchY > capheight)
    {
        touchY      = capheight;
        inBounds    = FALSE;
    }
    //DHS 4/27
#ifdef MAGNIFIER_ON
    if (magView != nil)
    {
        magView.touchPoint = touchLocation;
        [magView setNeedsDisplay];
        if (inBounds) magView.hidden = FALSE;
    }
#endif
    touchLocation.x = touchX;
    touchLocation.y = touchY;
    
    xi = touchX;
    yi = touchY;
    CGPoint center      = CGPointMake((float) (xi + capleft), (float) (yi + captop));
    autoBoxes[selectedColor-1].center = center;
    int photoX = (int)((float)xi / sampleXPercentConvert);
    int photoY = (int)((float)yi / sampleXPercentConvert);
    int pX = (int)((float)photoPixWid * (float)(xi+capleft) / (float)photoScreenWid);
    int pY = (int)((float)photoPixWid * (float)(yi+capleft) / (float)photoScreenWid);
    NSLog(@" pxy %d %d",pX,pY);
    [self getPhotoRGBPixel: pX  : pY]; //afdsdf
    float r,g,b;
    r = INV255 * cr;
    g = INV255 * cg;
    b = INV255 * cb;
    NSLog(@" txy(%4.2f,%4.2f)pxy(%d,%d)rgb(%4.2f,%4.2f,%f4.2)",touchX,touchY,photoX,photoY,r,g,b);
    latestColor = [UIColor colorWithRed : r green: g blue : b alpha: 1.0f];
    autoBoxes[selectedColor-1].backgroundColor = latestColor;
    latestColorName = [colorNamer getNameFromUIColor : latestColor];

    switch(selectedColor)
    {
        case 1: _TLSwatch.backgroundColor = color1 = latestColor;break;
        case 2: _TRSwatch.backgroundColor = color2 = latestColor;break;
        case 3: _BLSwatch.backgroundColor = color3 = latestColor;break;
        case 4: _BRSwatch.backgroundColor = color4 = latestColor;break;
    }
    [self saveTouchColorAndPosition];
    [self updateUI : CREATEVC_COLOR_UPDATE]; //DHS 5/25 centralize UI updates
} //end touchesMoved

//==========createVC=========================================================================
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (magView != nil)
    {
        magView.hidden = TRUE;
    }
    dragging = NO;
    selectedColor = 0;  //DHS 10/15
} //end touchesEnded

//==========createVC=========================================================================
-(void) saveTouchColorAndPosition
{
    
   float xperConv = 100.0 /(float)_photoView.frame.size.width; //DHS 2/19
   float yperConv = 100.0 /(float)_photoView.frame.size.height;
   
    int percentX = (int)((float)touchX * xperConv);
    int percentY = (int)((float)touchY * yperConv);
    CGPoint percentPoint = CGPointMake(percentX,percentY);

   switch(selectedColor)
    {
        case 1:
            color1      = latestColor;
            colorName1  = latestColorName;
            colorPoint1 = percentPoint;
            break;
        case 2:
            color2      = latestColor;
            colorName2  = latestColorName;
            colorPoint2 = percentPoint;
            break;
        case 3:
            color3      = latestColor;
            colorName3  = latestColorName;
            colorPoint3 = percentPoint;
            break;
        case 4:
            color4      = latestColor;
            colorName4  = latestColorName;
            colorPoint4 = percentPoint;
            break;
    }
} //end saveTouchColorAndPosition


//-----------(pixHalation)-----------------------------------------------------------------
// X and Y are in the range 0...processedImage.size.Width,.height!!
- (void) getPhotoRGBPixel: (int)x  : (int)y
{
    if (processedImage == nil) return;
    CFDataRef pixelData;
    pixelData = CGDataProviderCopyData(CGImageGetDataProvider(processedImage.CGImage));
    if (pixelData == nil) return;
    const UInt8* data = CFDataGetBytePtr(pixelData);
    int pixelInfo = ((photoPixWid  * y) + x ) * 4; // The image is png
    //DHS 3/25 For some reason CIImage ops return different R/B ordering!
    {
        cr = (int)data[pixelInfo];
        cg = (int)data[pixelInfo + 1];
        cb = (int)data[pixelInfo + 2];
    }
    CFRelease(pixelData);
    
} //end getPhotoRGBPixel

//==========createVC=========================================================================
// Brute force, checks for two identical colornames
-(BOOL) areThereColorRedundancies
{
    BOOL gotmatch = FALSE;
    //NSLog(@" match %@ %@ %@ %@",colorName1,colorName2,colorName3,colorName4);
    if ([colorName1 isEqualToString:colorName2])                    gotmatch = TRUE;
    else if (!gotmatch && [colorName1 isEqualToString:colorName3])  gotmatch = TRUE;
    else if (!gotmatch && [colorName1 isEqualToString:colorName4])  gotmatch = TRUE;
    else if (!gotmatch && [colorName2 isEqualToString:colorName3])  gotmatch = TRUE;
    else if (!gotmatch && [colorName2 isEqualToString:colorName4])  gotmatch = TRUE;
    else if (!gotmatch && [colorName3 isEqualToString:colorName4])  gotmatch = TRUE;
    return gotmatch;
} //end areThereColorRedundancies

//==========createVC=========================================================================
-(void) orderColors
{
    //Here are the 4 initial cornervalues in an array
    UIColor  *corner1234[] = {color1,color2,color3,color4};
    
    double luminance[4];
    for(int i = 0; i<4; i++)
    {
        const CGFloat* ccomponents;
        const CGFloat* tcomponents;
        double rd,gd,bd;
        ccomponents = CGColorGetComponents(corner1234[i].CGColor);
        rd = (double)ccomponents[0];
        gd = (double)ccomponents[1];
        bd = (double)ccomponents[2];
        UIColor *t = [UIColor colorWithRed:[self xyzc:(rd)/100.0]
                                     green:[self xyzc:(gd)/100.0]
                                      blue:[self xyzc:(bd)/100.0]
                                     alpha:1.0];
        tcomponents = CGColorGetComponents(t.CGColor);
        rd = (double)tcomponents[0];
        gd = (double)tcomponents[1];
        bd = (double)tcomponents[2];
        luminance[i] = (sqrt((0.299*(rd*rd)) +
                             0.587*((gd*gd)) +
                             0.114*((bd*bd))));
        //NSLog(@" order[%d] rgb %f %f %f lum %f",i,rd,gd,bd,luminance[i]);
        
    }
    
    //DHS 2/19: Brute force luminance sort... (just resort indices)
    //int nextIndex = 0;
    int maxIndex  = 0;
    for (int i=0;i<4;i++)
    {
        double maxLum = -999;
        for (int j=0;j<4;j++)
        {
            if (luminance[j] > maxLum)
            {
                maxLum   = luminance[j];
                maxIndex = j;
            }
        }
        orderedIndices[i] = maxIndex;
        luminance[maxIndex] = -90; //Clear luminance for next pass..
    }
    //NSLog(@" brute order %d %d %d %d",orderedIndices[0],orderedIndices[1],orderedIndices[2],orderedIndices[3]);
    
    //NSLog(@" preordered: %@ |%@ |%@ |%@ ",corner1234[0],corner1234[1],corner1234[2],corner1234[3]);
    //DHS if the colors get re-ordered, then all their associated values must be as well!
    //NSLog(@" max %d t1 %d t2 %d min %d",max,t1,t2,min);
    orderedColor1  = corner1234[orderedIndices[0]];
    orderedColor2  = corner1234[orderedIndices[1]];
    orderedColor3  = corner1234[orderedIndices[2]];
    orderedColor4  = corner1234[orderedIndices[3]];
}    //end orderColors

//==========CameraVC=========================================================================
//These next two are just helper methods for getLAB
//formula off internet
-(double )xyzc : (double)c {
    
    c=((c)>0.04045)? pow((((c)+0.055)/1.055),2.4)*100 :(c)/12.92*100;
    return c;
}


@end
