//
//  CurrentRouteViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentRouteViewController.h"
#import "MKPolyline+EncodedString.h"
#import <AudioToolbox/AudioServices.h>
#import "BSEPolyline.h"
#import "ARGeoCoordinate.h"
#import "ARViewController.h"
#import "ARCoordinate.h"
#import "ARGeoViewController.h"
#import "DirtyHack.h"

	// dat is for while sitting in der bude, debugging
//#define TESTMODE

//#define DRAW_ALL_ROUTES_TEST

//#define AR_ENABLED

@interface CurrentRouteViewController ()

@property (readwrite) AppState appState;

@property (strong, nonatomic) UIAccelerometer* accelerometer;
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) ARGeoViewController* arViewController;
@property (strong, nonatomic) Graph* graph;
@property (strong, nonatomic) StationViewController* stationDetailViewController;
@property (nonatomic) MKMapRect flyTo;
@property (nonatomic) bool gameOver;
@property (readwrite) bool isRestoringSavedState;

@property (nonatomic, retain) NSMutableArray* temporaryAnnotations;
@property (nonatomic, retain) NSMutableArray* temporaryOverlays;
@property (nonatomic, retain) MultipleChoiceViewController* multipleChoiceViewController;

@property (nonatomic) SystemSoundID soundID;
@property (nonatomic) OSStatus audioErrorCode;

@property (nonatomic) BOOL canProgress;

@property (nonatomic) NSUInteger vibrationCount;

@property (nonatomic) NSMutableArray* purplePolylines;

@property (nonatomic) BOOL canDoAR;

@end

@implementation CurrentRouteViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self loadXML];
	
	NSString* str =  [[NSBundle mainBundle] pathForResource:@"out" ofType:@"caf"];
	
	CFURLRef soundFileURL = (__bridge CFURLRef)[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	SystemSoundID soundID = 0;
	self.audioErrorCode = AudioServicesCreateSystemSoundID(soundFileURL, &soundID);
	self.soundID = soundID;

	
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    
    self.appState = NONE;
    
    self.arViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"arview"];
	[self.arViewController lol];
	self.arViewController.debugMode = NO;
	self.arViewController.delegate = self;
	self.arViewController.scaleViewsBasedOnDistance = YES;
	self.arViewController.minimumScaleFactor = .5;
	self.arViewController.rotateViewsBasedOnPerspective = NO;
	
	NSMutableArray *tempLocationArray = [[NSMutableArray alloc] init];
	
	for (GraphNode* node in self.graph.annotationStations) {
		CLLocation *tempLocation;
		ARGeoCoordinate *tempCoordinate;
		
		tempLocation = [[CLLocation alloc] initWithCoordinate:node.location altitude:1609.0 horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:[NSDate date]];
		
		tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
		tempCoordinate.title = node.name;
		
		NSLog(@"%@", node.name);
		
		[tempLocationArray addObject:tempCoordinate];
	}

	[self.arViewController addCoordinates:tempLocationArray];
//50.446137,7.461777
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:50.446137 longitude:7.461777];
//	self.arViewController.centerCoordinate = newCenter;
	self.arViewController.centerLocation = newCenter;
	[self.arViewController startListening];


	
    self.mapView.delegate = self;
	
	self.flyTo = MKMapRectNull;
	
	self.temporaryAnnotations = [[NSMutableArray alloc] init];
	self.temporaryOverlays = [[NSMutableArray alloc] init];

	self.canDoAR = YES;
#ifndef AR_ENABLED
	self.canDoAR = NO;
#endif
	
	[DirtyHack sharedInstance].mapView = self.mapView;
}


