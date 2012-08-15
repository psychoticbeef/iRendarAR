//
//  SummaryViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 
 This Controller shows two things:
	1) routes that we completed
	2) routes that follow once we completed a route
 
 There are some edge cases here, though:
 
	- the very first route is a dummy. it has all starting routes as follow ups
	- we haven't a completed any route yet, thus we only show follow up routes
	- we are at the end, thus there aren't any follow-up routes anymore
 
 Also:
 
 The current route is _not_ visited. So, we have to manage the visited ones, the current one
 and the follow ups to the current one.
 
 The result: several switches & ifs i wouldn't want to debug in a week or so.
 
 Oh, and it does not get any simplified by the fact that i have no clue how i should share
 data between this VC and CurrentRouteVC. The problem is: both are instantiated by the TabBar,
 thus neither one of them has access to the instance of the other. Also, the instantiation of
 this VC is lazy, so messaging is not an option either – except the very dirty way:
 
 "hey, i was instantiated, tell me what's going on". So a singleton, DirtyHack, does the dirty work.
 
 */

#import "SummaryViewController.h"
//#import "Score.h"
#import "DirtyHack.h"

@interface SummaryViewController ()

@property (weak, nonatomic) IBOutlet UITableView* tv;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel;

@end

@implementation SummaryViewController

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
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:(@selector(scoreChanged:)) name:@"scoreChanged" object:nil];
}


-(void)scoreChanged:(NSNotification*)notification {
    if ([[notification object] isKindOfClass:[NSNumber class]]) {
		self.scoreLabel.text = [NSString stringWithFormat:@"%d Punkte", [[notification object] intValue]];
    }
}


//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark tableview shit

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int modifier = 1;
	if ([DirtyHack sharedInstance].currentStation.type == DUMMY) {
		section++;
		modifier--;
	}

	switch (section) {
		case 0:
			return [DirtyHack sharedInstance].visitedStations.count + modifier;

		case 1:
			return [DirtyHack sharedInstance].currentStation.outputNode.count;

		default:
			return 0;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // checkmarks for stuff done, disclosure for the current thingie
	
	GraphNode* node;

	int indexPathSection = indexPath.section;
	if ([DirtyHack sharedInstance].currentStation.type == DUMMY) indexPathSection++;
	
	switch (indexPathSection) {
		case 0:
			if (indexPath.row < [DirtyHack sharedInstance].visitedStations.count) {
				node = [DirtyHack sharedInstance].visitedStations[(NSUInteger) indexPath.row];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else if (indexPath.row == [DirtyHack sharedInstance].visitedStations.count) {
				node = [DirtyHack sharedInstance].currentStation;
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			break;
			
		case 1:
			node = [DirtyHack sharedInstance].currentStation.outputNode[(NSUInteger) indexPath.row];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
			
		default:
			break;
	}

    cell.textLabel.text = node.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int numberOfSections = 0;
	if (![DirtyHack sharedInstance].currentStation.isEndStation) numberOfSections++;
	if ([DirtyHack sharedInstance].currentStation.type != DUMMY) numberOfSections++;
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([DirtyHack sharedInstance].currentStation.type == DUMMY) section++;
	
	NSString *result;

	switch (section) {
		case 0:
			result = @"Bereits besuchte Stationen";
			if (![[DirtyHack sharedInstance].routeName isEqualToString:@""])
				result = [result stringByAppendingFormat:@" von %@", [DirtyHack sharedInstance].routeName];
			break;
		case 1:
			result = @"Nächstmögliche Ziele";
			if (![[DirtyHack sharedInstance].routeName isEqualToString:@""])
				result = [result stringByAppendingFormat:@" von %@", [DirtyHack sharedInstance].routeName];
			break;
			
		default:
			result = @"";
			break;
	}
	
	return result;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tv reloadData];
}


@end
