//
//  FilterModel.h
//  GPUDemo
//
//  Created by Darcy on 16/6/1.
//  Copyright © 2016年 Darcy. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GPUImage.h"

typedef struct FilterRange FilterRange;

struct FilterRange {
    float min ;
    float max;
};

FilterRange  FilterRangeMake(float min ,float max ) {
    
    FilterRange range;
    range.min = min;
    range.max = max;
    return range;
};

@interface FilterModel : NSObject

@property (nonatomic ,copy) NSString *filterName;

@property (nonatomic ,assign) FilterRange filterRange;

@property (nonatomic ,assign) float progress;

@property (nonatomic ,strong) GPUImageFilter *filter ;

@end
