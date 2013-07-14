//
//  SHSecondViewController.m
//  Example
//
//  Created by Seivan Heidari on 5/28/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHSecondViewController.h"
#import "UIWebView+SHWebViewBlocks.h"

@interface SHSecondViewController ()
@property(nonatomic,strong) IBOutlet UIWebView * viewWeb;
-(void)testPropertiesAreNil;
-(void)setPropertiesToNil;
-(void)testPropertiesArePresent;
@end

@implementation SHSecondViewController

-(void)viewDidLoad; {
  [super viewDidLoad];
  
}

-(void)viewDidAppear:(BOOL)animated; {
  [super viewDidAppear:animated];
  
  dispatch_semaphore_t semaphoreShouldStartLoadWithRequest = dispatch_semaphore_create(0);
  dispatch_semaphore_t semaphoreDidStartLoad               = dispatch_semaphore_create(0);
  dispatch_semaphore_t semaphoreDidFinishLoad              = dispatch_semaphore_create(0);
  dispatch_semaphore_t semaphoreidFailLoadWithError        = dispatch_semaphore_create(0);
  
  [self.viewWeb SH_loadRequestWithString:@"http://google.se"];
  __block BOOL testShouldStartLoadWithRequest = NO;
  __block BOOL testDidStartLoad               = NO;
  __block BOOL testDidFinishLoad              = NO;
  __block BOOL testDidFailLoadWithError       = NO;
  
  [self testPropertiesAreNil];
  [self.viewWeb SH_setShouldStartLoadWithRequestBlock:^(UIWebView *theWebView, NSURLRequest *theRequest, UIWebViewNavigationType theNavigationType) {
    SHBlockAssert(theRequest, @"Must pass theRequest");
    SHBlockAssert(theWebView, @"Must pass theWebView");
    testShouldStartLoadWithRequest = YES;
    dispatch_semaphore_signal(semaphoreShouldStartLoadWithRequest);
    return YES;
  }];
  
  
  [self.viewWeb SH_setDidStartLoadBlock:^(UIWebView *theWebView) {
    SHBlockAssert(theWebView, @"Must pass theWebView");
    testDidStartLoad = YES;
    dispatch_semaphore_signal(semaphoreDidStartLoad);
  }];
  
  
  [self.viewWeb SH_setDidFinishLoadBlock:^(UIWebView *theWebView) {
    SHBlockAssert(theWebView, @"Must pass theWebView");
    testDidFinishLoad = YES;
    [theWebView SH_loadRequestWithString:@"This Should Probably error out"];
    dispatch_semaphore_signal(semaphoreDidFinishLoad);
    
  }];
  
  
  [self.viewWeb SH_setDidFailLoadWithErrorBlock:^(UIWebView *theWebView, NSError *theError) {
    SHBlockAssert(theWebView, @"Must pass theWebView");
    testDidFailLoadWithError = YES;
    dispatch_semaphore_signal(semaphoreidFailLoadWithError);
  }];
  [self testPropertiesArePresent];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    dispatch_semaphore_wait(semaphoreShouldStartLoadWithRequest, DISPATCH_TIME_FOREVER);
    SHBlockAssert(testShouldStartLoadWithRequest, @"testShouldStartLoadWithRequest must be true");
    
    dispatch_semaphore_wait(semaphoreDidStartLoad, DISPATCH_TIME_FOREVER);
    SHBlockAssert(testDidStartLoad, @"testDidStartLoad must be true");
    
    dispatch_semaphore_wait(semaphoreDidFinishLoad, DISPATCH_TIME_FOREVER);
    SHBlockAssert(testDidFinishLoad, @"testDidFinishLoad must be true");
    
    dispatch_semaphore_wait(semaphoreidFailLoadWithError, DISPATCH_TIME_FOREVER);
    SHBlockAssert(testDidFailLoadWithError, @"testDidFailLoadWithError must be true");
    
  });
//  [self setPropertiesToNil];
//  [self testPropertiesAreNil];
  
}

-(void)testPropertiesAreNil; {
  SHBlockAssert(self.viewWeb.SH_blockShouldStartLoadingWithRequest == nil,
                @"SH_blockShouldStartLoadingWithRequest is nil");
  SHBlockAssert(self.viewWeb.SH_blockDidStartLoad == nil,
                @"SH_blockDidStartLoad is nil");
  SHBlockAssert(self.viewWeb.SH_blockDidFinishLoad == nil,
                @"SH_blockDidFinishLoad is nil");
  SHBlockAssert(self.viewWeb.SH_blockDidFailLoadWithError == nil,
                @"SH_blockDidFailLoadWithError is nil");
  
}

-(void)setPropertiesToNil; {
  [self.viewWeb SH_setShouldStartLoadWithRequestBlock:nil];
  [self.viewWeb SH_setDidStartLoadBlock:nil];
  [self.viewWeb SH_setDidFinishLoadBlock:nil];
  [self.viewWeb SH_setDidFailLoadWithErrorBlock:nil];
}

-(void)testPropertiesArePresent; {
  SHBlockAssert(self.viewWeb.SH_blockShouldStartLoadingWithRequest,
                @"SH_blockShouldStartLoadingWithRequest is set");
  SHBlockAssert(self.viewWeb.SH_blockDidStartLoad,
                @"SH_blockDidStartLoad is set");
  SHBlockAssert(self.viewWeb.SH_blockDidFinishLoad,
                @"SH_blockDidFinishLoad is set");
  SHBlockAssert(self.viewWeb.SH_blockDidFailLoadWithError,
                @"SH_blockDidFailLoadWithError is set");
  
}

@end