- (void)progressedToNextStation {
	//	[self.mapView removeOverlays:self.mapView.overlays];
	for (GraphNode* node in self.graph.graphRoot.currentNode.outputNode) { // in the beginning our graph is undirected
		unsigned int index = [node.outputNode indexOfObject:self.graph.graphRoot.currentNode];
		if (index != NSNotFound) {
			[node.outputNode removeObjectAtIndex:index];	// it BECOMES the cup. err directed.
			[node.outputJSON removeObjectAtIndex:index];	// the app can flow. or it can crash.
																										// be water my friend
		}
	}
	[self drawRoutes];
	[self drawAnnotationsForFollowupStation];
	if (!self.isRestoringSavedState) {
		[self.graph save];
	}
	
	[self setupLocationListener];
}

- (void)didArriveAtLocation:(NSString*)identifer {
	DebugLog(@"did arrive! %@", identifer);
	
	[[GPSManager sharedInstance] clearNotifications];

	if (self.graph.graphRoot.currentNode.isEndStation || self.graph.graphRoot.currentNode.outputNode.count == 0) {
		self.gameOver = YES;
		UIAlertView* lel = [[UIAlertView alloc] initWithTitle:@"Fertig" message:@"Herzlichen Glückwunsch! Du hast das Ziel erreicht!" delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:nil, nil];
		[lel show];
		return;
	}
	
	[self.mapView removeOverlays:self.mapView.overlays];

	
	for (GraphNode* node in self.graph.graphRoot.currentNode.outputNode) {
		if ([node.identifier isEqualToString:identifer]) {
			NSUInteger index = [self.graph.graphRoot.currentNode.outputNode indexOfObject:node];
			
			if (self.temporaryAnnotations.count > 0) {
				Annotation* annotation = [self.temporaryAnnotations objectAtIndex:index];
				annotation.type = VISITED;
				
				[self.temporaryOverlays removeObjectAtIndex:index];
				[self.mapView removeOverlays:self.temporaryOverlays];
				[self.temporaryOverlays removeAllObjects];
				
				[self.mapView removeAnnotations:self.temporaryAnnotations];
				[self.temporaryAnnotations removeAllObjects];
				
				[self.mapView addAnnotation:annotation];
			}
			
			[self.graph.graphRoot setNodeAsCurrentNode:node];
			
			break;
		}
	}
	
	[self.mapView setNeedsDisplay];

	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
		if (!self.audioErrorCode) AudioServicesPlaySystemSound(self.soundID);
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(vibrate:) userInfo:nil repeats:YES];
	}

	if (![self showDetailsForNode:self.graph.graphRoot.currentNode]) {
		if (!self.graph.graphRoot.currentNode.isEndStation) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self progressedToNextStation];
			});
		}
	}
}


- (void)vibrate:(NSTimer*)timer {
	if (self.vibrationCount++ == 5) {
		[timer invalidate];
		self.vibrationCount = 0;
	}
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateInactive)AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	else {
		[timer invalidate];
		self.vibrationCount = 0;
	}
}


- (bool)showDetailsForNode:(GraphNode*) node {
	// if there's media, show media
	if (node.media.count > 0) {
		self.stationDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StationDetailView"];
		self.stationDetailViewController.node = node;
		self.stationDetailViewController.delegate = self;
		[self.navigationController pushViewController:self.stationDetailViewController animated:YES];
		// if there's no media, but questions, show those instead
	} else if (node.questions.count > 0) {
		self.multipleChoiceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"multipleChoice"];
		self.multipleChoiceViewController.questions = node.questions;
		self.multipleChoiceViewController.delegate = self;
		[self.navigationController pushViewController:self.multipleChoiceViewController animated:YES];
		// otherwise just continue with the following station(s)
	} else {
		return false;
	}
	
	return true;
}

- (void)answeredQuestions {
	self.canProgress = YES;
}

