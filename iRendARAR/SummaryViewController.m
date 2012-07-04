//
//  SummaryViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SummaryViewController.h"
#import "Score.h"

@interface SummaryViewController ()

@property (strong, nonatomic) NSMutableArray* finishedParts;
@property (strong, nonatomic) IBOutlet UITableView* tv;
@property (strong, nonatomic) IBOutlet UILabel* scoreLabel;

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

    self.finishedParts = [[NSMutableArray alloc] init];
    [self.finishedParts addObject:@"Durch die Mosel schwimmen"];
    [self.finishedParts addObject:@"Passanten mit Steinen bewerfen"];
    [self.finishedParts addObject:@"Auf die Seilbahn klettern"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:(@selector(scoreChanged)) name:@"scoreChanged" object:nil];
    
}



-(void)scoreChanged:(NSNotification*)notification {
    if ([[notification object] isKindOfClass:[NSNumber class]]) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d Punkte", [[notification object] intValue]];
    }
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark tableview shit

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.finishedParts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }   
    
    cell.textLabel.text = self.finishedParts[indexPath.row];
    
    // checkmarks for stuff done, disclosure for the current thingie
    cell.accessoryType = ([self.finishedParts count] == (indexPath.row + 1)) ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Bitte eine Route wählen";
}


@end
