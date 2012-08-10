//
//  StationViewController.h
//  iRendARAR
//
//  Created by Daniel Arndt on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleChoiceViewController.h"
#import "GraphNode.h"

@protocol MultipleChoiceDelegate
- (void)answeredQuestion;
@end


@interface StationViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) GraphNode* node;
@property (nonatomic, weak) id<MultipleChoiceDelegate> delegate;


@end