- (void)drawRoutes {
#ifndef DRAW_ALL_ROUTES_TEST
	GraphNode* node = self.graph.graphRoot.currentNode;
	
	self.purplePolylines = [[NSMutableArray alloc] init];

	NSArray* followupNodes = [GraphRoot getFollowupStationsIgnoringTriggers:node];
	
	for (GraphNode* tmpNode in node.outputNode) {
		MKCircle* circle = [MKCircle circleWithCenterCoordinate:tmpNode.location radius:tmpNode.radius];
		[self.mapView addOverlay:circle];
	}
		// move back inside if (tmp.type == TRIGGER) to only draw circles around triggers
		
	NSMutableSet* json = [[NSMutableSet alloc] init];
	for (GraphNode* tmpNode in followupNodes) {
		for (NSString* encString in tmpNode.outputJSON)
			[json addObject:encString];
	}
	
	for (NSString* routeline in json) {
		MKPolyline* line = [MKPolyline polylineWithEncodedString:routeline];
		[self.purplePolylines addObject:line];
		[self.temporaryOverlays addObject:line];
		[self.mapView addOverlay:line];
	}
	
	[self.mapView removeAnnotations:self.mapView.annotations];
#else
	NSLog(@"allnodes count %i", self.graph.graphRoot.allNodes.count);
	for (GraphNode* node in self.graph.graphRoot.allNodes) {
		for (NSString* json in node.outputJSON) {
			MKPolyline* line = [MKPolyline polylineWithEncodedString:json];
			[self.mapView addOverlay:line];
		}
	}
	
#endif
}

- (void)setupLocationListener {
	[[GPSManager sharedInstance] pauseNotifications:YES];
	[[GPSManager sharedInstance] clearNotifications];
	GraphNode* node = self.graph.graphRoot.currentNode;
	
	for (GraphNode* followupNode in node.outputNode) {
		[[GPSManager sharedInstance] notifyWhenAtLocation:followupNode.location withRadius:(int)followupNode.radius identifier:followupNode.identifier delegate:self];
	}
	[[GPSManager sharedInstance] pauseNotifications:NO];
}

- (void)drawAnnotationsForFollowupStation {
	GraphNode* node = self.graph.graphRoot.currentNode;	// add last visited node as bounding box thing
	
	// add the current location of the user to the box
	MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.userLocation.location.coordinate);
	MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
	self.flyTo = pointRect;
	
	// add all possible follow-up nodes as box
	AnnotationType type = self.isRestoringSavedState ? VISITED : CURRENT;
	
	NSArray* outputNodes = [GraphRoot getFollowupStationsIgnoringTriggers:node];
	for (GraphNode* node in outputNodes) {
		assert(node.type != TRIGGER);
		Annotation* annotation = [self addAnnotation:node addToRect:YES annotationType:type];
		[self.temporaryAnnotations addObject:annotation];
		[self.mapView addAnnotation:annotation];
	}

	// @todo: check if this is OK. went from "what if the next station is a trigger?" to "omg check all sub stations captain"
//	for (unsigned int i = 0; i < node.outputNode.count; i++) {
//		GraphNode* successorNode = node.outputNode[i];
//		
//		if (successorNode.type == TRIGGER) {
//			for (GraphNode* node in successorNode.outputNode) {
//				Annotation* annotation = [self addAnnotation:node addToRect:YES annotationType:type];
//				[self.temporaryAnnotations addObject:annotation];
//				[self.mapView addAnnotation:annotation];
//			}
//		} else {
//			Annotation* annotation = [self addAnnotation:successorNode addToRect:YES annotationType:type];
//			[self.temporaryAnnotations addObject:annotation];
//			[self.mapView addAnnotation:annotation];
//		}
//	}
	
	// when we're done, we're done.
	if (!self.gameOver) [self.mapView setVisibleMapRect:self.flyTo edgePadding:UIEdgeInsetsMake(50, 100, 50, 50) animated:YES];
}

- (void)drawAnnotationStations {
	for (GraphNode* node in self.graph.annotationStations) {
		Annotation* annotation = [self addAnnotation:node addToRect:NO annotationType:STATIC];
		[self.mapView addAnnotation:annotation];
	}
}

