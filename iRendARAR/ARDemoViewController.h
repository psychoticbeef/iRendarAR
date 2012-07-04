//
//  ARDemoViewController.h
//  ARDemo
//
//  Created by Chris Greening on 10/10/2010.
//  CMG Research
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageUtils.h"

@class ARView;

@interface ARDemoViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UIAccelerometerDelegate> {
	AVCaptureSession *session;
	UIView *previewView;
	ARView *arView;
	Image *imageToProcess;
}


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;

@property (nonatomic, retain) IBOutlet UIView *arView;
@property (nonatomic, retain) IBOutlet UIView *previewView;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, assign) UIAccelerometer* accelerometer;
@property (nonatomic, assign) AVCaptureInput* cameraInput;

@end

