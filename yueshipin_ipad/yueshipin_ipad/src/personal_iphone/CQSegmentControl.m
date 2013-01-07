
#import "CQSegmentControl.h"

#define		DEFAULTFONTSIZE				14.0f		//默认字体
#define		DEFAULTFCORNERRADIUS		8.0f		//在非完全自定义下，默认圆角

@implementation CQSegmentControl

@synthesize items = items_;
@synthesize normalImageItems = normalImageItems_;
@synthesize highlightImageItems = highlightImageItems_;

- (id)initWithItemsAndStype:(NSArray *)array stype:(CQSegmentedControlType)type
{
	if (self = [super initWithItems:array]) 
	{
		NSMutableArray *mutableArray = [array mutableCopy];
		self.items = mutableArray;
		
		
		segmentedType_ = type;
		canCustom = YES;
		if (type != TitleAndImageSegmented)
		{
			self.normalImageItems = nil;
			self.highlightImageItems = nil;
		}
	}
	
	return self;
}


- (void)setSegmentedType:(CQSegmentedControlType)type
{
	if (segmentedType_ != type)
	{
		[self setNeedsDisplay];
	}
	segmentedType_ = type;
}

- (CQSegmentedControlType) segmentedType
{
	return segmentedType_;
}

- (UIFont *)font {
	if (font_ == nil) {
		self.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
	}
	return font_;
}

- (void)setFont:(UIFont *)aFont {
	if (font_ != aFont) {
		
		font_ = aFont ;
		
		[self setNeedsDisplay];
	}
}

- (UIColor *)selectedItemColor {
	if (selectedItemColor_ == nil) {
		self.selectedItemColor = [UIColor whiteColor];
	}
	return selectedItemColor_;
}

- (void)setSelectedItemColor:(UIColor *)aColor {
	if (aColor != selectedItemColor_) {
		
		selectedItemColor_ = aColor ;
		
		[self setNeedsDisplay];
	}
}

- (UIColor *)unselectedItemColor {
	if (unselectedItemColor_ == nil) {
		self.unselectedItemColor = [UIColor whiteColor];
	}
	return unselectedItemColor_;
}

