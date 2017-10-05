#import "NCXIBlurView.h"

@implementation NCXIBlurView
-(id)init {
  self = [super init];

  _UIBackdropViewSettings *defaultSettings = [NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:-2];
	self.backdropSettings = defaultSettings;
	self.backdropView = [[NSClassFromString(@"_UIBackdropView") alloc] initWithSettings:defaultSettings];
	[self.backdropView setAppliesOutputSettingsAnimationDuration:0.25];
  self.backdropView.frame = self.bounds;

  self.backdropSettings = [NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:-2];
	self.backdropSettings.blurRadius = 25.0f;
	self.backdropSettings.saturationDeltaFactor = 2.4f;
	self.backdropSettings.grayscaleTintAlpha = 0;
	self.backdropSettings.colorTintAlpha = 0;
	self.backdropSettings.grayscaleTintLevel = 0;
  self.backdropSettings.usesGrayscaleTintView = NO;
	self.backdropSettings.usesColorTintView = NO;
	self.backdropView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

  [self addSubview:self.backdropView];

  return self;
}
- (void)setProgress:(CGFloat)progress {
	[self.backdropView transitionIncrementallyToSettings:self.backdropSettings weighting:progress];
	if (self.backdropView.colorSaturateFilter) {
		[self.backdropView.colorSaturateFilter setValue:[NSNumber numberWithFloat:self.backdropSettings.saturationDeltaFactor*progress] forKey:@"inputAmount"];
	}
}
@end
