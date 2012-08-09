//
//  DirtyHack.h
//  iRendARAR
//
//  Created by Daniel on 09.08.12.
//
//

#import <Foundation/Foundation.h>

@interface DirtyHack : NSObject

@property (nonatomic, weak) NSArray* visitedStations;
@property (nonatomic) NSInteger score;
@property (nonatomic, retain) NSString* routeName;

+ (DirtyHack*)sharedInstance;

@end
