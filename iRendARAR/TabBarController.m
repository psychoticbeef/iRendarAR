//
//  TabBarController.m
//  iRendARAR
//
//  Created by Daniel on 10.08.12.
//
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

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
	self.graph = [[Graph alloc] init];
	
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"-----------------------------------------------------------");
	NSLog(@"%@", [segue identifier]);
}

@end
