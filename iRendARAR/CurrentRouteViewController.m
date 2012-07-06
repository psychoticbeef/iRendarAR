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
    
    Annotation* annotation1 = [[Annotation alloc] init];
    annotation1.title = @"Dominiks Buero";
    annotation1.subtitle = @"Er tut so, als sei er nicht anwesend";
    CLLocationCoordinate2D coordinate1;
    coordinate1.latitude = 50.3;
    coordinate1.longitude = 7.6;
    annotation1.coordinate = coordinate1;
    
    
#pragma mark overlay test
    
    CLLocationCoordinate2D a, b, c, d;
    a.latitude = 50.3;
    a.longitude = 7.6;
    b.latitude = 50.4;
    b.longitude = 7.7;
    c.latitude = 50.2;
    c.longitude = 8.1;
    d.latitude = 50.3;
    d.longitude = 7.6;
    
    CLLocationCoordinate2D coordinates[4];
    coordinates[0] = a;
    coordinates[1] = b;
    coordinates[2] = c;
    coordinates[3] = d;
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates: coordinates count: 4];
    [self.mapView addOverlay:route];
    

    
    MKMapRect flyTo = MKMapRectNull;
//	for (id  annotation in annotations) {
//		NSLog(@"fly to on");
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
//        if (MKMapRectIsNull(flyTo)) {
//            flyTo = pointRect;
//        } else {
//            flyTo = MKMapRectUnion(flyTo, pointRect);
//        }
//    }
    
    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation1.coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
    if (MKMapRectIsNull(flyTo)) {
        flyTo = pointRect;
    } else {
        flyTo = MKMapRectUnion(flyTo, pointRect);
    }
    
    [self.mapView addAnnotation:annotation1];
    
    // Position the map so that all overlays and annotations are visible on screen.
    self.mapView.visibleMapRect = flyTo;
    self.mapView.delegate = self;
}

- (void)loadXML {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/test.xml"]]];
    self.graph = [[Graph alloc] init];
    [parser setDelegate:self.graph];
    
    bool wtf = ![parser parse];
    if (wtf) {
        DebugLog(@"XML parsing failed: %@", [parser parserError]);
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
