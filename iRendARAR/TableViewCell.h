//
//  TableViewCell.h
//  Evade
//
//  Created by Stephen Heaps on 07/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell {
}

@property (nonatomic, copy, setter=setBazinga:) NSString * _bazinga;

- (void)drawRect:(CGRect)rect;
- (void)dealloc;

@end