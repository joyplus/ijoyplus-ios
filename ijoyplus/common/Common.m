//
//  Common.m
//  CoolTable
//
//  Created by Ray Wenderlich on 9/29/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "Common.h"

CGRect rectFor1PxStroke(CGRect rect) {
    return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1);
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGFloat colors[]) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
}

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGFloat color[]) {
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);        
    
}

void drawGlossAndGradient(CGContextRef context, CGRect rect, CGFloat colors[]) {
    
    drawLinearGradient(context, rect, colors);
    CGFloat glossColor[8] = {1/255.0, 1/255.0, 1/255.0, 0.35, 1/255.0, 1/255.0, 1/255.0, 0.1};    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);    
    drawLinearGradient(context, topHalf, glossColor);
    
}