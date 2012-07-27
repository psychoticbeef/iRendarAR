//
//  Answer.h
//  iRendARAR
//
//  Created by Daniel on 27.07.12.
//
//

#import <Foundation/Foundation.h>

@interface Answer : NSObject

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* answerText;
@property (nonatomic, assign) int points;
@property (nonatomic, assign) bool isCorrect;


@end
