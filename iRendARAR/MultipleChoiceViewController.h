//
//  MultipleChoiceViewController.h
//  iRendARAR
//
//  Created by Daniel Arndt on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultipleChoiceViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate>

@property (nonatomic, weak) NSMutableArray* questions;

@end
