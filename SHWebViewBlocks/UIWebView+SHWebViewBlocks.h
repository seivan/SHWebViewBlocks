
#pragma mark -
#pragma mark Block Def
typedef void (^SHNavigationControllerBlock)(UINavigationController * theNavigationController,
                                            UIViewController       * theViewController,
                                            BOOL                      isAnimated);


@interface UIWebView (SHWebViewBlocks)

#pragma mark -
#pragma mark Setup
-(void)SH_setNavigationBlocks;


#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Setters



//-(void)SH_setDidShowViewControllerBlock:(SHNavigationControllerBlock)theBlock;

#pragma mark -
#pragma mark Getters

//@property(nonatomic,readonly) SHNavigationControllerBlock SH_blockWillShowViewController;

@end