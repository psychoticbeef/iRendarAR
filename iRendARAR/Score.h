//
//  Score.h
//  iRendARAR
//
//  Created by Daniel Arndt on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Score : NSObject

@property (readonly) NSInteger score;

-(void)modifyScore:(int)amount;

@end
