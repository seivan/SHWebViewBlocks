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

-(void)testSH_loadRequestWithString; {
  STAssertNil(self.viewWeb.request, nil);
  NSString * link = @"www.google.se";
  [self.viewWeb SH_loadRequestWithString:link];
  [self SH_performAsyncTestsWithinBlock:^(BOOL *didFinish) {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      STAssertNotNil(self.viewWeb.request, nil);
      STAssertEqualObjects(self.viewWeb.request, [NSURLRequest requestWithURL:[NSURL URLWithString:link]], nil);

    });
  } withTimeout:5];

}

//#pragma mark - Helpers
//-(void)SH_loadRequestWithString:(NSString *)theString; {
//  NSAssert(theString, @"Must pass theString");
//  [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:theString]]];
//}
//
//
//
//#pragma mark - Properties
//
//
//#pragma mark - Setters
//
//-(void)SH_setShouldStartLoadWithRequestBlock:(SHWebViewBlockWithRequest)theBlock; {
//  [SHWebViewBlockManager setBlock:theBlock forWebView:self withKey:SH_blockShouldStartLoadingWithRequest];
//}
//
//-(void)SH_setDidStartLoadBlock:(SHWebViewBlock)theBlock; {
//  [SHWebViewBlockManager setBlock:theBlock forWebView:self withKey:SH_blockDidStartLoad];
//  
//}
//
//-(void)SH_setDidFinishLoadBlock:(SHWebViewBlock)theBlock; {
//  [SHWebViewBlockManager setBlock:theBlock forWebView:self withKey:SH_blockDidFinishLoad];
//  
//}
//
//-(void)SH_setDidFailLoadWithErrorBlock:(SHWebViewBlockWithError)theBlock; {
//  [SHWebViewBlockManager setBlock:theBlock forWebView:self withKey:SH_blockDidFailLoadWithError];
//  
//}
//
//
//
//
//#pragma mark - Getters
//
//-(SHWebViewBlockWithRequest)SH_blockShouldStartLoadingWithRequest; {
//  return [SHWebViewBlockManager blockForWebView:self withKey:SH_blockShouldStartLoadingWithRequest];
//}
//
//-(SHWebViewBlock)SH_blockDidStartLoad; {
//  return [SHWebViewBlockManager blockForWebView:self withKey:SH_blockDidStartLoad];
//}
//
//-(SHWebViewBlock)SH_blockDidFinishLoad; {
//  return [SHWebViewBlockManager blockForWebView:self withKey:SH_blockDidFinishLoad];
//}
//
//-(SHWebViewBlockWithError)SH_blockDidFailLoadWithError; {
//  return [SHWebViewBlockManager blockForWebView:self withKey:SH_blockDidFailLoadWithError];
//}



@end
