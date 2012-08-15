//
//  MultipleChoiceViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultipleChoiceViewController.h"

@interface MultipleChoiceViewController ()

@property (weak) IBOutlet UIPageControl* pageControl;
@property (weak) IBOutlet UIScrollView *scrollView;
@property (weak) IBOutlet UIView* answerView;
@property (weak) IBOutlet UILabel* answerViewSymbol;
@property (weak) IBOutlet UILabel* answerViewPoints;
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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// shadow!!1
	self.answerView.layer.masksToBounds = NO;
	self.answerView.layer.cornerRadius = 8;
	self.answerView.layer.shadowOffset = CGSizeMake(-15, 20);
	self.answerView.layer.shadowRadius = 5;
	self.answerView.layer.shadowOpacity = 0.5;

	CGRect scrollViewFrame = self.scrollView.frame;
	CGRect tableViewFrame = self.scrollView.frame;
	tableViewFrame.origin.y = 0;

	for (unsigned int i = 0; i < self.questions.count; i++) {
		CGFloat xOrigin = i * scrollViewFrame.size.width;
		tableViewFrame.origin.x = xOrigin;
		UITableView* tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
//		tableView.backgroundColor = [UIColor clearColor];
//		tableView.opaque = NO;
//		tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chalkboard - iPhone.png"]];
		Question* q = self.questions[i];
		q.number = i+1;
		q.delegate = self;
		q.tableView = tableView;
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

- (void)questionAnswered:(BOOL)correctly forPoints:(NSInteger)points sender:(Question*)sender {
	self.answerViewPoints.text = [NSString stringWithFormat:@"%i Punkte", points];

	if (correctly) {
		self.answerViewSymbol.text = @"✓";
		self.answerViewSymbol.textColor = [UIColor greenColor];
		self.answerViewPoints.textColor = [UIColor greenColor];
	} else {
		self.answerViewSymbol.text = @"✗";
		self.answerViewSymbol.textColor = [UIColor redColor];
		self.answerViewPoints.textColor = [UIColor redColor];
	}
	
	CGRect centerFrame = self.answerView.frame;
	CGRect outsideViewFrame = centerFrame;

	outsideViewFrame.origin.y = -(centerFrame.size.height);
	self.answerView.frame = outsideViewFrame;
	self.answerView.alpha = 0.8;
	
	[UIView animateWithDuration:0.75 animations:^(void) {
		self.answerView.frame = centerFrame;
	} completion:^(BOOL finished) {
		
		[UIView animateWithDuration:1.5 animations:^(void) {
			self.answerView.alpha = 1.0;
		} completion:^(BOOL finished) {
			
			[UIView animateWithDuration:0.75 animations:^(void) {
				self.answerView.alpha = 0.0;
				self.answerView.frame = outsideViewFrame;
			} completion:^(BOOL finished) {
				self.answerView.frame = centerFrame;
				
				int index = [self.questions indexOfObject:sender];
				int newIndex = -1;
				
				for (int i = index; i < self.questions.count; i++) {
					Question* q = self.questions[i];
					if (!(q.answersExhausted || q.correctlyAnswered)) {
						newIndex = i;
						break;
					}
				}
				
				if (newIndex == -1) {
					for (int i = index; i >= 0; i--) {
						Question* q = self.questions[i];
						if (!(q.answersExhausted || q.correctlyAnswered)) {
							newIndex = i;
							break;
						}
					}
				}
				
				if (newIndex != -1) {
					self.pageControl.currentPage = newIndex;
					[self changePage:nil];
				} else {
					[self.delegate answeredQuestions];
					[self.navigationController popViewControllerAnimated:YES];
				}
				

			}];
		}];
	}];
	
	
	sender.tableView.userInteractionEnabled = YES;
}

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}

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
	int page = (int)floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
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
