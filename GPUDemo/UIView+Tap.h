//
//  UIView+Tap.h
//  Tangren
//
//  Created by  TB-home on 15/10/8.
//  Copyright (c) 2015年  TB-home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^TapBlock)(CGPoint loc,UIGestureRecognizer *tapGesture);

@interface UIView (Tap)

-(void)handleTap:(TapBlock)tapBlock;

-(void)handleLongTap:(TapBlock)tapBlock;

-(void)removeAllGestures;

@property (assign, nonatomic ,readonly) CGFloat			top;
@property (assign, nonatomic ,readonly) CGFloat			bottom;
@property (assign, nonatomic ,readonly) CGFloat			left;
@property (assign, nonatomic ,readonly) CGFloat			right;
@property (assign, nonatomic ,readonly) CGFloat			width;
@property (assign, nonatomic ,readonly) CGFloat			height;

@end