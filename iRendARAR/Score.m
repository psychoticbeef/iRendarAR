//
//  Score.m
//  iRendARAR
//
//  Created by Daniel Arndt on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Score.h"
#import "DirtyHack.h"

@interface Score ()

@property (readwrite) NSInteger score;

@end

@implementation Score

-(id)init {
	self = [super init];
	
    if (self) {
    }
    
    return self;
}

-(void)modifyScore:(int)amount {
    self.score += amount;
	
	[DirtyHack sharedInstance].score = self.score;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scoreDidChange" object:[NSNumber numberWithInteger:self.score]];
}

@end
