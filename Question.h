//
//  Question.h
//  iRendARAR
//
//  Created by Daniel on 27.07.12.
//
//

#import <Foundation/Foundation.h>

@interface Question : NSObject  <UITableViewDataSource>

@property (nonatomic, retain) NSString* questionText;
@property (nonatomic, retain) NSMutableArray* answers;
@property (nonatomic) NSUInteger number;
@property (nonatomic) NSUInteger total;
@property (nonatomic) NSInteger selectedAnswers;	// bitwise & for every answer given

@end
