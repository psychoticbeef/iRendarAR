//
//  RouteSelectionController.m
//  iRendARAR
//
//  Created by Daniel Arndt on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteSelectionController.h"

@interface RouteSelectionController ()

@property (nonatomic, readwrite) NSUInteger filesize;
@property (atomic, readwrite) BOOL routeListDownloaded;

@property (strong, nonatomic) NSArray* routes;
@property (strong, nonatomic) IBOutlet UIView* downloadPopup;
@property (strong, nonatomic) IBOutlet UIProgressView* progressView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* activity;
@property (strong, nonatomic) IBOutlet UITableView* tv;
@property (strong, nonatomic) RouteLoader* routeLoader;
@property (strong, nonatomic) GPSManager* gpsManager;
@property (readwrite) int routeSelected;
@property (strong, nonatomic) CurrentRouteViewController* currentRoute;


@end

@implementation RouteSelectionController

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
    
    RouteSelectionController *__weak weakSelf = self;
    
    self.routeListDownloaded = NO;
    self.routes = NULL;
    self.routeLoader = [[RouteLoader alloc] init];
    self.routeLoader.delegate = self;
    
    self.gpsManager = [GPSManager sharedInstance];
    self.gpsManager.delegate = self;
    
    self.navigationController.delegate = self;
    
    self.currentRoute = [self.storyboard instantiateViewControllerWithIdentifier:@"CurrentRouteViewController"];
    
    self.downloadPopup.alpha = 0.0f;
    self.downloadPopup.layer.cornerRadius = 5;
    
    // get the correct URL to check for reachability. fucking magic.
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath]; 
    NSString* urlSettingsFile = [bundlePath stringByAppendingPathComponent:@"url_settings.plist"];
    NSMutableDictionary* urlSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:urlSettingsFile];
    NSString* base_url = [urlSettings valueForKey:@"base_url"];
    NSURL* url = [NSURL URLWithString:base_url];
    Reachability* reach = [Reachability reachabilityWithHostname:url.host];
    
    reach.reachableBlock = ^(Reachability* reach) {
        if (!weakSelf.routeListDownloaded) {
            [weakSelf.routeLoader loadRoutes];
        }
    };
    
    reach.unreachableBlock = ^(Reachability* reach) {
        DebugLog(@"Network is down");
    };
    
    [reach startNotifier];
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
    return [self.routes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }   
    
    NSString* distance;
    CGFloat fdistance = [[GPSManager sharedInstance] distanceFromCurrentPosititionToRoute:self.routes[indexPath.row]];
    if (fdistance > 1)
        distance = [NSString stringWithFormat:@"%.fkm", fdistance];
    else
        distance = [NSString stringWithFormat:@"%.fm", fdistance*1000];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self.routes[indexPath.row] longname], distance];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.activity.isAnimating) {
        return;
    }
    
    self.downloadPopup.alpha = 0.8;
    [self fetchZIPfile:self.routes[indexPath.row]];
    [self.activity startAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Tour wählen";
}

- (void)locationDidChange {
    if (self.routes) {
        [self.tv reloadData];
        DebugLog(@"The GPS receiver informed us about a new location. Also, Routes are already loaded.");
    } else {
        DebugLog(@"The GPS receiver informed us about a new location. The route list was not yet loaded.");
    }
}

- (void)routeLoaderDidFinishLoading:(NSArray* )routeList {
    self.routeListDownloaded = YES;
    self.routes = routeList;
    [self.tv reloadData];
}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//}

- (IBAction)cancelDownload:(id)sender {
    // TODO:
    // [connection cancel]
    //    [self downloadFinished];
    DebugLog(@"trying to cancel. NYI");
}


- (void)downloadFinished:(Route*)route {
    
    [self.activity stopAnimating];
    self.downloadPopup.alpha = 0.0;
    if (self.filesize == -1) {
        NSLog(@"Downloaded -1 Bytes, which means there was an error concerning the NSURLConnection downloading route content.");
    }
    
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
    
    // deprecated
    //            NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:[cachePath stringByAppendingPathComponent:[downloader._route filename]] traverseLink:YES];
    
    NSError* error = NULL;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[cachePath stringByAppendingPathComponent:[route filename]] error:&error];
    
    NSString* filepath = [cachePath stringByAppendingPathComponent:[route filename]];
    
    if (self.filesize == [fileAttributes[@"NSFileSize"] intValue]) {
    } else {
        NSLog(@"File size of route on system: %d Expected: %@", self.filesize, fileAttributes[@"NSFileSize"]);
        return;
    }
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    [zipArchive UnzipOpenFile:filepath Password:@""];
    [zipArchive UnzipFileTo:[cachePath stringByAppendingPathComponent:@"/route/"] overWrite:YES];
    [zipArchive UnzipCloseFile];
    
    self.filesize = 0;
    
    [self.navigationController pushViewController:self.currentRoute animated:YES];
}


- (void)fetchZIPfile:(Route*)route {
    
    RouteSelectionController *__weak weakSelf = self;
    
    [self.progressView setProgress:0.0];
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
    
    NSError* filePathCreationError = nil;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&filePathCreationError];
    if (filePathCreationError) {
        NSLog(@"Download file path is invalid: %@", cachePath);
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:route.zipfile];
    
    self.progressView.progress = 0.0;
    
    [URLConnection asyncConnectionWithRequest:request
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
