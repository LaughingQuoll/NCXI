#import "NCXIViewController.h"
#import <objc/runtime.h>

@interface UIApplication (tweak)
 -(id)_accessibilityFrontMostApplication;
@end

@interface UIView (Private)
-(void)setAlignmentPercent:(CGFloat)arg1;
@end

@interface SBFWallpaperView : UIView
@property (nonatomic,retain) UIImage * wallpaperImage;              //@synthesize displayedImage=_displayedImage - In the implementation block
@end

@interface SBWallpaperController : UIViewController
+(id)sharedInstance;
-(id)_wallpaperViewForVariant:(long long)arg1 ;
@property (nonatomic,retain) SBFWallpaperView * lockscreenWallpaperView;                                             //@synthesize lockscreenWallpaperView=_lockscreenWallpaperView - In the implementation block
-(SBFWallpaperView *)lockscreenWallpaperView;
@end

@interface SBFStaticWallpaperView : SBFWallpaperView
@property (setter=_setDisplayedImage:,getter=_displayedImage,nonatomic,retain) UIImage * displayedImage;
- (UIImage *)wallpaperImage;
@end

bool isOnSpringBoard() {
  if ([[objc_getClass("UIApplication") sharedApplication] _accessibilityFrontMostApplication] != nil) {
    return true;
  }
  else {
    return false;
  }
}


@implementation NCXIViewController
static NCXIViewController *sharedInstance;
+(id)sharedInstance{
  return sharedInstance;
}
-(id)init {
  self = [super init];

  sharedInstance = self;

  CGRect screenBounds = [[UIScreen mainScreen] bounds];

  self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  self.contentScrollView.contentSize = CGSizeMake(screenBounds.size.width * 2, screenBounds.size.height);
  self.contentScrollView.contentOffset = CGPointMake(screenBounds.size.width,0);
  self.contentScrollView.pagingEnabled = TRUE;

  [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
  [self.contentScrollView setShowsVerticalScrollIndicator:NO];

  self.contentScrollView.delegate = self;

  if (isOnSpringBoard()) {
    CGRect newFrame = self.view.bounds;
    newFrame.origin.y = self.view.bounds.size.height;
    self.wallpaperView = [[UIImageView alloc] initWithFrame:newFrame];
  }
  else {
  CGRect newFrame = self.view.bounds;
  newFrame.origin.y = self.view.bounds.size.height/4;
  self.wallpaperView = [[UIImageView alloc] initWithFrame:newFrame];
  }

  [self.view addSubview:self.wallpaperView];

  SBFStaticWallpaperView *wallpaperView = [[objc_getClass("SBWallpaperController") sharedInstance] _wallpaperViewForVariant:0];
  self.wallpaperView.image = [wallpaperView.wallpaperImage copy];
  self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
  self.wallpaperView.clipsToBounds = true;

  self.blurView = [[NCXIBlurView alloc] init];
  self.blurView.frame = self.view.bounds;
  [self.view addSubview:self.blurView];

  self.dateView = [[NSClassFromString(@"SBLockScreenDateViewController") alloc] init];
  self.dateView.view.frame = CGRectMake(screenBounds.size.width/12, screenBounds.size.height/10.5, screenBounds.size.width - (screenBounds.size.width/6),screenBounds.size.height/5);
  [self.view addSubview:self.dateView.view];

  self.pageControl = [[[UIPageControl alloc] init] autorelease];
  self.pageControl.frame = CGRectMake(screenBounds.size.width/2 - screenBounds.size.width/16,screenBounds.size.height - screenBounds.size.height/32,screenBounds.size.width/8,screenBounds.size.height/32);
  self.pageControl.numberOfPages = 2;
  self.pageControl.currentPage = 0;
  [self.view addSubview:self.pageControl];

  self.notificationsPage = [[UIView alloc] init];
  self.notificationsPage.frame = CGRectMake(screenBounds.size.width, 0, screenBounds.size.width, screenBounds.size.height - screenBounds.size.height/32);
  self.notificationsPage.clipsToBounds = TRUE;
  [self.contentScrollView addSubview:self.notificationsPage];

  self.widgetsPage = [[UIView alloc] init];
  self.widgetsPage.frame = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
  [self.contentScrollView addSubview:self.widgetsPage];

  self.widgetsViewController = [[NSClassFromString(@"NCXISearchWidgetsPageViewController") alloc] init];
  self.widgetsViewController.view.frame = CGRectMake(0, 0, screenBounds.size.width,screenBounds.size.height);
  [self.widgetsPage addSubview:self.widgetsViewController.view];

  [self.view addSubview:self.contentScrollView];

  [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self.blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self.wallpaperView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self.contentScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

  return self;
}
-(void)setProgress:(CGFloat)progress {
  // Credits to JakeAsJames for providing CALayer masking adjustments for backdrop blur.
  CALayer *maskLayer = [CALayer layer];
  maskLayer.backgroundColor = [UIColor blackColor].CGColor;
  CGRect maskFrame = self.wallpaperView.frame;
  CGRect newFrame = self.wallpaperView.frame;

  if (isOnSpringBoard()) {
    maskFrame.origin.y = ((1 - progress) * self.wallpaperView.frame.size.height) - self.wallpaperView.frame.size.height;
    maskLayer.frame = maskFrame;
    self.wallpaperView.layer.mask = maskLayer;
    self.wallpaperView.alpha = (1 - progress)*1.15;

    newFrame.origin.y = progress * self.wallpaperView.frame.size.height;
  } else {
    maskFrame.origin.y = ((1 - progress) * self.wallpaperView.frame.size.height/4) - self.wallpaperView.frame.size.height/4;
    maskLayer.frame = maskFrame;
    self.wallpaperView.layer.mask = maskLayer;
    self.wallpaperView.alpha = (1 - progress)*1.2;

    newFrame.origin.y = progress * self.wallpaperView.frame.size.height/4;
  }

  self.wallpaperView.frame = newFrame;

  if (progress >= 0.7) {
     [self.blurView setProgress:1];
  } else {
   [self.blurView setProgress:progress*(1/0.7)];
  }
}
-(void)viewDidLayoutSubviews {

  SBFStaticWallpaperView *wallpaperView = [[objc_getClass("SBWallpaperController") sharedInstance] _wallpaperViewForVariant:0];
  self.wallpaperView.image = [wallpaperView.displayedImage copy];

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];

  CGFloat pageWidth = self.contentScrollView.frame.size.width; // you need to have a **iVar** with getter for scrollView
  float fractionalPage = self.contentScrollView.contentOffset.x / pageWidth;
  NSInteger page = lround(fractionalPage);

  self.pageControl.currentPage = page; // you need to have a **iVar** with getter for pageControl
  self.pageControl.alpha = fractionalPage;

  [self.dateView.view setAlignmentPercent:(1 - fractionalPage)];

  self.dateView.view.frame = CGRectMake(self.dateView.view.frame.origin.x, screenBounds.size.height/10.5, self.dateView.view.frame.size.width, self.dateView.view.frame.size.height);

}
-(void)adjustVerticalDateOffset:(CGPoint)point {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];

  self.dateView.view.frame = CGRectMake(self.dateView.view.frame.origin.x, -point.y + screenBounds.size.height/10.5, self.dateView.view.frame.size.width, self.dateView.view.frame.size.height);
}
-(void)adjustWidgetsForLongLook:(BOOL)active {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  if(active){
    self.widgetsPage.frame = CGRectMake(screenBounds.size.width, 0, screenBounds.size.width, screenBounds.size.height);
  } else {
    self.widgetsPage.frame = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
  }
}
@end
