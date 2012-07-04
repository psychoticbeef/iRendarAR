//
//  TableViewCell.m
//  Evade
//
//  Created by Stephen Heaps on 07/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewCell.h"
#import "UITableViewCell+CustomFrameModification.h"
#import <QuartzCore/QuartzCore.h>

@implementation TableViewCell

@synthesize _bazinga = bazinga;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.layer.cornerRadius = 8.0f;
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

- (void)setBazinga:(NSString *)string {
    bazinga = [string copy];
    self.accessibilityLabel = bazinga;
	[self setNeedsDisplay];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	size_t num_locations = 2;
	CGFloat locations[2] = {0.0, 1.0};
	CGFloat components[8] = {0.8f, 0.8f, 0.8f, 1.0f, // Bottom Colour: Red, Green, Blue, Alpha.
		0.9f, 0.9f, 0.9f, 1.0}; // Top Colour: Red, Green, Blue, Alpha.
	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
													  locations, num_locations);
	
	CGColorSpaceRelease(myColorspace);
	
	CGPoint startPoint, endPoint;
	startPoint.x = 0.0;
	startPoint.y = self.frame.size.height;
	endPoint.x = 0.0;
	endPoint.y = 0.0;
	CGContextDrawLinearGradient (c, myGradient, startPoint, endPoint, 0);
	
	const CGFloat topSepColor[] = { 0.8f, 0.8f, 0.8f, 1.0f }; // Cell Seperator Colour - Top
	
	CGGradientRelease(myGradient);
	
	CGContextSetStrokeColor(c, topSepColor);
	
	CGContextMoveToPoint(c, 0.0, 0.0);
	CGContextSetLineWidth(c, 1.0);
	CGContextSetLineCap(c, kCGLineCapRound);
	CGContextAddLineToPoint(c, self.frame.size.width, 0.0);
	CGContextStrokePath(c);
	
	const CGFloat bottomSepColor[] = { 0.5f, 0.5f, 0.5f, 1.0f }; // Cell Seperator Colour - Bottom
	CGContextSetStrokeColor(c, bottomSepColor);
	
	CGContextMoveToPoint(c, 0.0, self.frame.size.height);
	CGContextSetLineWidth(c, 1.0);
	CGContextSetLineCap(c, kCGLineCapRound);
	CGContextAddLineToPoint(c, self.frame.size.width, self.frame.size.height);
	CGContextStrokePath(c);
	
	[[UIColor blackColor] set];
	[bazinga drawInRect:CGRectMake(10, self.frame.size.height / 3.5, self.frame.size.width - 20, self.frame.size.height - 10) withFont:[UIFont boldSystemFontOfSize:15] lineBreakMode:UILineBreakModeWordWrap];
}

- (void)dealloc {
}


@end
