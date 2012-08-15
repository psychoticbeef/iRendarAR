//
//  MultipleChoiceViewController.h
//  iRendARAR
//
//  Created by Daniel Arndt on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface MultipleChoiceViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, QuestionDelegate>

@property (nonatomic, weak) NSMutableArray* questions;

@end
