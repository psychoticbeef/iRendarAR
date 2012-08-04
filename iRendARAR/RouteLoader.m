//
//  RouteLoader.m
//  iRendARAR
//
//  Created by Daniel Arndt on 27.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteLoader.h"
#import "Route.h"

@interface RouteLoader ()

@property (nonatomic, strong) NSString* urlSettingsFile;
@property (nonatomic, strong) NSString* base_url;
@property (nonatomic, strong) NSString* list_file;
@property (nonatomic, strong) NSMutableDictionary* urlSettings;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSMutableArray* routeList;
@property (nonatomic, strong) NSString* zipURL;

@end


@implementation RouteLoader

-(id)init{
    if (self=[super init]) {
        NSString* bundlePath = [[NSBundle mainBundle] resourcePath]; 
        _urlSettingsFile = [bundlePath stringByAppendingPathComponent:@"url_settings.plist"];
        _urlSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:_urlSettingsFile];
        _base_url = _urlSettings[@"base_url"];
        _list_file = _urlSettings[@"list_file"];
        _url = [NSURL URLWithString:[_base_url stringByAppendingPathComponent:_list_file]];
        _delegate = NULL;
    }
    
    return self;
}

-(void)loadRoutes{
    self.routeList = [[NSMutableArray alloc] init];
    DebugLog(@"Trying to download from URL: %@", self.url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* downloadError = NULL;
        NSString* routeComponents = [NSString stringWithContentsOfURL:self.url encoding:NSUTF8StringEncoding error:&downloadError];
        
        NSArray* routeComponentArray = [routeComponents componentsSeparatedByString:@"\n"];
        
        for (NSString* line in routeComponentArray) {
            if ([line length] > 0) {
                if ([line characterAtIndex:0] != '#') {// lines that start with # are comments
                    NSArray* routeArray = [line componentsSeparatedByString:@"\t"];
                    if ([routeArray count] != 5) {
                        NSLog(@"Routelist Error: %@ broken in line: %@", self.list_file, line);
						NSLog(@"Got %i lines: %@", routeArray.count, routeArray);
                        continue;
                    }
                    
                    Route* route = [[Route alloc] init];
                    route.longname = routeArray[0];
                    route.shortname = routeArray[1];
                    route.filename = routeArray[2];
                    route.latitude = [routeArray[3] floatValue];
                    route.longitude = [routeArray[4] floatValue];
                    route.zipfile = [NSURL URLWithString:[self.base_url stringByAppendingString:route.filename]];
                    
                                        
                    [self.routeList addObject:route];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate routeLoaderDidFinishLoading:[self.routeList copy]];
        });
    });
}

@end
