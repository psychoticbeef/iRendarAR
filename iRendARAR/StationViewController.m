//
//  StationViewController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationViewController.h"

@interface StationViewController ()

@property (strong, nonatomic) NSMutableArray* images;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSMutableArray* multipleChoice;

@property (weak, nonatomic) IBOutlet UIPageControl* pageControl;
@property (weak, nonatomic) IBOutlet UITextView* textView;

@property (strong, nonatomic) MultipleChoiceViewController* multipleChoiceViewController;

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property (readwrite) BOOL hasDescription;
@property (readwrite) BOOL hasMultipleImages;
@property (readwrite) BOOL hasSingleImage;
@property (readwrite) BOOL hasMultipleChoice;
@property (readwrite) NSInteger currentImageIndex;

@property (readwrite, atomic) BOOL pageControlUsed;

@end

@implementation StationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	
	// set up scroll view
	
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	
	self.pageControlUsed = NO;
	
	self.currentImageIndex = 0;
	
	self.images = [[NSMutableArray alloc] init];
//	[self.images addObject:[UIImage imageNamed:@"a.png"]];
//	[self.images addObject:[UIImage imageNamed:@"b.png"]];
//	[self.images addObject:[UIImage imageNamed:@"c.png"]];
	
	int i = 0;
	CGRect scrollViewFrame = self.scrollView.frame;
	CGRect imageFrame = self.scrollView.frame;
	imageFrame.origin.y = 0;
	
	// no for loop over "i", because this uses fast enumeration.
	for (UIImage* image in self.images) {
		CGFloat xOrigin = i++ * scrollViewFrame.size.width;
		
		UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageFrame.origin.x = xOrigin;
		imageView.frame = imageFrame;
		[self.scrollView addSubview:imageView];
	}
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width *
											 self.images.count,
											 self.scrollView.frame.size.height);
	
	self.text = @"lorem ipsum";
	
	self.pageControl.numberOfPages = self.images.count;
	self.pageControl.currentPage = self.currentImageIndex;
	
	self.hasDescription = (self.text && self.text.length > 0);
	self.hasSingleImage = (self.images.count == 1);
	self.hasMultipleImages = (self.images.count > 1);
	self.hasMultipleChoice = self.node.questions != NULL && self.node.questions.count > 0;
	
	CGRect textViewRect = self.textView.frame;
	CGRect scrollViewRect = self.scrollView.frame;
	
	// do resizing magic. some elements only need to be shown conditionally.
	if (self.hasDescription && self.hasMultipleImages) {
		// do nothing. yeahhh.
	}
	
	if (self.hasDescription && self.hasSingleImage) {
		self.pageControl.hidden = YES;
		scrollViewRect.size.height += 24;
	}
	
	if (self.hasDescription && !self.hasMultipleImages && !self.hasSingleImage) {
		self.pageControl.hidden = YES;
		self.scrollView.hidden = YES;
		textViewRect.size.height += 173;
	}
	
	if (!self.hasDescription && self.hasMultipleImages) {
		self.textView.hidden = YES;
		scrollViewRect.origin.y -= 162;
		scrollViewRect.size.height += 162;
	}
	
	if (!self.hasDescription && self.hasSingleImage) {
		self.textView.hidden = YES;
		self.pageControl.hidden = YES;
		scrollViewRect.origin.y -= 162;
		scrollViewRect.size.height += 162;
		scrollViewRect.size.height += 24;
	}
	
	if (!self.hasDescription && !self.hasMultipleImages && !self.hasSingleImage) {
		// TODO: go immediately to multiple choice view
		[self multipleChoiceAction:self];
		return;
	}
	
	self.textView.frame = textViewRect;
	self.scrollView.frame = scrollViewRect;
	
	if (self.hasMultipleChoice) {
		UIBarButtonItem *multipleChoice = [[UIBarButtonItem alloc] initWithTitle:@"Rätseln" style:UIBarButtonItemStylePlain target:self action:@selector(multipleChoiceAction:)];
		self.navigationItem.rightBarButtonItem = multipleChoice;
	}
}

-(IBAction)multipleChoiceAction:(id)sender {
	self.multipleChoiceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"multipleChoice"];
	self.multipleChoiceViewController.questions = self.node.questions;
	[self.navigationController pushViewController:self.multipleChoiceViewController animated:YES];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

@end