- (Annotation*)addAnnotation:(GraphNode*)successorNode addToRect:(BOOL)add annotationType:(AnnotationType)type {
	Annotation* annotation = [[Annotation alloc] init];
	annotation.title = successorNode.name;
	annotation.subtitle = @"";
	annotation.coordinate = successorNode.location;
	annotation.type = type;
	annotation.node = successorNode;
	
	if (add) {
		MKMapPoint annotationPoint = MKMapPointForCoordinate(successorNode.location);
		MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
		
		if (MKMapRectIsNull(self.flyTo)) {
			self.flyTo = pointRect;
		} else {
			self.flyTo = MKMapRectUnion(self.flyTo, pointRect);
		}
	}
	
	return annotation;
}

- (void)load {
	//	self.playerHasArrived = YES;
	self.isRestoringSavedState = YES;
	[self.graph load];
	for (unsigned int i = 0; i < self.graph.graphRoot.visitedNodes.count; i++) {
		[self.graph.graphRoot setNodeAsCurrentNode:self.graph.graphRoot.visitedNodes[i]];
		[self drawRoutes];
		if (i == self.graph.graphRoot.visitedNodes.count-1) self.isRestoringSavedState = NO;
		[self drawAnnotationsForFollowupStation];
	}
	[self setupLocationListener];
}

- (void)loadXML {
	// remove overlays ("routes")
	[self.mapView removeOverlays:self.mapView.overlays];
	// remove all annotations
	id userAnnotation = self.mapView.userLocation;
    NSMutableArray *annotations = [self.mapView.annotations mutableCopy];
    [annotations removeObject:userAnnotation];
	// remove all annotations, except the user position, which we removed from the removal list. so smart.
	// no blinking :o
    [self.mapView removeAnnotations:annotations];
	
	NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:[cachePath stringByAppendingPathComponent:@"/route/index.xml"]]];
	
	DebugLog(@"%@", cachePath);
    self.graph = [[Graph alloc] init];
    [parser setDelegate:self.graph];
    
    bool wtf = ![parser parse];
    if (wtf) {
        DebugLog(@"XML parsing failed: %@", [parser parserError]);
    } else {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:[self.graph.graphRoot.name stringByAppendingString:@"current_node"]]) {
			
			UIAlertView* savedSession = [[UIAlertView alloc] initWithTitle:@"Fortsetzen?" message:@"Diese Route wurde schon einmal begonnen. Am letzten Punkt fortsetzen?" delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:@"Ja", nil];
			[savedSession show];
		} else {
			[self setupMap];
		}
	}
}

- (void)setupMap {
	[self progressedToNextStation];
	[self drawAnnotationStations];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) [self load];
	else [self setupMap];
}


- (void)viewWillAppear:(BOOL)animated {
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
    self.appState = MAP;
	
    self.navigationController.navigationBar.translucent = YES;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
	
	UITabBarItem *tabBarItem = self.tabBarController.tabBar.items[0];
	tabBarItem.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.accelerometer.delegate = nil;
    self.navigationController.navigationBar.translucent = NO;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

- (void)viewDidAppear:(BOOL)animated {
	if (self.canProgress) {
		self.canProgress = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self progressedToNextStation];
		});
	}
//	[self.mapView setNeedsDisplayInRect:MKMapRectWorld];
	self.canDoAR = YES;
#ifndef AR_ENABLED
	self.canDoAR = NO;
#endif
}

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
	if (self.canDoAR) {
		if ((acceleration.y < 0.2) && (acceleration.x > 0.95 || acceleration.x < -0.95)) { // why does 'z' have no influence here? oO
			if (self.appState != CAMERA) {
				self.appState = CAMERA;
				
				//			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
				self.canDoAR = NO;
				[self presentViewController:self.arViewController animated:YES completion:^{
				}];
			}
        }
    }
}


#pragma mark MKMapViewDelegate

-(MKAnnotationView* )mapView:(MKMapView* )mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
	
