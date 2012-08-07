//
//  CurrentRouteViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// TODO: Remove annotations AND paths we did not visit.

#import "CurrentRouteViewController.h"
#import "MKPolyline+EncodedString.h"

@interface CurrentRouteViewController ()

@property (readwrite, atomic) AppState appState;

@property (strong, nonatomic) UIAccelerometer* accelerometer;
@property (weak, nonatomic) IBOutlet UILabel* label;
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) ARDemoViewController* arViewController;
@property (strong, nonatomic) Graph* graph;
@property (strong, nonatomic) StationViewController* stationDetailViewController;
@property (nonatomic) MKMapRect flyTo;
@property (nonatomic) bool playerHasArrived;
@property (nonatomic) bool gameOver;
@property (atomic) bool isRestoringSavedState;

@property (nonatomic, retain) NSMutableArray* temporaryAnnotations;
@property (nonatomic, retain) NSMutableArray* temporaryOverlays;

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

    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    
    self.appState = NONE;
    
    self.arViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"arview"];

    self.mapView.delegate = self;
	
	self.flyTo = MKMapRectNull;
	
	self.temporaryAnnotations = [[NSMutableArray alloc] init];
	self.temporaryOverlays = [[NSMutableArray alloc] init];
}


- (void)progressedToNextStation {
//	[self.mapView removeOverlays:self.mapView.overlays];
	for (GraphNode* node in self.graph.graphRoot.currentNode.outputNode) { // in the beginning our graph is undirected
		unsigned int index = [node.outputNode indexOfObject:self.graph.graphRoot.currentNode];
		if (index != NSNotFound) {
			[node.outputNode removeObjectAtIndex:index];	// it BECOMES the cup. err directed.
			[node.outputJSON removeObjectAtIndex:index];	// the app can flow. or it can crash.
		}
	}
	[self drawRoutes];
	[self drawAnnotationsForFollowupStation];
	if (!self.isRestoringSavedState) {
		[self setupLocationListener];
	}
}

- (void)didArriveAtLocation:(NSString*)identifer {
	NSLog(@"did arrive at: %@", identifer);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.graph.graphRoot.currentNode.isStartStation) {
			self.playerHasArrived = YES;
			GraphNode* node = self.graph.graphRoot.currentNode;
			for (NSString* json in node.outputJSON) {
				[self.mapView addOverlay:[MKPolyline polylineWithEncodedString:json]];
			}
		}
		if (self.graph.graphRoot.currentNode.isEndStation) {
			self.gameOver = YES;
			[[GPSManager sharedInstance] clearNotifications];
		}
		for (GraphNode* node in self.graph.graphRoot.currentNode.outputNode) {
			if ([node.identifier isEqualToString:identifer]) {
				NSUInteger index = [self.graph.graphRoot.currentNode.outputNode indexOfObject:node];

				if (self.temporaryAnnotations.count > 0) {
					NSLog(@"Keeping Index: %i. Name: %@.", index, node.identifier);
					
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
				
				
//				UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//				localNotif.alertAction = @"HELLO";
//				localNotif.alertBody = @"HELLO";
//				localNotif.fireDate = [NSDate date];
//				
				break;
			}
		}
		[self progressedToNextStation];
	});
}

- (void)drawRoutes {
	GraphNode* node = self.graph.graphRoot.currentNode;
	
	if (self.playerHasArrived) {
		for (NSString* json in node.outputJSON) {
			MKPolyline* line = [MKPolyline polylineWithEncodedString:json];
			[self.temporaryOverlays addObject:line];
			[self.mapView addOverlay:line];
			
		}
	}
}

- (void)setupLocationListener {
	[[GPSManager sharedInstance] clearNotifications];
	GraphNode* node = self.graph.graphRoot.currentNode;
	if (!self.playerHasArrived) {
		[[GPSManager sharedInstance] notifyWhenAtLocation:node.location withRadius:(int)node.radius identifier:node.identifier delegate:self];
	} else {
		for (GraphNode* followupNode in node.outputNode) {
			[[GPSManager sharedInstance] notifyWhenAtLocation:followupNode.location withRadius:(int)followupNode.radius identifier:followupNode.identifier delegate:self];
		}
	}
}

