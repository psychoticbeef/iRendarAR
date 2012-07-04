//
//  Route.h
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (nonatomic, strong) NSString* longname;
@property (nonatomic, strong) NSString* shortname;
@property (nonatomic, strong) NSString* filename;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) NSURL* zipfile;

@end
