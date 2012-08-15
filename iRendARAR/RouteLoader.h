//
//  RouteLoader.h
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RouteLoaderDelegate
- (void)routeLoaderDidFinishLoading;
- (void)routeLoaderDidFinishWithError;
@end


@interface RouteLoader : NSObject <UITableViewDataSource>

- (void)loadRoutes;
- (void)locationDidChange;

@property (weak) id<RouteLoaderDelegate> delegate;
@property (readonly, strong) NSArray* routes;


@end
