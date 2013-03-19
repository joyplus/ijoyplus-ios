//
//  AHAlertView.m
//  AHAlertViewSample
//
//	Copyright (C) 2012 Auerhaus Development, LLC
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "AHAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static const char * const kAHAlertViewButtonBlockKey = "AHAlertViewButtonBlock";

static const CGFloat AHAlertViewDefaultWidth = 300;
static const CGFloat AHAlertViewMinimumHeight = 250;
static const CGFloat AHAlertViewDefaultButtonHeight = 50;

CGFloat CGAffineTransformGetAbsoluteRotationAngleDifference(CGAffineTransform t1, CGAffineTransform t2)
{
	CGFloat dot = t1.a * t2.a + t1.c * t2.c;
	CGFloat n1 = sqrtf(t1.a * t1.a + t1.c * t1.c);
	CGFloat n2 = sqrtf(t2.a * t2.a + t2.c * t2.c);
	return acosf(dot / (n1 * n2));
}

#pragma mark - Internal interface

typedef void (^AHAnimationCompletionBlock)(BOOL); // Internal.

@interface AHAlertView () {
	BOOL hasLayedOut;
}

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *messageLabel;
@property (nonatomic, strong) UITextField *plainTextField;
@property (nonatomic, strong) UITextField *secureTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *destructiveButton;
@property (nonatomic, strong) NSMutableArray *otherButtons;
@property (nonatomic, strong) NSMutableDictionary *buttonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *cancelButtonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *destructiveButtonBackgroundImagesForControlStates;
@end

#pragma mark - Implementation

@implementation AHAlertView

@synthesize title = _title;
@synthesize message = _message;
@synthesize otherButtons = _otherButtons;
@synthesize backgroundImage = _backgroundImage;
@synthesize destructiveButton = _destructiveButton;
@synthesize titleLabel;
@synthesize dismissalStyle = _dismissalStyle;
@synthesize backgroundImageView;
@synthesize cancelButtonBackgroundImagesForControlStates;
@synthesize buttonBackgroundImagesForControlStates;
@synthesize contentInsets;
@synthesize destructiveButtonBackgroundImagesForControlStates;
@synthesize presentationStyle = _presentationStyle;
@synthesize plainTextField;
@synthesize titleTextAttributes;
@synthesize messageLabel;
@synthesize alertViewStyle;
@synthesize messageTextAttributes;
@synthesize cancelButton = _cancelButton;
@synthesize visible;
@synthesize buttonTitleTextAttributes;
@synthesize secureTextField;
@synthesize contentTextView;

#pragma mark - Class life cycle methods

+ (void)initialize
{
	[self applySystemAlertAppearance];
}

+ (void)applySystemAlertAppearance {
	// Set up default values for all UIAppearance-compatible selectors
	
//	[[self appearance] setBackgroundImage:[self alertBackgroundImage]];
	
//	[[self appearance] setContentInsets:UIEdgeInsetsMake(16, 8, 8, 8)];
//	
//	[[self appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//											   [UIFont boldSystemFontOfSize:17], UITextAttributeFont,
//											   [UIColor whiteColor], UITextAttributeTextColor,
//											   [UIColor blackColor], UITextAttributeTextShadowColor,
//											   [NSValue valueWithCGSize:CGSizeMake(0, -1)], UITextAttributeTextShadowOffset,
//											   nil]];
//	
//	[[self appearance] setMessageTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//												 [UIFont systemFontOfSize:15], UITextAttributeFont,
//												 [UIColor whiteColor], UITextAttributeTextColor,
//												 [UIColor blackColor], UITextAttributeTextShadowColor,
//												 [NSValue valueWithCGSize:CGSizeMake(0, -1)], UITextAttributeTextShadowOffset,
//												 nil]];
//	
//	[[self appearance] setButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//													 [UIFont boldSystemFontOfSize:17], UITextAttributeFont,
//													 [UIColor whiteColor], UITextAttributeTextColor,
//													 [UIColor blackColor], UITextAttributeTextShadowColor,
//													 [NSValue valueWithCGSize:CGSizeMake(0, -1)], UITextAttributeTextShadowOffset,
//													 nil]];
	
//	[[self appearance] setButtonBackgroundImage:[self normalButtonBackgroundImage] forState:UIControlStateNormal];
	
//	[[self appearance] setCancelButtonBackgroundImage:[self cancelButtonBackgroundImage] forState:UIControlStateNormal];
}