//	if ([annotation isKindOfClass:[Annotation class]]) {
//		Annotation* a = (Annotation*)annotation;
//		if (a.node.type == DUMMY)
//			return nil;
//	}
	
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    
	Annotation* cast = (Annotation*) annotation;
	pinView.canShowCallout = YES;

#ifndef TESTMODE
	if ((cast.node.media.count > 0 || cast.node.questions.count > 0) /* && cast.type != */  ) {
#endif
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton setTitle:annotation.title forState:UIControlStateNormal];
		pinView.rightCalloutAccessoryView = rightButton;
#ifndef TESTMODE
	}
#endif
	
	switch (cast.type) {
		case STATIC:
			pinView.animatesDrop = NO;
			pinView.pinColor = MKPinAnnotationColorGreen;
			break;
			
		case CURRENT:
			pinView.animatesDrop = YES;
			pinView.pinColor = MKPinAnnotationColorRed;
			break;
			
		case VISITED:
			pinView.animatesDrop = NO;
			pinView.pinColor = MKPinAnnotationColorPurple;
			break;
			
		default:
			break;
	}
    
	
    return pinView;
}

-(IBAction)showDetails:(id)sender {
	NSLog(@"%@ %@", sender, [sender class]);

//	GraphNode* node = self.graph.graphRoot.currentNode;
//	if (node.outputNode.count > 0) {
//		//		if (self.playerHasArrived) {
//		node = node.outputNode[0];
//		//		}
//		[self didArriveAtLocation:node.identifier];
//	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
#ifdef TESTMODE

	// dat si teh testcoed
	Annotation* a = (Annotation*) view.annotation;
	if (a.node.type != VISITED && a.node.type != ANNOTATION)
		[self didArriveAtLocation:a.node.identifier];
	
#else
	
	// dat si teh p0rduction coed. u liek? y/n/m
	
	if ([view.annotation isKindOfClass:[Annotation class]]) {
		Annotation* a = (Annotation*) view.annotation;
		if (a.node.type == VISITED || a.node.type == ANNOTATION || self.graph.graphRoot.currentNode == a.node) {
			[self showDetailsForNode: a.node];
		} else {
			// POPUP INS GESICHT
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erst bei Erreichen der Station" message:@"Die Details zu einer Station werden erst angezeigt, wenn sie erreicht wurde und die Fragen der vorherigen Station beantwortet wurden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
	
#endif
	
}


// different coloring has been disabled. only showing pathes to the next station looks _much_ cleaner

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	
	if ([overlay isKindOfClass:[MKCircle class]]) {
	
		MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay];
		circleView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:1.0];
		
		return circleView;
	}
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
    polylineView.lineWidth = 0;
	if ([self.purplePolylines containsObject:overlay]) {
		polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
		DebugLog(@"purple");
	} else {
		polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
		DebugLog(@"blue");
	}
	
    return polylineView;
    
}



#define BOX_WIDTH 150
#define BOX_HEIGHT 100

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate {
	
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	UIView *tempView = [[UIView alloc] initWithFrame:theFrame];
	
	//tempView.backgroundColor = [UIColor colorWithWhite:.5 alpha:.3];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
	titleLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = coordinate.title;
	[titleLabel sizeToFit];
	
	titleLabel.frame = CGRectMake(BOX_WIDTH / 2.0 - titleLabel.frame.size.width / 2.0 - 4.0, 0, titleLabel.frame.size.width + 8.0, titleLabel.frame.size.height + 8.0);
	
	UIImageView *pointView = [[UIImageView alloc] initWithFrame:CGRectZero];
	pointView.image = [UIImage imageNamed:@"location.png"];
	pointView.frame = CGRectMake((int)(BOX_WIDTH / 2.0 - pointView.image.size.width / 2.0), (int)(BOX_HEIGHT / 2.0 - pointView.image.size.height / 2.0), pointView.image.size.width, pointView.image.size.height);
	
	[tempView addSubview:titleLabel];
	[tempView addSubview:pointView];
	
	return tempView;
}


@end
