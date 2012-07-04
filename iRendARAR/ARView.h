//
//  OverlayView.h
//  AugmentedRealitySample
//
//  Created by Chris Greening on 01/01/2010.
//

#import <UIKit/UIKit.h>
#import "ImageUtils.h"

#define MAX_LINES 10

@interface ARView : UIView {
	CGMutablePathRef pathToDraw;
}


@property (nonatomic, assign) CGMutablePathRef pathToDraw;


@end

