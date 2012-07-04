//
//  UITableViewCell+CustomFrameModification.m
//  Oplop
//
//  Created by Daniel Arndt on 10.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+CustomFrameModification.h"

@implementation UITableViewCell (CustomFrameModification)

const int __custom_x = 7;
const int __custom_y = 2;

- (void)setFrame:(CGRect)frame {
    frame.origin.x += __custom_x;
    frame.size.width -= 2 * __custom_x;
    frame.origin.y += __custom_y;
    frame.size.height -= 2 * __custom_y;
    [super setFrame:frame];
}

@end
