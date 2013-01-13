//
//  SummaryViewMapController.m
//  iRendARAR
//
//  Created by Daniel on 18.12.12.
//
//

#import "SummaryViewMapController.h"
#import "DirtyHack.h"

@interface SummaryViewMapController ()

@property (weak, nonatomic) IBOutlet MKMapView* mapView;

@end

@implementation SummaryViewMapController

-(void)viewDidAppear:(BOOL)animated {
	[self.mapView addAnnotations:[[DirtyHack sharedInstance].mapView annotations]];
	NSLog(@"%f %f", [DirtyHack sharedInstance].location.latitude, [DirtyHack sharedInstance].location.longitude);

	MKMapPoint annotationPoint = MKMapPointForCoordinate([DirtyHack sharedInstance].location);
	MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);

	[self.mapView setVisibleMapRect:pointRect edgePadding:UIEdgeInsetsMake(50, 100, 50, 50) animated:YES];
//	[self.mapView setVisibleMapRect:self.flyTo edgePadding:UIEdgeInsetsMake(50, 100, 50, 50) animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
