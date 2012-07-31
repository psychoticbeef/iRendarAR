//
//  RouteGraph.h
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphNode.h"
#import <Foundation/NSJSONSerialization.h> 
#import "GraphRoot.h"
#import <CoreLocation/CoreLocation.h>

@interface Graph : NSObject <NSXMLParserDelegate> {
    
}

@property (readonly, retain) GraphRoot* graphRoot;
@property (nonatomic, retain) NSMutableArray* nodes;
@property (readonly, nonatomic) NSMutableArray* annotationStations;



@end
