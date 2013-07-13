
#import "UIWebView+SHWebViewBlocks.h"

static NSString * const SH_blockWillShowViewController = @"SH_blockWillShowViewController";
static NSString * const SH_blockDidShowViewController = @"SH_blockDidShowViewController";

@protocol SHWebViewDelegate <NSObject>
@required
+(void)setDelegateForWebView:(UIWebView *)theWebView;
@end


@interface SHWebViewBlockManager : NSObject
<UIWebViewDelegate>

@property(nonatomic,strong)   NSMapTable   * mapBlocks;
+(instancetype)sharedManager;
-(void)SH_memoryDebugger;

#pragma mark -
#pragma mark Class selectors

#pragma mark -
#pragma mark Setter
+(void)setDelegateForWebView:(UIWebView *)theWebView;

+(void)setBlock:(id)theBlock
  forWebView:(UIWebView *)theWebView
        withKey:(NSString *)theKey;

#pragma mark -
#pragma mark Getter
+(id)blockForWebView:(UIWebView *)theWebView withKey:(NSString *)theKey;

@end

@implementation SHWebViewBlockManager

#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.mapBlocks            = [NSMapTable weakToStrongObjectsMapTable];
    [self SH_memoryDebugger];
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static SHWebViewBlockManager * _sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHWebViewBlockManager alloc] init];
    
  });
  
  return _sharedInstance;
  
}


#pragma mark -
#pragma mark Debugger
-(void)SH_memoryDebugger; {
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    NSLog(@"MAP %@",self.mapBlocks);
    [self SH_memoryDebugger];
  });
}

#pragma mark -
#pragma mark Class selectors

#pragma mark -
#pragma mark Setter
+(void)setDelegateForWebView:(UIWebView *)theWebView ;{
  [theWebView setDelegate:[SHWebViewBlockManager sharedManager]];
}

+(void)setBlock:(id)theBlock
  forWebView:(UIWebView *)theWebView
        withKey:(NSString *)theKey; {

  NSAssert(theWebView, @"Must pass theWebView");
  
  SHNavigationControllerBlock block = [theBlock copy];
  
  SHWebViewBlockManager * manager = [SHWebViewBlockManager
                                                  sharedManager];
  NSMutableDictionary * map = [manager.mapBlocks objectForKey:theWebView];
  if(map == nil) {
    map = [@{} mutableCopy];
    [manager.mapBlocks setObject:map forKey:theWebView];
  }
  if(block == nil) {
    [map removeObjectForKey:theKey];
    if(map.count == 0) [manager.mapBlocks removeObjectForKey:theWebView];
  }
  
  else map[theKey] = block;
      
}

#pragma mark -
#pragma mark Getter
+(id)blockForWebView:(UIWebView *)theWebView withKey:(NSString *)theKey; {
  NSAssert(theWebView, @"Must pass a controller to fetch blocks for");
  return [[[SHWebViewBlockManager sharedManager].mapBlocks
          objectForKey:theWebView] objectForKey:theKey];
}

#pragma mark -
#pragma mark Delegates


#pragma mark -
#pragma mark <UIWebViewDelegate>
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; {
  
}

-(void)webViewDidStartLoad:(UIWebView *)webView; {
  
}

-(void)webViewDidFinishLoad:(UIWebView *)webView; {
  
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error; {
  
}

//SHNavigationControllerBlock block = [navigationController SH_blockWillShowViewController];
//if(block) block(navigationController, viewController, animated);


@end

@implementation UIWebView  (SHWebViewBlocks)

#pragma mark -
#pragma mark Setup
-(void)SH_setNavigationBlocks; {
  [SHWebViewBlockManager setDelegateForWebView:self];
}


#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Setters



#pragma mark -
#pragma mark Getters

@end