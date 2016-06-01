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
    }
    return self;
}

- (void)setFilterRange:(FilterRange)filterRange {
    _filterRange = filterRange;
}

@end
