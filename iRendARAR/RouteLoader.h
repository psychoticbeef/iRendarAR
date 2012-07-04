//
//  RouteLoader.h
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RouteLoaderDelegate
- (void)routeLoaderDidFinishLoading:(NSArray* )routeList;
@end


@interface RouteLoader : NSObject

-(void)loadRoutes;

@property (weak) id<RouteLoaderDelegate> delegate;

@end
