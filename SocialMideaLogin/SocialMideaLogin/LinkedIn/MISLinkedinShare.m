//
//  ShareLinkedinHelper.m
//  OAuthStarterKit
//
//  Created by Pedro Milanez on 27/09/12.
//  Copyright (c) 2012 self. All rights reserved.
//


// Last Changes done from https://developer.linkedin.com/support/developer-program-transition

#import "MISLinkedinShare.h"
#import "OAMutableURLRequest.h"



@implementation MISLinkedinShare
@synthesize oAuthLoginView = _oAuthLoginView;
@synthesize postTitle = _postTitle;
@synthesize postDescription = _postDescription;
@synthesize postURL = _postURL;
@synthesize postImageURL = _postImageURL;
@synthesize delegate = _delegate;


+ (MISLinkedinShare *)sharedInstance
{
    static dispatch_once_t once;
    static MISLinkedinShare *instance;
    dispatch_once(&once, ^ { instance = [[MISLinkedinShare alloc] init]; });
    return instance;
}


# pragma mark - Public Methods
- (void) setDelegate:(id)delegate {
	_delegate = delegate;
}

- (void) shareContent:(UIViewController *)viewController postTitle:(NSString*)aPostTitle postDescription:(NSString*)aPostDescription postURL:(NSString*)aPostURL postImageURL:(NSString*)aPostImageURL {
	
	_postTitle = aPostTitle;
	_postDescription = aPostDescription;
	_postURL = aPostURL;
	_postImageURL = aPostImageURL;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aPostDescription forKey:@"SharingText"];
	
	_oAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil apiKey:kLinkedinApiKey secretKey:kLinkedinSecretKey];
	
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:_oAuthLoginView];
    
    [viewController presentViewController:_oAuthLoginView animated:YES completion:^{}];
}


-(void)loginIntoLinkedIn :(UIViewController *)viewController
{
    
    _oAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil apiKey:kLinkedinApiKey secretKey:kLinkedinSecretKey];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:_oAuthLoginView];
    
    [viewController presentViewController:_oAuthLoginView animated:YES completion:^{}];
}

#pragma mark - Private Methods


-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	// Login failed
	if (![_oAuthLoginView.accessToken isValid]) {
		return;
	}
	
    [self getUserDetail];
}

-(void)getUserDetail
{
    NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/v1/people/~:(id,num-connections,picture-url,first-name,last-name)?format=json"];
    
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:_oAuthLoginView.consumer
                                       token:_oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(profileApiCallResult:didFinish:)
                  didFailSelector:@selector(profileCancel:didFail:)];
}

-(void)profileApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *json = [responseBody objectFromJSONString];
    
    if ([self.linkedInDelegate respondsToSelector:@selector(didFinishLinkedInLogin:)]) {
        [self.linkedInDelegate didFinishLinkedInLogin:json];
    }
    
}
- (void)profileCancel:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

#pragma mark - OADataFetcher return Methods
- (void) shareContentWithData
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:_oAuthLoginView.consumer
                                       token:_oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    

    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[NSDictionary alloc]
                             initWithObjectsAndKeys:
                             @"anyone",@"code",nil], @"visibility",
                           [[NSUserDefaults standardUserDefaults] valueForKey:@"SharingText"], @"comment", nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    format=json
    NSString *updateString = [update JSONString];
    
    [request setHTTPBodyWithString:updateString];
	[request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(postUpdateApiCallResult:didFinish:)
                  didFailSelector:@selector(postUpdateApiCallResult:didFail:)];
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    // The next thing we want to do is call the network updates
    NSLog(@"Sucess! %@",[data description]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:@"Shared Successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

@end
