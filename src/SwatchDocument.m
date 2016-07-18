/*
 
 File: SwatchDocument.m
 
 Abstract: Part of the Sketch Sample Code
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Computer, Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Computer,
 Inc. may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2007 Apple Inc. All Rights Reserved.
 
 */


#import <objc/objc-runtime.h>
#import "SwatchDocument.h"
#import "DataReader.h"

#define HEIGHT	600
#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

const int BLOCK_GROUP_START = 0xc001;
const int BLOCK_GROUP_END = 0xc002;
const int BLOCK_COLOR = 0x0001;

enum ColorMode
{
	ColorModeUndefined = -1,
	ColorModeCMYK,
	ColorModeRGB,
	ColorModeLAB,
	ColorModeGray
};

enum ColorType
{
	ColorTypeUndefined = -1,
	ColorTypeGlobal,
	ColorTypeSpot,
	ColorTypeNormal
};

struct SwatchColor
{
	NSString * name;
	NSString * group;
	enum ColorMode mode;
	enum ColorType type;
	NSColor * color;
	float rawValues[4];
	int rawValuesCount;
};

@implementation SwatchDocument

- (BOOL)readFromURL:(NSURL *)url {
//	[self redirectConsoleLogToDocumentFolder];
	
	// Create colors array
	colors = [[NSMutableArray alloc]init];
	
	// Open data reader
	DataReader* reader = [[DataReader alloc] init];
	[reader readFromURL:url];
	NSLog(@"SwatchPalette: File size [%d]",[reader length]);
	if ([reader length] < 12)
	{
		NSLog(@"SwatchPalette: Invalid asset size [%d]",[reader length]);
		return false;
	}
	
	// Get Header
	NSString * signature = [reader GetString:4];
	int v1 = [reader GetIntOfSize:2];
	int v2 = [reader GetIntOfSize:2];
	NSLog(@"SwatchPalette: signature [%@] version [%d.%d]",signature,v1,v2);
	if (![signature isEqualToString:@"ASEF"])
	{
		NSLog(@"SwatchPalette: Wrong signature [%@]. Must be [ASEF].",signature);
		return false;
	}
	
	// Get blocks
	NSString * groupName = @"";
	int blockCount = [reader GetInt];
	NSLog(@"SwatchPalette: Block count [%d]",blockCount);
	for (int b = 0 ; b < blockCount ; b++)
	{
		int type = [reader GetIntOfSize:2];
		int blockSize = [reader GetInt];
		NSLog(@"SwatchPalette: Block [%d] type [%d] size [%d]",b,type,blockSize);
		
		struct SwatchColor color;
		
		// Color
		if (type == BLOCK_GROUP_START || type == BLOCK_COLOR)
		{
			// Group/Colro name
			int nameSize = [reader GetIntOfSize:2];
			NSLog(@"SwatchPalette: nameSize [%d]",nameSize);
			if (nameSize > 0)
			{
				//  0-terminated string of length (uint16) double-byte characters
				unsigned char * bs = [reader GetBytes:nameSize*2];
				color.name = @"";
				for (int i = 0 ; i < nameSize-1 ; i++)
				{
					NSString *ch = [NSString stringWithFormat:@"%c", bs[(i*2)+1]];
					color.name = [color.name stringByAppendingString:ch];
				}
				NSLog(@"SwatchPalette: Name (%d) [%@]",nameSize,color.name);
			}
			
			if (type == BLOCK_GROUP_START)
			{
				groupName = color.name;
				NSLog(@"SwatchPalette: Group Start [%@]",groupName);
			}
			else //if (type == BLOCK_COLOR)
			{
				color.group = groupName;
				
				NSString * colorMode = [reader GetString:4];
				NSLog(@"SwatchPalette: Color mode [%@]",colorMode);
				if ([colorMode isEqualToString:@"CMYK"])
				{
					color.mode = ColorModeCMYK;
					color.rawValuesCount = 4;
					float C = color.rawValues[0] = [reader GetFloat];
					float M = color.rawValues[1] = [reader GetFloat];
					float Y = color.rawValues[2] = [reader GetFloat];
					float K = color.rawValues[3] = [reader GetFloat];
					float R = (1-C) * (1-K);
					float G = (1-M) * (1-K);
					float B = (1-Y) * (1-K);
					color.color = [NSColor colorWithRed:R green:G blue:B alpha:1];
					[colors addObject:color.color];
//					palette.Add(color);
				}
				else if ([colorMode isEqualToString:@"RGB "])
				{
					color.mode = ColorModeRGB;
					color.rawValuesCount = 3;
					float R = color.rawValues[0] = [reader GetFloat];
					float G = color.rawValues[1] = [reader GetFloat];
					float B = color.rawValues[2] = [reader GetFloat];
					color.color = [NSColor colorWithRed:R green:G blue:B alpha:1];
					[colors addObject:color.color];
//					palette.Add(color);
				}

				else if ([colorMode isEqualToString:@"LAB "])
				{
					color.mode = ColorModeLAB;
					color.rawValuesCount = 3;
					float L = color.rawValues[0] = [reader GetFloat];
					float A = color.rawValues[1] = [reader GetFloat];
					float B = color.rawValues[2] = [reader GetFloat];
//					color.color = [NSColor colorWithRed:R green:G blue:B alpha:1];
//					[colors addObject:color.color];
//					palette.Add(color);
					// No idea what LAB is !!!
					NSLog(@"SwatchPalette: LAB color not supportted (%.3f,%.3f,%.3f)",L,A,B);
				}
				else if ([colorMode isEqualToString:@"Gray"])
				{
					color.mode = ColorModeGray;
					color.rawValuesCount = 1;
					float G = color.rawValues[0] = [reader GetFloat];
					color.color = [NSColor colorWithWhite:G alpha:1];
					[colors addObject:color.color];
//					palette.Add(color);
				}
				
				// Color type
				color.type = [reader GetIntOfSize:2];
			}
		}
		else if (type == BLOCK_GROUP_END)
		{
			NSLog(@"SwatchPalette: Group End");
		}
		else
		{
			NSLog(@"SwatchPalette: Invalid type [%d]",type);
		}
	}
	
	return ([colors count] > 0);
}

- (void) dealloc
{
	if (colors)
		[colors dealloc];
	[super dealloc];
}


- (NSSize)canvasSize {
	NSSize size = { CLAMP(colors.count, 2, 4)*(HEIGHT/2), HEIGHT };
	return size;
}


// Added for Quick Look generator
- (void)drawDocumentInContext:(NSGraphicsContext *)context
{
	// Init
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [context saveGraphicsState];

	// Draw!
	{
		NSSize size = [self canvasSize];
		
		int w = size.width / colors.count;
		for (int i = 0 ; i < colors.count ; ++i)
		{
			[colors[i] setFill];
			NSRect aRect = NSMakeRect(w*i, 0.0, w, size.height);
			NSRectFill(aRect);
		}
	}
	
	// Finalize
    [context restoreGraphicsState];
    [NSGraphicsContext restoreGraphicsState];
}

- (void) redirectConsoleLogToDocumentFolder
{
	NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"console.txt"];
	freopen([logPath fileSystemRepresentation],"a+",stderr);
}


@end


