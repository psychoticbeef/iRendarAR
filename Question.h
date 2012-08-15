//
//  Question.h
//  iRendARAR
//
//  Created by Daniel on 27.07.12.
//
//

#import <Foundation/Foundation.h>

@interface Question : NSObject  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSString* questionText;
@property (nonatomic, retain) NSMutableArray* answers;
@property (nonatomic) NSUInteger number;
@property (nonatomic) NSUInteger total;
@property (nonatomic) NSUInteger selectedAnswers;	// bitwise & for every answer given
@property (nonatomic) NSUInteger correctAnswerBitmask;
@property (nonatomic) BOOL correctlyAnswered;
@property (nonatomic) BOOL answersExhausted;	// clicked every wrong answer there is

@end
