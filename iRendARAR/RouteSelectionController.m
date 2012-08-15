//
//  RouteSelectionController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteSelectionController.h"
#import "SSZipArchive.h"

@interface RouteSelectionController ()

@property (nonatomic, readwrite) NSUInteger filesize;
@property (readwrite) BOOL routeListDownloaded;

@property (weak, nonatomic) IBOutlet UIView* downloadPopup;
@property (weak, nonatomic) IBOutlet UIProgressView* progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activity;
@property (weak, nonatomic) IBOutlet UITableView* tv;
@property (strong, nonatomic) RouteLoader* routeLoader;
@property (strong, nonatomic) GPSManager* gpsManager;
@property (nonatomic, weak) URLConnection* connection;
@property (nonatomic, retain) Reachability* reach;

@property (nonatomic) BOOL tabbarIsHidden;

@end

@implementation RouteSelectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
	}
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


- (void)hideTabbar {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	for(UIView *view in self.tabBarController.view.subviews)
	{
		CGRect _rect = view.frame;
		NSLog(@"%f %f %f %f", _rect.origin.x, _rect.origin.y, _rect.size.width, _rect.size.height);
		if([view isKindOfClass:[UITabBar class]])
		{
			if (self.tabbarIsHidden) {
				_rect.origin.y = 431;
			} else {
				_rect.origin.y = 480;
			}
			view.frame = _rect;
		} else {
			if (self.tabbarIsHidden) {
				_rect.size.height = 431;
			} else {
				_rect.size.height = 480;
			}
			view.frame = _rect;
		}
	}
	[UIView commitAnimations];
	
	self.tabbarIsHidden = !self.tabbarIsHidden;
}

- (void)viewWillAppear:(BOOL)animated {
//	self.tabBarBackup = [self.tabBarController.viewControllers copy];
//	NSMutableArray* hiddenTabBar = [self.tabBarController.viewControllers mutableCopy];
//	[hiddenTabBar removeObjectAtIndex:1];
//	[self.tabBarController setViewControllers:hiddenTabBar animated:YES];
	[self hideTabbar];
}

- (void)viewWillDisappear:(BOOL)animated {
//	[self.tabBarController setViewControllers:self.tabBarBackup animated:YES];
	[self hideTabbar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    RouteSelectionController *__weak weakSelf = self;
	
    
    self.routeListDownloaded = NO;
    self.routeLoader = [[RouteLoader alloc] init];
    self.routeLoader.delegate = self;
    
    self.gpsManager = [GPSManager sharedInstance];
    self.gpsManager.delegate = self;
    
    self.navigationController.delegate = self;
    
    self.downloadPopup.alpha = 0.0f;
    self.downloadPopup.layer.cornerRadius = 5;
    
    // get the correct URL to check for reachability. fucking magic.
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* urlSettingsFile = [bundlePath stringByAppendingPathComponent:@"url_settings.plist"];
    NSMutableDictionary* urlSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:urlSettingsFile];
    NSString* base_url = [urlSettings valueForKey:@"base_url"];
    NSURL* url = [NSURL URLWithString:base_url];
    self.reach = [Reachability reachabilityWithHostname:url.host];
    
    self.reach.reachableBlock = ^(Reachability* reach) {
        if (!weakSelf.routeListDownloaded) {
            [weakSelf.routeLoader loadRoutes];
        }
    };
    
    self.reach.unreachableBlock = ^(Reachability* reach) {
        DebugLog(@"Network is down");
    };
    
    [self.reach startNotifier];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark tableview shit

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeLoader.routes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	Route* r = self.routeLoader.routes[(NSUInteger) indexPath.row];
	NSString* distance;
	if (r.distance > 1000) {
		distance = [NSString stringWithFormat:@"%.fkm", r.distance/1000];
	} else {
		distance = [NSString stringWithFormat:@"%.fm", r.distance];
	}
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", r.longname, distance];
    
    return cell;
}

- (void)locationDidChange {
	[self.routeLoader locationDidChange];
	[self.tv reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Tour wählen";
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.activity.isAnimating) {
        return;
    }
    
//	[UIView animateWithDuration:0.25 animations:^(void) {
		self.downloadPopup.alpha = 0.8;
//	}];
    [self fetchZIPfile:self.routeLoader.routes[(NSUInteger) indexPath.row]];
    [self.activity startAnimating];
}

- (void)routeLoaderDidFinishLoading {
    self.routeListDownloaded = YES;
	[self.reach stopNotifier];
	[self locationDidChange];
}

- (void)routeLoaderDidFinishWithError {
    self.routeListDownloaded = NO;
}

- (IBAction)cancelDownload:(id)sender {
    // TODO:
    [self.connection abort];
    [self downloadFinished:nil];
//    DebugLog(@"trying to cancel. NYI");
}


- (void)downloadFinished:(Route*)route {
    
    [self.activity stopAnimating];
	if (route == nil) {
		[UIView animateWithDuration:1.0 animations:^(void) {
			self.downloadPopup.alpha = 0.0;
		}];
	}
	else {
		self.downloadPopup.alpha = 0.0;
	}
    if (self.filesize == -1 || route == nil) {
        NSLog(@"Downloaded -1 Bytes, which means there was an error concerning"
			  @"the NSURLConnection downloading route content.");
    }
	
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
    
    NSError* error = NULL;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:
									[cachePath stringByAppendingPathComponent:[route filename]]
																					error:&error];
    
    NSString* filepath = [cachePath stringByAppendingPathComponent:[route filename]];
    
    if (self.filesize == [fileAttributes[@"NSFileSize"] intValue]) {
    } else {
        NSLog(@"File size of route on system: %d Expected: %@", self.filesize, fileAttributes[@"NSFileSize"]);
        return;
    }
    
	[SSZipArchive unzipFileAtPath:filepath toDestination:[cachePath stringByAppendingPathComponent:@"/route/"]];
    
    self.filesize = 0;

	CurrentRouteViewController* currentRoute = [self.storyboard instantiateViewControllerWithIdentifier:@"CurrentRouteViewController"];
    [self.navigationController pushViewController:currentRoute animated:YES];
}


- (void)fetchZIPfile:(Route*)route {
    
    RouteSelectionController *__weak weakSelf = self;
    
    [self.progressView setProgress:0.0];
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
    
    NSError* filePathCreationError = nil;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath
							  withIntermediateDirectories:YES attributes:nil
													error:&filePathCreationError];
    if (filePathCreationError) {
        NSLog(@"Download file path is invalid: %@", cachePath);
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:route.zipfile];
    
    self.progressView.progress = 0.0;
    
    self.connection = [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response) {
                                  [data writeToFile:[cachePath stringByAppendingPathComponent:route.filename] atomically:YES];
                                  weakSelf.filesize = [data length];
                                  [weakSelf downloadFinished:route];
                              } errorBlock:^(NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      UIAlertView* downloadedErrorView = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Notwendige Dateien konnten nicht heruntergeladen werden. Bitte versuchen Sie es später erneut." delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"Alles klar!", nil];
                                      [downloadedErrorView show];
                                      
                                      weakSelf.filesize = -1;
                                  });
                              } uploadPorgressBlock:^(float progress) {
                              } downloadProgressBlock:^(float progress) {
                                  self.progressView.progress = progress;
                              }];
    
    
}


@end