- (void)setUnselectedItemColor:(UIColor *)aColor {
	if (aColor != unselectedItemColor_) {
		
		unselectedItemColor_ = aColor ;
		
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Custom Methods

- (void)setNormalImage:(UIImage *)image atIndex:(NSUInteger)segment
{
	if (!canCustom) {
		return;
	} 
	else
	{
		if (!segment || segment >= self.numberOfSegments) return;
		[self.normalImageItems replaceObjectAtIndex:segment withObject:image];
		[self setNeedsDisplay];
	}
}

- (void)setHighlightedImage:(UIImage *)image atIndex:(NSUInteger)segment
{
	if (!canCustom)
	{
		return;
	}
	else 
	{
		if (!segment || segment >= self.numberOfSegments) return;
		[self.highlightImageItems removeObjectAtIndex:segment];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark override UISegmentedControl Methods
- (NSUInteger)numberOfSegments {
	if (!self.items) {
		return [super numberOfSegments];
	} else {
		return self.items.count;
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0) {
        rect.size.width = 162;
    }
    // Drawing code.
	if (canCustom == NO) 
	{
		[super drawRect:rect];
		return;
	}
	
	CGSize itemSize = CGSizeMake(round(rect.size.width / self.numberOfSegments), rect.size.height);
	// Rect with radius, will be used to clip the entire view
	CGFloat minx = CGRectGetMinX(rect) + 1, midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
	CGFloat miny = CGRectGetMinY(rect) + 1, midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
	
	
	if (segmentedType_ == TitleAndImageSegmented) {
		for (int i = 0; i < self.numberOfSegments; i++)
		{
			NSString *string = (NSString *)[items_ objectAtIndex:i];
			CGSize stringSize = [string sizeWithFont:self.font];
			CGRect stringRect = CGRectMake(i * itemSize.width + (itemSize.width - stringSize.width) / 2, 
										   (itemSize.height - stringSize.height) / 2,
										   stringSize.width,
										   stringSize.height);
			
			if (self.selectedSegmentIndex == i) 
			{
				UIImage *selectImage = (UIImage *)[self.highlightImageItems objectAtIndex:i];
				[selectImage drawAtPoint:CGPointMake(i * itemSize.width, 0)];
				
				//[[UIColor colorWithWhite:0.0f alpha:1.0f] setFill];
				//[string drawInRect:CGRectOffset(stringRect, 0.0f, -1.0f) withFont:self.font];
				[self.selectedItemColor setFill];	
				//[self.selectedItemColor setStroke];	
				[string drawInRect:stringRect withFont:self.font];
				
			} else {
				UIImage *selectImage = (UIImage *)[self.normalImageItems objectAtIndex:i];
				[selectImage drawAtPoint:CGPointMake(i * itemSize.width, 0)];
				
				[[UIColor whiteColor] setFill];			
				//[string drawInRect:CGRectOffset(stringRect, 0.0f, 1.0f) withFont:self.font];
				[self.unselectedItemColor setFill];
				[string drawInRect:stringRect withFont:self.font];
			}
		}
	}
	else {
		CGContextRef c = UIGraphicsGetCurrentContext();
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		CGContextSaveGState(c);
		
		// Path are drawn starting from the middle of a pixel, in order to avoid an antialiased line
		CGContextMoveToPoint(c, minx - .5, midy - .5);
		CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, DEFAULTFCORNERRADIUS);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, DEFAULTFCORNERRADIUS);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, DEFAULTFCORNERRADIUS);
		CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, DEFAULTFCORNERRADIUS);
		CGContextClosePath(c);
		
		CGContextClip(c);
		
		
		// Background gradient for non selected items
		CGFloat components[8] = { 
			255/255.0, 255/255.0, 255/255.0, 1.0, 
			200/255.0, 200/255.0, 200/255.0, 1.0
		};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
		CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
		CFRelease(gradient);
		
		for (int i = 0; i < self.numberOfSegments; i++) {
			BOOL isLeftItem  = i == 0;
			BOOL isRightItem = i == self.numberOfSegments -1;
			
			CGRect itemBgRect = CGRectMake(i * itemSize.width, 
										   0.0f,
										   itemSize.width,
										   rect.size.height);
			
			if (i == self.selectedSegmentIndex) {
				
				// -- Selected item --
				
				// Background gradient is composed of two gradients, one on the top, another rounded on the bottom
				
				CGContextSaveGState(c);
				CGContextClipToRect(c, itemBgRect);
				
				float factor  = 1.22f; // multiplier applied to the first color of the gradient to obtain the second
				float mfactor = 1.25f; // multiplier applied to the color of the first gradient to obtain the bottom gradient
				
				int red = 55, green = 111, blue = 214; // default blue color
				
				if (self.tintColor != nil) {
					const CGFloat *components = CGColorGetComponents(self.tintColor.CGColor);
					size_t numberOfComponents = CGColorGetNumberOfComponents(self.tintColor.CGColor);
					
					if (numberOfComponents == 2) {
						red = green = blue = components[0] * 255;
					} else if (numberOfComponents == 4) {
						red   = components[0] * 255;
						green = components[1] * 255;
						blue  = components[2] * 255;
					}
				}
				
				
				// Top gradient
				
				CGFloat top_components[16] = { 
					red / 255.0f,         green / 255.0f,         blue/255.0f          , 1.0f,
					(red*mfactor)/255.0f, (green*mfactor)/255.0f, (blue*mfactor)/255.0f, 1.0f
				};
				
				CGFloat top_locations[2] = {
					0.0f, .75f
				};
				
				CGGradientRef top_gradient = CGGradientCreateWithColorComponents(colorSpace, top_components, top_locations, 2);
				CGContextDrawLinearGradient(c, 
											top_gradient, 
											itemBgRect.origin, 
											CGPointMake(itemBgRect.origin.x, 
														itemBgRect.size.height), 
											kCGGradientDrawsBeforeStartLocation);
				CFRelease(top_gradient);
				CGContextRestoreGState(c);
				
				
				// Bottom gradient
				// It's clipped in a rect with the left corners rounded if segment is the first,
				// right corners rounded if segment is the last, no rounded corners for the segments inbetween
				
				CGRect bottomGradientRect = CGRectMake(itemBgRect.origin.x, 
													   itemBgRect.origin.y + round(itemBgRect.size.height / 2), 
													   itemBgRect.size.width, 
													   round(itemBgRect.size.height / 2));
				
				CGFloat gradient_minx = CGRectGetMinX(bottomGradientRect) + 1;
				CGFloat gradient_midx = CGRectGetMidX(bottomGradientRect);
				CGFloat gradient_maxx = CGRectGetMaxX(bottomGradientRect);
				CGFloat gradient_miny = CGRectGetMinY(bottomGradientRect) + 1;
				CGFloat gradient_midy = CGRectGetMidY(bottomGradientRect);
				CGFloat gradient_maxy = CGRectGetMaxY(bottomGradientRect);
				
				
				CGContextSaveGState(c);
				if (isLeftItem) {
					CGContextMoveToPoint(c, gradient_minx - .5f, gradient_midy - .5f);
				} else {
					CGContextMoveToPoint(c, gradient_minx - .5f, gradient_miny - .5f);
				}
				
				CGContextAddArcToPoint(c, gradient_minx - .5f, gradient_miny - .5f, gradient_midx - .5f, gradient_miny - .5f, DEFAULTFCORNERRADIUS);
				
				if (isRightItem) {
					CGContextAddArcToPoint(c, gradient_maxx - .5f, gradient_miny - .5f, gradient_maxx - .5f, gradient_midy - .5f, DEFAULTFCORNERRADIUS);
					CGContextAddArcToPoint(c, gradient_maxx - .5f, gradient_maxy - .5f, gradient_midx - .5f, gradient_maxy - .5f, DEFAULTFCORNERRADIUS);
				} else {
					CGContextAddLineToPoint(c, gradient_maxx, gradient_miny);
					CGContextAddLineToPoint(c, gradient_maxx, gradient_maxy);
				}
				
				if (isLeftItem) {
					CGContextAddArcToPoint(c, gradient_minx - .5f, gradient_maxy - .5f, gradient_minx - .5f, gradient_midy - .5f, DEFAULTFCORNERRADIUS);
				} else {
					CGContextAddLineToPoint(c, gradient_minx, gradient_maxy);
				}
				
				CGContextClosePath(c);
				
				
				CGContextClip(c);
				CGFloat bottom_components[16] = {
					(red*factor)        /255.0f, (green*factor)        /255.0f, (blue*factor)/255.0f,         1.0f,
					(red*factor*mfactor)/255.0f, (green*factor*mfactor)/255.0f, (blue*factor*mfactor)/255.0f, 1.0f
				};
				
				CGFloat bottom_locations[2] = {
					0.0f, 1.0f
				};
				
				CGGradientRef bottom_gradient = CGGradientCreateWithColorComponents(colorSpace, bottom_components, bottom_locations, 2);
				CGContextDrawLinearGradient(c, 
											bottom_gradient, 
											bottomGradientRect.origin, 
											CGPointMake(bottomGradientRect.origin.x, 
														bottomGradientRect.origin.y + bottomGradientRect.size.height), 
											kCGGradientDrawsBeforeStartLocation);
				CFRelease(bottom_gradient);
				CGContextRestoreGState(c);
				
				
				
				// Inner shadow
				
				int blendMode = kCGBlendModeDarken;
				
				// Right and left inner shadow 
				CGContextSaveGState(c);
				CGContextSetBlendMode(c, blendMode);
				CGContextClipToRect(c, itemBgRect);
				
				CGFloat inner_shadow_components[16] = {
					0.0f, 0.0f, 0.0f, isLeftItem ? 0.0f : .25f,
					0.0f, 0.0f, 0.0f, 0.0f,
					0.0f, 0.0f, 0.0f, 0.0f,
					0.0f, 0.0f, 0.0f, isRightItem ? 0.0f : .25f
				};
				
				
				CGFloat locations[4] = {
					0.0f, .05f, .95f, 1.0f
				};
				CGGradientRef inner_shadow_gradient = CGGradientCreateWithColorComponents(colorSpace, inner_shadow_components, locations, 4);
				CGContextDrawLinearGradient(c, 
											inner_shadow_gradient, 
											itemBgRect.origin, 
											CGPointMake(itemBgRect.origin.x + itemBgRect.size.width, 
														itemBgRect.origin.y), 
											kCGGradientDrawsAfterEndLocation);
				CFRelease(inner_shadow_gradient);
				CGContextRestoreGState(c);
				
				// Top inner shadow 
				CGContextSaveGState(c);
				CGContextSetBlendMode(c, blendMode);
				CGContextClipToRect(c, itemBgRect);
				CGFloat top_inner_shadow_components[8] = { 
					0.0f, 0.0f, 0.0f, 0.25f,
					0.0f, 0.0f, 0.0f, 0.0f
				};
				CGFloat top_inner_shadow_locations[2] = {
					0.0f, .10f
				};
				CGGradientRef top_inner_shadow_gradient = CGGradientCreateWithColorComponents(colorSpace, top_inner_shadow_components, top_inner_shadow_locations, 2);
				CGContextDrawLinearGradient(c, 
											top_inner_shadow_gradient, 
											itemBgRect.origin, 
											CGPointMake(itemBgRect.origin.x, 
														itemBgRect.size.height), 
											kCGGradientDrawsAfterEndLocation);
				CFRelease(top_inner_shadow_gradient);
				CGContextRestoreGState(c);
				
			}
			
			id item = [items_ objectAtIndex:i];
			if ([item isKindOfClass:[UIImage class]]) {
				CGImageRef imageRef = [(UIImage *)item CGImage];
				
				CGRect imageRect = CGRectMake(round(i * itemSize.width + (itemSize.width - CGImageGetWidth(imageRef)) / 2), 
											  round((itemSize.height - CGImageGetHeight(imageRef)) / 2),
											  CGImageGetWidth(imageRef),
											  CGImageGetHeight(imageRef));
				
				
				if (i == self.selectedSegmentIndex) {
					
					CGContextSaveGState(c);
					CGContextTranslateCTM(c, 0, rect.size.height);  
					CGContextScaleCTM(c, 1.0, -1.0);  
					
					CGContextRestoreGState(c);
					
					CGContextSaveGState(c);
					CGContextTranslateCTM(c, 0, rect.size.height);  
					CGContextScaleCTM(c, 1.0, -1.0);  
					
					CGContextClipToMask(c, imageRect, imageRef);
					CGContextSetFillColorWithColor(c, [self.selectedItemColor CGColor]);
					
					CGContextFillRect(c, imageRect);
					CGContextRestoreGState(c);
				} 
				else {
					
					CGContextSaveGState(c);
					CGContextTranslateCTM(c, 0, itemBgRect.size.height);  
					CGContextScaleCTM(c, 1.0, -1.0);  
					
					CGContextClipToMask(c, CGRectOffset(imageRect, 0, -1), imageRef);
					CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
					CGContextFillRect(c, CGRectOffset(imageRect, 0, -1));
					CGContextRestoreGState(c);
					
					CGContextSaveGState(c);
					CGContextTranslateCTM(c, 0, itemBgRect.size.height);  
					CGContextScaleCTM(c, 1.0, -1.0);  
					
					CGContextClipToMask(c, imageRect, imageRef);
					CGContextSetFillColorWithColor(c, [self.unselectedItemColor CGColor]);
					CGContextFillRect(c, imageRect);
					CGContextRestoreGState(c);
				}
			}
			else if ([item isKindOfClass:[NSString class]]) {
				
				NSString *string = (NSString *)[items_ objectAtIndex:i];
				CGSize stringSize = [string sizeWithFont:self.font];
				CGRect stringRect = CGRectMake(i * itemSize.width + (itemSize.width - stringSize.width) / 2, 
											   (itemSize.height - stringSize.height) / 2,// + kTopPadding,
											   stringSize.width,
											   stringSize.height);
				
				if (self.selectedSegmentIndex == i) {
					[[UIColor colorWithWhite:0.0f alpha:.2f] setFill];
					[string drawInRect:CGRectOffset(stringRect, 0.0f, -1.0f) withFont:self.font];
					[self.selectedItemColor setFill];	
					[self.selectedItemColor setStroke];	
					[string drawInRect:stringRect withFont:self.font];
				} else {
					[[UIColor whiteColor] setFill];			
					[string drawInRect:CGRectOffset(stringRect, 0.0f, 1.0f) withFont:self.font];
					[self.unselectedItemColor setFill];
					[string drawInRect:stringRect withFont:self.font];
				}
			}
			
			// Separator分割线
			if (i > 0 && i - 1 != self.selectedSegmentIndex && i != self.selectedSegmentIndex) {
				CGContextSaveGState(c);
				
				CGContextMoveToPoint(c, itemBgRect.origin.x + .5, itemBgRect.origin.y);
				CGContextAddLineToPoint(c, itemBgRect.origin.x + .5, itemBgRect.size.height);
				
				CGContextSetLineWidth(c, .5f);
				CGContextSetStrokeColorWithColor(c, [UIColor colorWithWhite:120/255.0 alpha:1.0].CGColor);
				CGContextStrokePath(c);
				
				CGContextRestoreGState(c);
			}
		}
		CGContextRestoreGState(c);
		
		if (self.segmentedControlStyle ==  UISegmentedControlStyleBordered) {
			CGContextMoveToPoint(c, minx - .5, midy - .5);
			CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, DEFAULTFCORNERRADIUS);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c,[UIColor blackColor].CGColor);
			CGContextSetLineWidth(c, 1.0f);
			CGContextStrokePath(c);
		} else {
			CGContextSaveGState(c);
			
			CGRect bottomHalfRect = CGRectMake(0, 
											   rect.size.height - DEFAULTFCORNERRADIUS + 7,
											   rect.size.width,
											   DEFAULTFCORNERRADIUS);
			CGContextClearRect(c, CGRectMake(0, 
											 rect.size.height - 1,
											 rect.size.width,
											 1));
			CGContextClipToRect(c, bottomHalfRect);
			
			CGContextMoveToPoint(c, minx + .5, midy - .5);
			CGContextAddArcToPoint(c, minx + .5, miny - .5, midx - .5, miny - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, minx + .5, maxy - .5, minx - .5, midy - .5, DEFAULTFCORNERRADIUS);
			CGContextClosePath(c);
			
			CGContextSetBlendMode(c, kCGBlendModeLighten);
			CGContextSetStrokeColorWithColor(c,[UIColor colorWithWhite:255/255.0 alpha:1.0].CGColor);
			CGContextSetLineWidth(c, .5f);
			CGContextStrokePath(c);
			
			CGContextRestoreGState(c);
			midy--, maxy--;
			CGContextMoveToPoint(c, minx - .5, midy - .5);
			CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, DEFAULTFCORNERRADIUS);
			CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, DEFAULTFCORNERRADIUS);
			CGContextClosePath(c);
			
			CGContextSetBlendMode(c, kCGBlendModeMultiply);
			CGContextSetStrokeColorWithColor(c,[UIColor colorWithWhite:30/255.0 alpha:.9].CGColor);
			CGContextSetLineWidth(c, .5f);
			CGContextStrokePath(c);
		}
		
		
		CFRelease(colorSpace);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!canCustom) {
		[super touchesBegan:touches withEvent:event];
	} else {
		CGPoint point = [[touches anyObject] locationInView:self];
		int itemIndex = floor(self.numberOfSegments * point.x / self.bounds.size.width);
        
        if (itemIndex >= 0)
        {
		self.selectedSegmentIndex = itemIndex;
		}
        
		[self setNeedsDisplay];
	}
}

