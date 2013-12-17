//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Seivan Heidari on 8/2/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHWebViewBlocks.h"



@interface SHWebViewBlocksTests : XCTestCase
@property(nonatomic,strong) UIWebView * viewWeb;
@end

#import "SHTestCaseAdditions.h"

@implementation SHWebViewBlocksTests

-(void)setUp; {
  [super setUp];
  self.viewWeb = [[UIWebView alloc] init];
}

-(void)tearDown; {
  [super tearDown];
  self.viewWeb = nil;
}

-(void)testPropertiesAreNil; {
  XCTAssertTrue(self.viewWeb.SH_blockShouldStartLoadingWithRequest == nil,
               @"SH_blockShouldStartLoadingWithRequest is nil");
  XCTAssertTrue(self.viewWeb.SH_blockDidStartLoad == nil,
               @"SH_blockDidStartLoad is nil");
  XCTAssertTrue(self.viewWeb.SH_blockDidFinishLoad == nil,
               @"SH_blockDidFinishLoad is nil");
  XCTAssertTrue(self.viewWeb.SH_blockDidFailLoadWithError == nil,
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
    XCTAssertNotNil(theRequest, @"Must pass theRequest");
    XCTAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    testShouldStartLoadWithRequest = YES;
    dispatch_semaphore_signal(semaphoreShouldStartLoadWithRequest);
    return YES;
  }];
  
  
  [self.viewWeb SH_setDidStartLoadBlock:^(UIWebView *theWebView) {
    XCTAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    testDidStartLoad = YES;
    dispatch_semaphore_signal(semaphoreDidStartLoad);
  }];
  
  
  [self.viewWeb SH_setDidFinishLoadBlock:^(UIWebView *theWebView) {
    XCTAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    testDidFinishLoad = YES;
    [theWebView SH_loadRequestWithString:@"This Should Probably error out"];
    dispatch_semaphore_signal(semaphoreDidFinishLoad);
    
  }];
  
  
  [self.viewWeb SH_setDidFailLoadWithErrorBlock:^(UIWebView *theWebView, NSError *theError) {
    XCTAssertEqualObjects(theWebView, self.viewWeb, @"Must pass theWebView");
    XCTAssertNotNil(theError);
    testDidFailLoadWithError = YES;
    dispatch_semaphore_signal(semaphoreidFailLoadWithError);
  }];
  
  XCTAssertNotNil(self.viewWeb.SH_blockShouldStartLoadingWithRequest,
                 @"SH_blockShouldStartLoadingWithRequest is set");
  XCTAssertNotNil(self.viewWeb.SH_blockDidStartLoad,
                 @"SH_blockDidStartLoad is set");
  XCTAssertNotNil(self.viewWeb.SH_blockDidFinishLoad,
                 @"SH_blockDidFinishLoad is set");
  XCTAssertNotNil(self.viewWeb.SH_blockDidFailLoadWithError,
                 @"SH_blockDidFailLoadWithError is set");

  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    dispatch_semaphore_wait(semaphoreShouldStartLoadWithRequest, DISPATCH_TIME_FOREVER);
    XCTAssertTrue(testShouldStartLoadWithRequest, @"testShouldStartLoadWithRequest must be true");
    
    dispatch_semaphore_wait(semaphoreDidStartLoad, DISPATCH_TIME_FOREVER);
    XCTAssertTrue(testDidStartLoad, @"testDidStartLoad must be true");
    
    dispatch_semaphore_wait(semaphoreDidFinishLoad, DISPATCH_TIME_FOREVER);
    XCTAssertTrue(testDidFinishLoad, @"testDidFinishLoad must be true");
    
    dispatch_semaphore_wait(semaphoreidFailLoadWithError, DISPATCH_TIME_FOREVER);
    XCTAssertTrue(testDidFailLoadWithError, @"testDidFailLoadWithError must be true");
    
  });
  
}

-(void)testSH_loadRequestWithString; {
  XCTAssertFalse(self.viewWeb.isLoading);
  NSString * link = @"www.google.se";
  [self.viewWeb SH_loadRequestWithString:link];
  [self SH_runLoopUntilTestPassesWithBlock:^BOOL{
    return self.viewWeb.isLoading;
  } withTimeOut:5];
  XCTAssertTrue(self.viewWeb.isLoading);
}

-(void)testSH_setShouldStartLoadWithRequestBlock; {
  SHWebViewBlockWithRequest block = ^BOOL(UIWebView *theWebView, NSURLRequest *theRequest, UIWebViewNavigationType theNavigationType) {
    return YES;
  };
  
  [self.viewWeb SH_setShouldStartLoadWithRequestBlock:block];
  
  XCTAssertEqualObjects(block, self.viewWeb.SH_blockShouldStartLoadingWithRequest);
}

-(void)testSH_setDidStartLoadBlock; {
  SHWebViewBlock block = ^(UIWebView *theWebView) {
    
  };
  
  [self.viewWeb SH_setDidStartLoadBlock:block];
  
  XCTAssertEqualObjects(block, self.viewWeb.SH_blockDidStartLoad);
}

-(void)testSH_setDidFinishLoadBlock; {
  SHWebViewBlock block = ^(UIWebView *theWebView) {
    
  };
  
  [self.viewWeb SH_setDidFinishLoadBlock:block];
  
  XCTAssertEqualObjects(block, self.viewWeb.SH_blockDidFinishLoad);
}

-(void)testSH_setDidFailLoadWithErrorBlock; {
  SHWebViewBlockWithError block = ^(UIWebView *theWebView, NSError *theError) {
    
  };
  
  [self.viewWeb SH_setDidFailLoadWithErrorBlock:block];
  
  XCTAssertEqualObjects(block, self.viewWeb.SH_blockDidFailLoadWithError);
}



@end
