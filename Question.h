//
//  Question.h
//  iRendARAR
//
//  Created by Daniel on 27.07.12.
//
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (nonatomic, retain) NSString* questionText;
@property (nonatomic, retain) NSMutableArray* answers;

@end
