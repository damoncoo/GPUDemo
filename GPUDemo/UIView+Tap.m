//
//  UIView+Tap.m
//  Tangren
//
//  Created by  TB-home on 15/10/8.
//  Copyright (c) 2015年  TB-home. All rights reserved.
//

#import "UIView+Tap.h"

@implementation UIView (Tap)

@dynamic top;
@dynamic bottom;
@dynamic left;
@dynamic right;
@dynamic width;
@dynamic height;


static char blockKey;
static char blockLongKey;

#pragma mark - Edges

- (CGFloat)top
{
    return self.frame.origin.y;
}
- (CGFloat)left
{
    return self.frame.origin.x;
}
- (CGFloat)bottom
{
    return self.frame.size.height + self.frame.origin.y;
}

- (CGFloat)right
{
    return self.frame.size.width + self.frame.origin.x;
}
- (CGFloat)width
{
    return self.frame.size.width;
}
- (CGFloat)height
{
    return self.frame.size.height;
}

-(void)removeAllGestures {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
}

#pragma mark - Tap

-(void)handleTap:(TapBlock)tapBlock {
    objc_setAssociatedObject(self, &blockKey, tapBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addAGestureRecognizer];
}

-(void)addAGestureRecognizer {
    [self removeAllGestures];
    self.userInteractionEnabled =   YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(didTapped:)] ;
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Long Tap

-(void)handleLongTap:(TapBlock)tapBlock {
    objc_setAssociatedObject(self, &blockLongKey, tapBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addALongGestureRecognizer];
}

-(void)addALongGestureRecognizer {
    [self removeAllGestures];
    self.userInteractionEnabled =   YES;
    UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc]  initWithTarget:self
                                                                action:@selector(didLongTapped:)] ;
    longTapGesture.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longTapGesture];

}
-(void)didTapped:(UITapGestureRecognizer *)rec {
    
    CGPoint point = [rec locationInView:self];
    TapBlock block =   objc_getAssociatedObject(self, &blockKey);
    block(point,rec);
}

-(void)didLongTapped:(UITapGestureRecognizer *)rec {
    CGPoint point = [rec locationInView:self];
    TapBlock block =   objc_getAssociatedObject(self, &blockLongKey);
    block(point,rec);
}
@end