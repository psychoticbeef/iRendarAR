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

@property (weak) IBOutlet UIPageControl* pageControl;
@property (weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL pageControlUsed;

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

	CGRect scrollViewFrame = self.scrollView.frame;
	CGRect tableviewFrame = self.scrollView.frame;
	tableviewFrame.origin.y = 0;

	for (int i = 0; i < self.questions.count; i++) {
		CGFloat xOrigin = i * scrollViewFrame.size.width;
		tableviewFrame.origin.x = xOrigin;
		UITableView* tableView = [[UITableView alloc] initWithFrame:tableviewFrame style:UITableViewStyleGrouped];
//		tableView.backgroundColor = [UIColor clearColor];
//		tableView.opaque = NO;
//		tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chalkboard - iPhone.png"]];
		Question* q = self.questions[i];
		q.number = i+1;
		tableView.dataSource = q;
		tableView.delegate = q;
		tableView.contentMode = UIViewContentModeScaleAspectFit;
		[self.scrollView addSubview:tableView];
	}
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width *
											 self.questions.count,
											 self.scrollView.frame.size.height);
	
	self.pageControl.numberOfPages = self.questions.count;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.pagingEnabled = YES;
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


#pragma mark scrollView delegate handlers

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (self.pageControlUsed) {
		return;
	}
	
	CGFloat pageWidth = self.scrollView.frame.size.width;
	int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	self.pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
	int page = self.pageControl.currentPage;
	
	// update the scroll view to the appropriate page
	CGRect frame = self.scrollView.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Set the boolean used when scrolls originate from the UIPageControl.
	self.pageControlUsed = YES;
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//	[headerView setBackgroundColor:[UIColor redColor]];
//	NSLog(@"yup. indeed.");
//	return headerView;
//}




@end
