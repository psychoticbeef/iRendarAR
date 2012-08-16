//
//  ARDemoViewController.m
//  ARDemo
//
//  Created by Chris Greening on 10/10/2010.
//  CMG Research
//

#import "ARDemoViewController.h"
#import "ImageUtils.h"
#import "ARView.h"
#import "Score.h"

@interface ARDemoViewController()

-(void) startCameraCapture;
-(void) stopCameraCapture;

@end


@implementation ARDemoViewController

@synthesize arView;
@synthesize previewView;
@synthesize accelerometer;
@synthesize cameraInput;
@synthesize scoreLabel;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if (acceleration.x < 0.6 && acceleration.x > -0.6) {
		[self dismissViewControllerAnimated:YES completion:^{
		}];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self startCameraCapture];
    self.navigationItem.title = @"camARAR";
    
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = .1;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:(@selector(scoreDidChange)) name:@"scoreDidChange" object:nil];
    
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI/2);
    scoreLabel.transform = rotationTransform;
}

-(void)scoreDidChange:(NSNotification*)notification {
    if ([[notification object] isKindOfClass:[NSNumber class]]) {
        scoreLabel.text = [[notification.object stringValue] stringByAppendingString:@" Punkte"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    accelerometer.delegate = self;
}


- (void)viewWillDisappear:(BOOL)animated {
    accelerometer.delegate = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Camera Capture Control

-(void) startCameraCapture {
	// start capturing frames
	// Create the AVCapture Session
	session = [[AVCaptureSession alloc] init];
	
	// create a preview layer to show the output from the camera
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
	previewLayer.frame = previewView.frame;
	[previewView.layer addSublayer:previewLayer];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

	
	// Get the default camera device
	AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// Create a AVCaptureInput with the camera device
	NSError *error=nil;
	cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (cameraInput == nil) {
		DebugLog(@"Error creating camera capture:%@",error);
	}
	
	// Set the output
	AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	
	// create a queue to run the capture on
	dispatch_queue_t captureQueue=dispatch_queue_create("catpureQueue", NULL);
	
	// setup our delegate
	[videoOutput setSampleBufferDelegate:self queue:captureQueue];

	// configure the pixel format
	videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
									 nil];

	// and the size of the frames we want
	[session setSessionPreset:AVCaptureSessionPresetHigh];

	// Add the input and output
	[session addInput:cameraInput];
	[session addOutput:videoOutput];
	
	// Start the session
	[session startRunning];		
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	// only run if we're not already processing an image
	if(imageToProcess==NULL) {
		// this is the image buffer
		CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
		// Lock the image buffer
		CVPixelBufferLockBaseAddress(cvimgRef,0);
		// access the data
		int width=CVPixelBufferGetWidth(cvimgRef);
		int height=CVPixelBufferGetHeight(cvimgRef);
		// get the raw image bytes
		uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
		size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
		// turn it into something useful
		imageToProcess=createImage(buf, bprow, width, height);
		// trigger the image processing on the main thread
		[self performSelectorOnMainThread:@selector(processImage) withObject:nil waitUntilDone:NO];
	}
}


-(void) stopCameraCapture {
	[session stopRunning];
	[session release];
    [cameraInput release];
	session=nil;
}

#pragma mark -
#pragma mark Image processing

-(void) processImage {
	if(imageToProcess) {
		// move and scale the overlay view so it is on top of the camera image 
		// (the camera image will be aspect scaled to fit in the preview view)
		float scale=MIN(previewView.frame.size.width/imageToProcess->width, 
						previewView.frame.size.height/imageToProcess->height);
		arView.frame=CGRectMake((previewView.frame.size.width-imageToProcess->width*scale)/2,
									 (previewView.frame.size.height-imageToProcess->height*scale)/2,
									 imageToProcess->width, 
									 imageToProcess->height);
		arView.transform=CGAffineTransformMakeScale(scale, scale);
		
		
		// detect vertical lines
//		CGMutablePathRef pathRef=CGPathCreateMutable();
//		int lastX=-1000, lastY=-1000;
//		for(int y=0; y<imageToProcess->height-1; y++) {
//			for(int x=0; x<imageToProcess->width-1; x++) {
//				int edge=(abs(imageToProcess->pixels[y][x]-imageToProcess->pixels[y][x+1])+
//						  abs(imageToProcess->pixels[y][x]-imageToProcess->pixels[y+1][x])+
//						  abs(imageToProcess->pixels[y][x]-imageToProcess->pixels[y+1][x+1]))/3;
//				if(edge>10) {
//					int dist=(x-lastX)*(x-lastX)+(y-lastY)*(y-lastY);
//					if(dist>50) {
//						CGPathMoveToPoint(pathRef, NULL, x, y);
//						lastX=x;
//						lastY=y;
//					} else if(dist>10) {
//						CGPathAddLineToPoint(pathRef, NULL, x, y);
//						lastX=x;
//						lastY=y;
//					}
//				}
//			}
//		}	
		
		// draw the path we've created in our ARView
//		arView.pathToDraw=pathRef;
		
		// done with the image
		destroyImage(imageToProcess);
		imageToProcess=NULL;
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[self stopCameraCapture];
	self.previewView=nil;
}


- (void)dealloc {
	[self stopCameraCapture];
	self.previewView = nil;

	self.arView = nil;

    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


@end
