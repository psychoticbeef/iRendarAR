//
//  CurrentRouteViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentRouteViewController.h"

@interface CurrentRouteViewController ()

@property (readwrite, atomic) AppState appState;

@property (strong, nonatomic) UIAccelerometer* accelerometer;
@property (weak, nonatomic) IBOutlet UILabel* label;
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) ARDemoViewController* arViewController;
@property (strong, nonatomic) Graph* graph;
@property (strong, nonatomic) StationViewController* stationDetailViewController;

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
    
    
    
#pragma mark overlay test
    
    self.mapView.delegate = self;
}

- (void)drawPolygonForNode {
	GraphNode* node = self.graph.nodes[0];
	
	NSLog(@"%i", node.questions.count);
	
	NSLog(@"%@", node);
	
	for (unsigned int i = 0; i < [node numberOfPossibleNextRoutes]; i++) {
		MKPolyline *route = [MKPolyline polylineWithCoordinates:[node getLocationCoordinateCollection:i] count:[node getLocationCoordinateCollectionCount:i]];
		[self.mapView addOverlay:route];
	}
}

MKMapRect flyTo;

- (void)drawAnnotations {
	flyTo = MKMapRectNull;
	
	GraphNode* node = self.graph.nodes[0];

	
	for (int i = 0; i < node.outputNode.count; i++) {
		GraphNode* successorNode = node.outputNode[i];
		Annotation* annotation = [self addAnnotation:successorNode addToRect:YES];
		[self.mapView addAnnotation:annotation];
	}
	
	Annotation* annotation = [self addAnnotation:node addToRect:YES];
	[self.mapView addAnnotation:annotation];

    self.mapView.visibleMapRect = flyTo;
}

- (void)drawAnnotationStations {
	for (GraphNode* node in self.graph.annotationStations) {
		Annotation* annotation = [self addAnnotation:node addToRect:NO];
		[self.mapView addAnnotation:annotation];
	}
}

- (Annotation*)addAnnotation:(GraphNode*)successorNode addToRect:(BOOL)add {
	Annotation* annotation = [[Annotation alloc] init];
	annotation.title = successorNode.name;
	annotation.subtitle = @"";
	annotation.coordinate = successorNode.location;
	
	if (add) {
		MKMapPoint annotationPoint = MKMapPointForCoordinate(successorNode.location);
		MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
		
		if (MKMapRectIsNull(flyTo)) {
			flyTo = pointRect;
		} else {
			flyTo = MKMapRectUnion(flyTo, pointRect);
		}
	}
	
	return annotation;
}

- (void)loadXML {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/test.xml"]]];
	NSLog(@"%@", [NSBundle.mainBundle.bundlePath stringByAppendingString:@"/test.xml"]);
    self.graph = [[Graph alloc] init];
    [parser setDelegate:self.graph];
    
    bool wtf = ![parser parse];
    if (wtf) {
        DebugLog(@"XML parsing failed: %@", [parser parserError]);
    } else {
		[self drawPolygonForNode];
		[self drawAnnotations];
		[self drawAnnotationStations];
	}
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
//    if ([annotation isKindOfClass:[MKUserLocation class]]) {
//        return nil;
//    }

    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    pinView.pinColor = MKPinAnnotationColorGreen;
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton setTitle:annotation.title forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = rightButton;
    pinView.leftCalloutAccessoryView = rightButton;
    
    // to add an image to the left side of an annotation thingie
    
    UIImageView* profileIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dominik.png"]];
    pinView.leftCalloutAccessoryView = profileIcon;
    
    return pinView;
}

-(IBAction)showDetails:(id)sender {
//    StationDetailView
    self.stationDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StationDetailView"];
    [self.navigationController pushViewController:self.stationDetailViewController animated:YES];

}




- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
    polylineView.lineWidth = 0;
    polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];

    return polylineView;
    
}

@end
