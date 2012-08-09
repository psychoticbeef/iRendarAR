//
//  DirtyHack.m
//  iRendARAR
//
//  Created by Daniel on 09.08.12.
//
//

#import "DirtyHack.h"

@implementation DirtyHack

+ (DirtyHack*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