- (void)drawAnnotationsForFollowupStation {
	self.flyTo = MKMapRectNull;	// zooms the map around bounding box of these coordinates
	
	GraphNode* node = self.graph.graphRoot.currentNode;	// add last visited node as bounding box thing
	self.flyTo = MKMapRectUnion(self.flyTo, node.pointRect);
	
	// add the current location of the user to the box
	MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.userLocation.location.coordinate);
	MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
	self.flyTo = MKMapRectUnion(self.flyTo, pointRect);

	// add all possible follow-up nodes as box
	if (!self.gameOver) {
		if (self.playerHasArrived) {
			for (int i = 0; i < node.outputNode.count; i++) {
				GraphNode* successorNode = node.outputNode[i];
				Annotation* annotation = [self addAnnotation:successorNode addToRect:YES annotationType:CURRENT];
				[self.temporaryAnnotations addObject:annotation];
				[self.mapView addAnnotation:annotation];
			}
		} else {
			Annotation* annotation = [self addAnnotation:node addToRect:YES annotationType:CURRENT];
			[self.temporaryAnnotations addObject:annotation];
			[self.mapView addAnnotation:annotation];
		}
	}

	// when we're done, we're done.
	if (!self.gameOver) self.mapView.visibleMapRect = self.flyTo;
}

- (void)drawAnnotationStations {
	for (GraphNode* node in self.graph.annotationStations) {
		Annotation* annotation = [self addAnnotation:node addToRect:NO annotationType:STATIC];
		[self.mapView addAnnotation:annotation];
	}
}

- (Annotation*)addAnnotation:(GraphNode*)successorNode addToRect:(BOOL)add annotationType:(AnnotationType)type{
	Annotation* annotation = [[Annotation alloc] init];
	annotation.title = successorNode.name;
	annotation.subtitle = @"";
	annotation.coordinate = successorNode.location;
	annotation.type = type;
	
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
	self.isRestoringSavedState = YES;
	for (GraphNode* node in self.graph.graphRoot.visitedNodes) {
		[self didArriveAtLocation:node.identifier];
	}
	self.isRestoringSavedState = NO;
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
	
	NSLog(@"%@", cachePath);
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


- (void)viewDidAppear:(BOOL)animated {
    [self loadXML];
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
    self.appState = MAP;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.accelerometer.delegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    if ((acceleration.y < 0.2) && (acceleration.x > 0.95 || acceleration.x < -0.95)) { // why does 'z' have no influence here? oO
        if (self.appState != CAMERA) {
            self.appState = CAMERA;
            [self.navigationController pushViewController:self.arViewController animated:YES];
        }
    }
}


#pragma mark MKMapViewDelegate

-(MKAnnotationView* )mapView:(MKMapView* )mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
	
	Annotation* cast = (Annotation*) annotation;
	switch (cast.type) {
		case STATIC:
			pinView.pinColor = MKPinAnnotationColorGreen;
			break;
			
		case CURRENT:
			pinView.pinColor = MKPinAnnotationColorRed;
			break;
			
		case VISITED:
			pinView.pinColor = MKPinAnnotationColorPurple;
			break;
			
		default:
			break;
	}
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton setTitle:annotation.title forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = rightButton;

    return pinView;
}

-(IBAction)showDetails:(id)sender {
//    StationDetailView
//    self.stationDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StationDetailView"];
//    [self.navigationController pushViewController:self.stationDetailViewController animated:YES];
	
	GraphNode* node = self.graph.graphRoot.currentNode;
	if (node.outputNode.count > 0) {
		if (self.playerHasArrived) {
			node = node.outputNode[0];
		}
		[self didArriveAtLocation:node.identifier];
	}
}




- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
    polylineView.lineWidth = 0;
    polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];

    return polylineView;
    
}

@end