- (void)setSegmentedControlStyle:(UISegmentedControlStyle)aStyle {
	[super setSegmentedControlStyle:aStyle];
	if (canCustom) {
		[self setNeedsDisplay];
	}
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
	
	if (!canCustom) {
		[super setTitle:title forSegmentAtIndex:segment];
	} else {
		[self.items replaceObjectAtIndex:segment withObject:title];
		[self setNeedsDisplay];
	}
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment {
	if (!canCustom) {
		[super setImage:image forSegmentAtIndex:segment];
	} else {
		[self.items replaceObjectAtIndex:segment withObject:image];
		[self setNeedsDisplay];
	}
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated {
	if (!canCustom) {
		[super insertSegmentWithTitle:title atIndex:segment animated:animated];
	} else {
		if (!segment || segment >= self.numberOfSegments) return;
		[super insertSegmentWithTitle:title atIndex:segment animated:animated];
		[self.items insertObject:title atIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated {
	if (!canCustom) {
		[super insertSegmentWithImage:image atIndex:segment animated:animated];
	} else {
		if (!segment || segment >= self.numberOfSegments) return;
		[super insertSegmentWithImage:image atIndex:segment animated:animated];
		[self.items insertObject:image atIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated {
	if (!canCustom) {
		[super removeSegmentAtIndex:segment animated:animated];
	} else {
		if (!segment || segment >= self.numberOfSegments) return;
		[self.items removeObjectAtIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    if (selectedSegmentIndex == self.selectedSegmentIndex) return;
    
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    
#ifdef __IPHONE_5_0
    if ([self respondsToSelector:@selector(apportionsSegmentWidthsByContent)]
        && canCustom)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
#endif
}

@end
