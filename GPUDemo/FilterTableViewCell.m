//
//  FilterTableViewCell.m
//  GPUDemo
//
//  Created by Darcy on 16/6/1.
//  Copyright © 2016年 Darcy. All rights reserved.
//

#import "FilterTableViewCell.h"

@implementation FilterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)sliderValueChaged:(id)sender {
  
    self.filterModel.progress = self.slider.value;
    self.progressLabel.text = [NSString stringWithFormat:@"%0.2f",self.filterModel.progress];
    
    if (self.block) {
        self.block();
    }
}

@end
