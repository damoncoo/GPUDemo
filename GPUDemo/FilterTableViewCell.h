//
//  FilterTableViewCell.h
//  GPUDemo
//
//  Created by Darcy on 16/6/1.
//  Copyright © 2016年 Darcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"

@interface FilterTableViewCell : UITableViewCell

- (IBAction)sliderValueChaged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property FilterModel *filterModel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end
