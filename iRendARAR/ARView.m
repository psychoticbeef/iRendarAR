//
//  OverlayView.m
//  AugmentedRealitySample
//
//  Created by Chris Greening on 01/01/2010.
//

#import "ARView.h"

@implementation ARView

@dynamic pathToDraw;


- (void)dealloc {
	if(pathToDraw!=NULL) CGPathRelease(pathToDraw);

    [super dealloc];
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context=UIGraphicsGetCurrentContext();
	// do your drawing here
	CGContextSetLineWidth(context, 1);
	CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
	CGContextAddPath(context, pathToDraw);
	CGContextStrokePath(context);
}

-(void) setPathToDraw:(CGMutablePathRef) newPath {
	if(pathToDraw!=NULL) CGPathRelease(pathToDraw);
	pathToDraw=newPath;
	[self setNeedsDisplay];
}

@end
