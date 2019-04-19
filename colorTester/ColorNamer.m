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
//  DHS 8/1/15: Redid so color data is read from ASCII file. Use 1D array instead of 2D also.
//  DHS 5/8 new method: -(UIColor*) getColorFromName : (NSString *) input
//  DHS 5/23 Make into a singleton...
//  DHS 6/27/18 Removed leading space from returned color names!

#import "ColorNamer.h"

@implementation ColorNamer

static ColorNamer *sharedInstance = nil;

//=====<ColorNamer>======================================================================
// Get the shared instance and create it if necessary.
+ (ColorNamer *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// Array of colorDB strings, 1-Dimensional, with a stride of 8 between records
NSMutableArray *colorsDB =  nil;

//=====<ColorNamer>======================================================================
-(instancetype) init
{
    if (self = [super init])
    {
        //Get the home folder...
        home     = NSHomeDirectory();
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        // Data is living in the colorDB folder, travels with app...
        dbhome   = [bundleRoot stringByAppendingPathComponent:@"colorDB"];
        colorsDB = [[NSMutableArray alloc ] init];
        [self loadColorDB];
        putils = [[PixUtils alloc] init];
    }
    return self;
} //end init

//=====<ColorNamer>======================================================================
-(void) loadColorDB
{
    NSError *error;
    NSString *fileContentsAscii;
    NSString *path;
    NSArray *sItems;
    int itemcount;
    int loop,loop1;

    //File is ./colorDB/colorDB.txt
    path = [[NSBundle mainBundle] pathForResource:@"colorDB" ofType:@"txt" inDirectory:@"colorDB"];
    //NSLog(@"load colorDB...%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
       //  NSLog(@" ERROR: bad/missing ColorDB File");
        return ;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if (url == nil)
    {
       //  NSLog(@" ERROR: bad ColorDB URL");
        return ;
    }
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    sItems    = [fileContentsAscii componentsSeparatedByString:@"\n"];
    linecount = (int)[sItems count];
    //NSLog(@"found %d lines...",linecount);
    for(loop=0;loop<linecount;loop++)
    {
        NSString *nextline;
        NSArray *lItems;
        nextline  = [sItems objectAtIndex:loop];
        lItems    = [nextline componentsSeparatedByString:@","];
        itemcount = (int)[lItems count];
        itemcount--;  //account for EOL comma
        if (loop == 0) stride = itemcount;
        //if (loop % 100 == 0) NSLog(@" line %d",loop);
        for(loop1=0;loop1<itemcount;loop1++)
        {
            NSString *duh = [lItems objectAtIndex:loop1];
            //NSLog(@" duh[%d] %@",loop1,duh);
            [colorsDB addObject:duh];
        }
    }
    linecount--;
    //NSLog(@" ...final colorDB size %lu stride %d linecount %d longest (%d): %@",
    //      (unsigned long)[colorsDB count],stride,linecount,longestNameLen,longestName);
    return;
} //end loadColorDB


//===HDKGenerator===================================================================
- (NSString *) getHexFromColor : (UIColor *) colorin
{
    const CGFloat* components = CGColorGetComponents(colorin.CGColor);
    //NSLog(@"Red: %f", components[0]);
    //NSLog(@"Green: %f", components[1]);
    //NSLog(@"Blue: %f", components[2]);
    NSString *hexout = [NSString stringWithFormat:@"%2.2x%2.2x%2.2x",
                        (int)(255.0*components[0]),
                        (int)(255.0*components[1]),
                        (int)(255.0*components[2])
                        ];
    
    return hexout;
} //end getHexFromColor


//=====<ColorNamer>======================================================================
-(NSString *)getNameFromUIColor: (UIColor *) colorin
{
    NSString *hexstr = [self getHexFromColor:colorin];
    
    //hexstr = @"FFF46E";
    NSString *result = [self getNameFromHex:hexstr];
    return result;
} //end getNameFromUIColor


//=====<ColorNamer>======================================================================
//- (NSString *)getName: (NSString*)hex forArray: (NSArray *) colors{
- (NSString *)getNameFromHex: (NSString*)hex
{
    int i0,i1,i2,i3,i4,i5,i6,i7;
    NSString *error = @"invalid color";
    NSString *name; //resulting color name
    hex = [hex uppercaseString];
    //input must be 6 characters
    if([hex length] != 6) return error;
    //Handle bad data load...
    if ([colorsDB count] == 0) return @"Empty colorDB";
    
    NSArray *rgb = [self rgb:hex];
    int r = [rgb[0] intValue];
    int g = [rgb[1] intValue];
    int b = [rgb[2] intValue];
    NSArray *hsl = [self hsl:hex];
    int h = [hsl[0] intValue];
    int s = [hsl[1] intValue];
    int l = [hsl[2] intValue];
    int ndf1 = 0;
    int ndf2 = 0;
    int ndf = 0;
    int cl = -1;
    int df = -1;
    //NSLog(@" cdb count %d",[colorsDB count]);
    //finds the closest hex value and returns corresponding name

    int r1,g1,b1,h1,l1,s1;
    for(int i = 0; i < linecount-1 ; i++)
    {
        i0 = i*stride;
        i1 = i0+1;
        i2 = i0+2;
        i3 = i0+3;
        i4 = i0+4;
        i5 = i0+5;
        i6 = i0+6;
        i7 = i0+7;
        NSString *testName = [colorsDB objectAtIndex:i1];
        //NSLog(@" compare %@ vs %@",hex,testName);
        if ([hex isEqualToString:testName])
            return [colorsDB objectAtIndex:i0];
        r1 = [[colorsDB objectAtIndex:i2] intValue];
        g1 = [[colorsDB objectAtIndex:i3] intValue];
        b1 = [[colorsDB objectAtIndex:i4] intValue];
        h1 = [[colorsDB objectAtIndex:i5] intValue];
        s1 = [[colorsDB objectAtIndex:i6] intValue];
        l1 = [[colorsDB objectAtIndex:i7] intValue];
        
        
        ndf1 = (r - r1)*(r - r1) + (g - g1)*(g - g1) + (b - b1)*(b - b1);
        
        ndf2 = (h - h1)*(h - h1) + (s - s1)*(s - s1) + (l - l1)*(l - l1);
        ndf = ndf1 + ndf2 * 2;
        if(df < 0 || df > ndf)
        {
            df = ndf;
            cl = i;
        }
    }

    //Make sure we're inbounds....
    if (cl >= 0)
    {
        name = [colorsDB objectAtIndex:cl*stride];
        //DHS 6/27 remove leading space
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return (cl < 0 ? error : name);
} //end getNameFromHex


//=====<ColorNamer>======================================================================
//DHS 5/8
-(UIColor*) getColorFromName : (NSString *) input
{
    int i0,i1; //DHS 5/11,i2,i3,i4,i5,i6,i7;
    UIColor *retColor = [UIColor blackColor];
    if ([colorsDB count] == 0) return retColor;
    
    for(int i = 0; i < linecount-1 ; i++)
    {
        i0 = i*stride;
        i1 = i0+1;
//DHS TBD 5/11
//        i2 = i0+2;
//        i3 = i0+3;
//        i4 = i0+4;
//        i5 = i0+5;
//        i6 = i0+6;
//        i7 = i0+7;
        
        NSString *testName = [colorsDB objectAtIndex:i0];
        NSString *hexcolor = [colorsDB objectAtIndex:i1];
        
        //NSLog(@" compare %@ vs %@",hex,testName);
        if ([input isEqualToString:testName])
        {
           // NSLog(@" found %@ at %d colorhex %@",input,i, hexcolor);
            retColor = [putils colorFromHexString : hexcolor];
        }
    }
    return retColor;
}

//=====<ColorNamer>======================================================================
//converts RGB to HSL, returns an array of NSStrings
- (NSArray*)hsl:(NSString *)hex
{
    NSArray *rgb = [self rgb:hex];
    int r = [rgb[0] intValue]/255;
    int g = [rgb[1] intValue]/255;
    int b = [rgb[2] intValue]/255;
    int min;
    int max;
    int delta;
    int h;
    int s;
    double l;
    min = fmin(r, fmin(g, b));
    max = fmax(r, fmax(g, b));
    delta = max - min;
    l = (min + max) / 2;
    
    s = 0;
    if(l > 0 && l < 1)
        s = delta / (l < 0.5 ? (2 * l) : (2 - 2 * l));
    
    h = 0;
    if(delta > 0)
    {
        if (max == r && max != g)
            h += (g - b) / delta;
        if (max == g && max != b)
            h += (2 + (b - r) / delta);
        if (max == b && max != r)
            h += (4 + (r - g) / delta);
        h /= 6;
    }
    unsigned hh = h;
    unsigned ss = s;
    unsigned ll = l;
    NSArray *hsl = @[[NSString stringWithFormat: @"%u",hh],[NSString stringWithFormat: @"%u",ss ],[NSString stringWithFormat: @"%u",ll ]];
    return hsl;
} //end hsl


//=====<ColorNamer>======================================================================
//gets RGB values out of hex, returns a array of NSStrings
- (NSArray*)rgb:(NSString *)hex
{
    NSString *r = [hex substringWithRange:NSMakeRange(0,2)];
    NSString *g = [hex substringWithRange:NSMakeRange(2,2)];
    NSString *b = [hex substringWithRange:NSMakeRange(4,2)];
    NSScanner *scanR = [NSScanner scannerWithString:r];
    NSScanner *scanG = [NSScanner scannerWithString:g];
    NSScanner *scanB = [NSScanner scannerWithString:b];
    unsigned rr = 0;
    unsigned gg = 0;
    unsigned bb = 0;
    [scanR scanHexInt:&rr];
    [scanG scanHexInt:&gg];
    [scanB scanHexInt:&bb];
    NSArray *rgb = @[[NSString stringWithFormat: @"%u",rr],[NSString stringWithFormat: @"%u",gg ],[NSString stringWithFormat: @"%u",bb ]];
    return rgb;
} //end rgb


@end
