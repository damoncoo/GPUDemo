//
//  FilterModel.m
//  GPUDemo
//
//  Created by Darcy on 16/6/1.
//  Copyright © 2016年 Darcy. All rights reserved.
//

#import "FilterModel.h"

@implementation FilterModel

- (id)init {
    self = [super init];
    if (self) {
        self.filterRange = FilterRangeMake(0, 1);
        self.progress = 0;
    }
    return self;
}

@end
