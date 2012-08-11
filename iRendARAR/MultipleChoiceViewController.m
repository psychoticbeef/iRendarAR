//
//  MultipleChoiceViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultipleChoiceViewController.h"
#import "Question.h"
#import "Answer.h"
#import "UACellBackgroundView.h"

@interface MultipleChoiceViewController ()

@property (weak) IBOutlet UITableView* tv;

@end

@implementation MultipleChoiceViewController

#pragma mark - table view shit

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tv.backgroundColor = [UIColor clearColor];
	self.tv.opaque = NO;
	self.tv.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chalkboard - iPhone.png"]];
	self.tv.dataSource = self.questions[0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


@end
