//
//  DirtyHack.h
//  iRendARAR
//
//  Created by Daniel on 09.08.12.
//
//

#import <Foundation/Foundation.h>
#import "GraphNode.h"

@interface DirtyHack : NSObject

@property (nonatomic, weak) NSArray* visitedStations;
@property (nonatomic) NSInteger score;
@property (nonatomic, retain) NSString* routeName;
@property (nonatomic, retain) GraphNode* currentStation;

+ (DirtyHack*)sharedInstance;

@end
