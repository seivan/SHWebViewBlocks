//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Seivan Heidari on 8/2/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SHWebViewBlocks.h"
@interface SHWebViewBlocksTests : SenTestCase
@property(nonatomic,strong) UIWebView * viewWeb;
@end



@implementation SHWebViewBlocksTests

-(void)setUp; {
  [super setUp];
  self.viewWeb = [[UIWebView alloc] init];
}

-(void)tearDown; {
  [super tearDown];
}

-(void)testPropertiesAreNil; {
  STAssertTrue(self.viewWeb.SH_blockShouldStartLoadingWithRequest == nil,
               @"SH_blockShouldStartLoadingWithRequest is nil");
  STAssertTrue(self.viewWeb.SH_blockDidStartLoad == nil,
               @"SH_blockDidStartLoad is nil");
  STAssertTrue(self.viewWeb.SH_blockDidFinishLoad == nil,
               @"SH_blockDidFinishLoad is nil");
  STAssertTrue(self.viewWeb.SH_blockDidFailLoadWithError == nil,
               @"SH_blockDidFailLoadWithError is nil");
  
}



-(void)testBlockCallbacks; {
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
    STAssertNotNil(theRequest, @"Must pass theRequest");
    STAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    testShouldStartLoadWithRequest = YES;
    dispatch_semaphore_signal(semaphoreShouldStartLoadWithRequest);
    return YES;
  }];
  
  
  [self.viewWeb SH_setDidStartLoadBlock:^(UIWebView *theWebView) {
    STAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    testDidStartLoad = YES;
    dispatch_semaphore_signal(semaphoreDidStartLoad);
  }];
  
  
  [self.viewWeb SH_setDidFinishLoadBlock:^(UIWebView *theWebView) {
    STAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    testDidFinishLoad = YES;
    [theWebView SH_loadRequestWithString:@"This Should Probably error out"];
    dispatch_semaphore_signal(semaphoreDidFinishLoad);
    
  }];
  
  
  [self.viewWeb SH_setDidFailLoadWithErrorBlock:^(UIWebView *theWebView, NSError *theError) {
    STAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    STAssertNotNil(theError, nil);
    testDidFailLoadWithError = YES;
    dispatch_semaphore_signal(semaphoreidFailLoadWithError);
  }];
  
  STAssertNotNil(self.viewWeb.SH_blockShouldStartLoadingWithRequest,
                 @"SH_blockShouldStartLoadingWithRequest is set");
  STAssertNotNil(self.viewWeb.SH_blockDidStartLoad,
                 @"SH_blockDidStartLoad is set");
  STAssertNotNil(self.viewWeb.SH_blockDidFinishLoad,
                 @"SH_blockDidFinishLoad is set");
  STAssertNotNil(self.viewWeb.SH_blockDidFailLoadWithError,
                 @"SH_blockDidFailLoadWithError is set");

  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    dispatch_semaphore_wait(semaphoreShouldStartLoadWithRequest, DISPATCH_TIME_FOREVER);
    STAssertTrue(testShouldStartLoadWithRequest, @"testShouldStartLoadWithRequest must be true");
    
    dispatch_semaphore_wait(semaphoreDidStartLoad, DISPATCH_TIME_FOREVER);
    STAssertTrue(testDidStartLoad, @"testDidStartLoad must be true");
    
    dispatch_semaphore_wait(semaphoreDidFinishLoad, DISPATCH_TIME_FOREVER);
    STAssertTrue(testDidFinishLoad, @"testDidFinishLoad must be true");
    
    dispatch_semaphore_wait(semaphoreidFailLoadWithError, DISPATCH_TIME_FOREVER);
    STAssertTrue(testDidFailLoadWithError, @"testDidFailLoadWithError must be true");
    
  });
  
}


@end
