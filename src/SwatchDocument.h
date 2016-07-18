//
// File: SwatchDocument.h
// Version: 1.0
//

#import <Cocoa/Cocoa.h>

@interface SwatchDocument : NSObject {
    @private

	NSMutableArray *colors;

}

// Return the current value of the property.
- (NSSize)canvasSize;

// Added for Quick Look generator
- (void)drawDocumentInContext:(NSGraphicsContext *)context;
- (BOOL)readFromURL:(NSURL *)url;


@end