#pragma mark - Instance life cycle methods

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
	CGRect frame = CGRectMake(0, 0, AHAlertViewDefaultWidth, AHAlertViewMinimumHeight);
	
	if((self = [super initWithFrame:frame]))
	{
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1;
		_title = title;
		_message = message;
		
		_presentationStyle = AHAlertViewPresentationStyleDefault;
		_dismissalStyle = AHAlertViewDismissalStyleDefault;

		_otherButtons = [NSMutableArray array];

		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc
{
	for(id button in _otherButtons)
		objc_setAssociatedObject(button, kAHAlertViewButtonBlockKey, nil, OBJC_ASSOCIATION_RETAIN);

	if(_cancelButton)
		objc_setAssociatedObject(_cancelButton, kAHAlertViewButtonBlockKey, nil, OBJC_ASSOCIATION_RETAIN);
	
	if(_destructiveButton)
		objc_setAssociatedObject(_destructiveButton, kAHAlertViewButtonBlockKey, nil, OBJC_ASSOCIATION_RETAIN);

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIDeviceOrientationDidChangeNotification
												  object:nil];

	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (UIButton *)buttonWithTitle:(NSString *)aTitle associatedBlock:(AHAlertViewButtonBlock)block {
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
	
	[button setTitle:aTitle forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	objc_setAssociatedObject(button, kAHAlertViewButtonBlockKey, block, OBJC_ASSOCIATION_RETAIN);
	return button;
}

- (void)addButtonWithTitle:(NSString *)aTitle block:(AHAlertViewButtonBlock)block {
	if(!self.otherButtons)
		self.otherButtons = [NSMutableArray array];
	
	UIButton *otherButton = [self buttonWithTitle:aTitle associatedBlock:block];
	[self.otherButtons addObject:otherButton];
	[self addSubview:otherButton];
}

- (void)setDestructiveButtonTitle:(NSString *)aTitle block:(AHAlertViewButtonBlock)block {
	self.destructiveButton = [self buttonWithTitle:aTitle associatedBlock:block];
	[self addSubview:self.destructiveButton];
}

- (void)setCancelButtonTitle:(NSString *)aTitle block:(AHAlertViewButtonBlock)block {
	self.cancelButton = [self buttonWithTitle:aTitle associatedBlock:block];
	[self addSubview:self.cancelButton];
}

#pragma mark - Text field accessor

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
	return nil;
}

#pragma mark - Appearance selectors

- (void)setButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
	if(!self.buttonBackgroundImagesForControlStates)
		self.buttonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
	
	[self.buttonBackgroundImagesForControlStates setObject:backgroundImage
													forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *)buttonBackgroundImageForState:(UIControlState)state
{
	return [self.buttonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

- (void)setCancelButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
	if(!self.cancelButtonBackgroundImagesForControlStates)
		self.cancelButtonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];

	[self.cancelButtonBackgroundImagesForControlStates setObject:backgroundImage
														  forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *)cancelButtonBackgroundImageForState:(UIControlState)state
{
	return [self.cancelButtonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

- (void)setDestructiveButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
	if(!self.destructiveButtonBackgroundImagesForControlStates)
		self.destructiveButtonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
	
	[self.destructiveButtonBackgroundImagesForControlStates setObject:backgroundImage
															   forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *)destructiveButtonBackgroundImageForState:(UIControlState)state
{
	return [self.destructiveButtonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

#pragma mark - Presentation and dismissal methods

- (void)show {
	[self showWithStyle:self.presentationStyle];
}

- (void)showWithStyle:(AHAlertViewPresentationStyle)style
{
	self.presentationStyle = style;
	
	[self setNeedsLayout];
	
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
	UIImageView *dimView = [[UIImageView alloc] initWithFrame:keyWindow.bounds];
//	dimView.image = [self backgroundGradientImageWithSize:keyWindow.bounds.size];
	dimView.userInteractionEnabled = YES;

	[keyWindow addSubview:dimView];
	[dimView addSubview:self];
	
	[self performPresentationAnimation];
}


- (void)dismiss {
	[self dismissWithStyle:self.dismissalStyle];
}

- (void)dismissWithStyle:(AHAlertViewDismissalStyle)style {
	self.dismissalStyle = style;
	[self performDismissalAnimation];
}

- (void)buttonWasPressed:(UIButton *)sender {
	AHAlertViewButtonBlock block = objc_getAssociatedObject(sender, kAHAlertViewButtonBlockKey);
	if(block) block();
	
	[self dismissWithStyle:self.dismissalStyle];
}

#pragma mark - Presentation and dismissal animation utilities

- (void)performPresentationAnimation
{
	if(self.presentationStyle == AHAlertViewPresentationStylePop)
	{
		CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animation];
		bounceAnimation.duration = 0.3;
		bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		bounceAnimation.values = [NSArray arrayWithObjects:
								  [NSNumber numberWithFloat:0.01],
								  [NSNumber numberWithFloat:1.1],
								  [NSNumber numberWithFloat:0.9],
								  [NSNumber numberWithFloat:1.0],
								  nil];
		
		[self.layer addAnimation:bounceAnimation forKey:@"transform.scale"];
		
		CABasicAnimation *fadeInAnimation = [CABasicAnimation animation];
		fadeInAnimation.duration = 0.3;
		fadeInAnimation.fromValue = [NSNumber numberWithFloat:0];
		fadeInAnimation.toValue = [NSNumber numberWithFloat:1];
		[self.superview.layer addAnimation:fadeInAnimation forKey:@"opacity"];
	}
	else if(self.presentationStyle == AHAlertViewPresentationStyleFade)
	{
		self.superview.alpha = 0;
		
		[UIView animateWithDuration:0.3
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^
		 {
			 self.superview.alpha = 1;
		 }
						 completion:nil];
	}
	else
	{
		// Views appear immediately when added
	}
}

- (void)performDismissalAnimation {
	AHAnimationCompletionBlock completionBlock = ^(BOOL finished)
	{
		[self.superview removeFromSuperview];
		[self removeFromSuperview];
	};
	
	if(self.dismissalStyle == AHAlertViewDismissalStyleTumble)
	{
		[UIView animateWithDuration:0.7
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^
		 {
			 CGPoint offset = CGPointMake(0, self.superview.bounds.size.height * 1.5);
			 offset = CGPointApplyAffineTransform(offset, self.transform);
			 self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(-M_PI_4));
			 self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
			 self.superview.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else if(self.dismissalStyle == AHAlertViewDismissalStyleFade)
	{
		[UIView animateWithDuration:0.25
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^
		 {
			 self.superview.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else if(self.dismissalStyle == AHAlertViewDismissalStyleZoomDown)
	{
		[UIView animateWithDuration:0.3
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^
		 {
			 self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(0.01, 0.01));
			 self.superview.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else if(self.dismissalStyle == AHAlertViewDismissalStyleZoomOut)
	{
		[UIView animateWithDuration:0.2
							  delay:0.0
							options:UIViewAnimationOptionCurveLinear
						 animations:^
		 {
			 self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(10, 10));
			 self.superview.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else
	{
		completionBlock(YES);
	}
}

#pragma mark - Layout calculation methods

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGAffineTransform baseTransform = [self transformForCurrentOrientation];
	
	CGFloat delta = CGAffineTransformGetAbsoluteRotationAngleDifference(self.transform, baseTransform);
	BOOL isDoubleRotation = (delta > M_PI);
	
	if(hasLayedOut)
	{
		CGFloat duration = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
		if(isDoubleRotation)
			duration *= 2;
		
		[UIView animateWithDuration:duration animations:^{
			self.transform = baseTransform;
		}];
	}
	else
		self.transform = baseTransform;
	
	hasLayedOut = YES;
	
	CGRect boundingRect = self.bounds;
	boundingRect.size.height = FLT_MAX;
	boundingRect = UIEdgeInsetsInsetRect(boundingRect, self.contentInsets);
	
	if(!self.titleLabel)
		self.titleLabel = [self addLabelAsSubview];
	
	[self applyTextAttributes:self.titleTextAttributes toLabel:self.titleLabel];
	self.titleLabel.text = self.title;
	CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:boundingRect.size lineBreakMode:UILineBreakModeWordWrap];
	self.titleLabel.frame = CGRectMake(boundingRect.origin.x, boundingRect.origin.y, boundingRect.size.width, titleSize.height);
	
	const CGFloat titleLabelBottomMargin = 10;
	CGFloat messageLabelOriginY = boundingRect.origin.y + titleSize.height + titleLabelBottomMargin;
	
	if(!self.messageLabel)
		self.messageLabel = [self addTextViewAsSubview];
	
//	[self applyTextAttributes:self.messageTextAttributes toLabel:self.messageLabel];
//	self.messageLabel.text = self.message;
//	CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font constrainedToSize:boundingRect.size lineBreakMode:UILineBreakModeWordWrap];
//	self.messageLabel.frame = CGRectMake(boundingRect.origin.x, messageLabelOriginY, boundingRect.size.width, messageSize.height);
    CGSize messageSize = self.messageLabel.frame.size;
	
	const CGFloat messageLabelBottomMargin = 0;
	CGFloat buttonOriginY = messageLabelOriginY + messageSize.height + messageLabelBottomMargin;
	
	[self applyBackgroundImages:self.cancelButtonBackgroundImagesForControlStates toButton:self.cancelButton];
	[self applyTextAttributes:self.buttonTitleTextAttributes toButton:self.cancelButton];
	CGRect cancelButtonRect = CGRectMake(boundingRect.origin.x - 10, buttonOriginY, boundingRect.size.width + 16, AHAlertViewDefaultButtonHeight);
	self.cancelButton.frame = cancelButtonRect;
	
	if([self.otherButtons count] > 0)
	{
		UIButton *otherButton = [self.otherButtons objectAtIndex:0];
		[self applyBackgroundImages:self.buttonBackgroundImagesForControlStates toButton:otherButton];
		[self applyTextAttributes:self.buttonTitleTextAttributes toButton:otherButton];
		CGRect otherButtonRect = CGRectMake(cancelButtonRect.origin.x + cancelButtonRect.size.width + 8, buttonOriginY, boundingRect.size.width * 0.5 - 4, AHAlertViewDefaultButtonHeight);
		otherButton.frame = otherButtonRect;
	}
	
	CGFloat calculatedHeight = buttonOriginY + cancelButtonRect.size.height + self.contentInsets.bottom;
	
	CGRect newBounds = CGRectMake(0, 0, self.bounds.size.width, calculatedHeight);
	CGPoint newCenter = CGPointMake(self.superview.bounds.size.width * 0.5, self.superview.bounds.size.height * 0.5);
	self.bounds = newBounds;
	self.center = newCenter;
	
	if(!self.backgroundImageView)
	{
		self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		self.backgroundImageView.autoresizingMask = ~UIViewAutoresizingNone;
		self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self insertSubview:self.backgroundImageView atIndex:0];
	}
	
	self.backgroundImageView.image = [self.backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    self.backgroundImageView.alpha = 1;
}

- (UILabel *)addLabelAsSubview
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	[self addSubview:label];
	
	return label;
}

- (UITextView *)addTextViewAsSubview
{
    [self addSubview:contentTextView];
    return contentTextView;
}

- (void)applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label {
	label.font = [attributes objectForKey:UITextAttributeFont];
	label.textColor = [attributes objectForKey:UITextAttributeTextColor];
	label.shadowColor = [attributes objectForKey:UITextAttributeTextShadowColor];
	label.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyTextAttributes:(NSDictionary *)attributes toButton:(UIButton *)button {
	button.titleLabel.font = [attributes objectForKey:UITextAttributeFont];
	[button setTitleColor:[attributes objectForKey:UITextAttributeTextColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[attributes objectForKey:UITextAttributeTextShadowColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyBackgroundImages:(NSDictionary *)imagesForStates toButton:(UIButton *)button {
	[imagesForStates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[button setBackgroundImage:obj forState:[key integerValue]];
	}];
}

#pragma mark - Orientation helpers

- (CGAffineTransform)transformForCurrentOrientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation == UIInterfaceOrientationPortraitUpsideDown)
		transform = CGAffineTransformMakeRotation(M_PI);
	else if(orientation == UIInterfaceOrientationLandscapeLeft)
		transform = CGAffineTransformMakeRotation(-M_PI_2);
	else if(orientation == UIInterfaceOrientationLandscapeRight)
		transform = CGAffineTransformMakeRotation(M_PI_2);
	
	return transform;
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
	[self setNeedsLayout];
}

#pragma mark - Drawing utilities for implementing system control styles

- (UIImage *)backgroundGradientImageWithSize:(CGSize)size
{
	CGPoint center = CGPointMake(size.width * 0.5, size.height * 0.5);
	CGFloat innerRadius = 0;
    CGFloat outerRadius = sqrtf(size.width * size.width + size.height * size.height) * 0.5;

	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(size, opaque, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();

    const size_t locationCount = 2;
    CGFloat locations[locationCount] = { 0.0, 1.0 };
    CGFloat components[locationCount * 4] = {
		0.0, 0.0, 0.0, 0.1, // More transparent black
		0.0, 0.0, 0.0, 0.7  // More opaque black
	};
	
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, locationCount);
	
    CGContextDrawRadialGradient(context, gradient, center, innerRadius, center, outerRadius, 0);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
	
    return image;
}

#pragma mark - Class drawing utilities for implementing system control styles

+ (UIImage *)alertBackgroundImage
{
	CGRect rect = CGRectMake(0, 0, AHAlertViewDefaultWidth, AHAlertViewMinimumHeight);
	const CGFloat lineWidth = 2;
	const CGFloat cornerRadius = 8;

	CGFloat shineWidth = rect.size.width * 1.33;
	CGFloat shineHeight = rect.size.width * 0.2;
	CGFloat shineOriginX = rect.size.width * 0.5 - shineWidth * 0.5;
	CGFloat shineOriginY = -shineHeight * 0.45;
	CGRect shineRect = CGRectMake(shineOriginX, shineOriginY, shineWidth, shineHeight);

	UIColor *fillColor = [UIColor colorWithRed:1/255.0 green:21/255.0 blue:54/255.0 alpha:0.9];
	UIColor *strokeColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	
	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);

	CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
	UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
	[fillColor setFill];
	[fillPath fill];
	
	CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
	UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
	strokePath.lineWidth = lineWidth;
	[strokeColor setStroke];
	[strokePath stroke];
	
	UIBezierPath *shinePath = [UIBezierPath bezierPathWithOvalInRect:shineRect];
	[fillPath addClip];
	[shinePath addClip];
	
    const size_t locationCount = 2;
    CGFloat locations[locationCount] = { 0.0, 1.0 };
    CGFloat components[locationCount * 4] = {
		1, 1, 1, 0.75,  // Translucent white
		1, 1, 1, 0.05   // More translucent white
	};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationCount);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint startPoint = CGPointMake(CGRectGetMidX(shineRect), CGRectGetMinY(shineRect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(shineRect), CGRectGetMaxY(shineRect));
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat capHeight = CGRectGetMaxY(shineRect);
	CGFloat capWidth = rect.size.width * 0.5;
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, capWidth, rect.size.height - capHeight, capWidth)];
}

+ (UIImage *)normalButtonBackgroundImage
{
	const size_t locationCount = 4;
	CGFloat opacity = 1.0;
    CGFloat locations[locationCount] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[locationCount * 4] = {
		179/255.0, 185/255.0, 199/255.0, opacity,
		121/255.0, 132/255.0, 156/255.0, opacity,
		87/255.0, 100/255.0, 130/255.0, opacity, 
		108/255.0, 120/255.0, 146/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:locationCount];
}

+ (UIImage *)cancelButtonBackgroundImage
{
	const size_t locationCount = 4;
	CGFloat opacity = 1.0;
    CGFloat locations[locationCount] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[locationCount * 4] = {
		164/255.0, 169/255.0, 184/255.0, opacity,
		77/255.0, 87/255.0, 115/255.0, opacity,
		51/255.0, 63/255.0, 95/255.0, opacity,
		78/255.0, 88/255.0, 116/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:locationCount];
}

+ (UIImage *)glassButtonBackgroundImageWithGradientLocations:(CGFloat *)locations
												  components:(CGFloat *)components
											   locationCount:(NSInteger)locationCount
{
	const CGFloat lineWidth = 1;
	const CGFloat cornerRadius = 4;
	UIColor *strokeColor = [UIColor colorWithRed:1/255.0 green:11/255.0 blue:39/255.0 alpha:1.0];
	
	CGRect rect = CGRectMake(0, 0, cornerRadius * 2 + 1, AHAlertViewDefaultButtonHeight);

	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationCount);
	
	CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
	UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
	strokePath.lineWidth = lineWidth;
	[strokeColor setStroke];
	[strokePath stroke];
	
	CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
	UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
	[fillPath addClip];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat capHeight = floorf(rect.size.height * 0.5);
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, cornerRadius, capHeight, cornerRadius)];
}

@end
