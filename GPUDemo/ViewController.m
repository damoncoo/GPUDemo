//
//  ViewController.m
//  GPUDemo
//
//  Created by Darcy on 16/6/1.
//  Copyright © 2016年 Darcy. All rights reserved.
//

#import "ViewController.h"
#import "FilterTableViewCell.h"

@interface ViewController ()< UITableViewDelegate , UITableViewDataSource >

@property (weak, nonatomic) IBOutlet UITableView *filterTableView;

@property (strong, nonatomic)  dispatch_queue_t processQueue;

@property (nonatomic ,copy) UIImage *originImage;

@property (nonatomic ,strong) UIImage *processedImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *filters;

@property (strong, nonatomic) NSMutableArray *filtersInPut;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originImage = [UIImage imageNamed:@"test.jpg"];
    self.imageView.image = self.originImage;
    NSArray *filters =   [@[
                              @"GPUImageBrightnessFilter",
                              @"GPUImageContrastFilter",
                              @"GPUImageSaturationFilter",
                              @"GPUImageHighlightShadowFilter",
                              @"GPUImageSharpenFilter"
                           ] mutableCopy];
    
    self.filters = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < filters.count; i ++) {
        FilterModel *filterModel = [[FilterModel alloc]init];
        filterModel.filterName = [filters objectAtIndex:i];
        Class class = NSClassFromString( filterModel.filterName);
        GPUImageFilter *filter = (GPUImageFilter *)[[class alloc]init];
        filterModel.filter = filter;
        [self.filters addObject:filterModel];
        
        if (i == 0) {
            [(GPUImageBrightnessFilter *)filter setBrightness:1];
        }
        if (i == 1) {
            [(GPUImageContrastFilter *)filter setContrast:4];
        }
        else if (i == 2) {
            [(GPUImageSaturationFilter *)filter setSaturation:1];
        }
        else if (i == 3) {
            [(GPUImageHighlightShadowFilter *)filter setShadows:1];
        }
        else if (i == 4) {
            [(GPUImageSharpenFilter *)filter setSharpness:4];
        }
    }
    
    self.filtersInPut = [NSMutableArray arrayWithCapacity:0];
    for (FilterModel *filterModel in self.filters) {
        [self.filtersInPut addObject:filterModel.filter];
    }
    
    [self.filterTableView registerNib:[UINib nibWithNibName:@"FilterTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Filter"];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)imageForProcess:(void (^)(UIImage *image ))compeletionBlock {
    
    
    
}

- (void)procecessImage {
    
    static BOOL hasLoad = NO;
    if (hasLoad == NO) {
        hasLoad = YES;
        
        [self imageForProcess:^(UIImage *image) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
            
        }];
    }
    
    if (!self.processQueue) {
        self.processQueue = dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.processQueue, ^{
        
        GPUImagePicture  * staticPictureOne = [[GPUImagePicture alloc] initWithImage:weakSelf.originImage];
        
        for (FilterModel *filterModel in weakSelf.filters) {
            [filterModel.filter forceProcessingAtSize:self.originImage.size];
            [staticPictureOne addTarget:filterModel.filter];
            [staticPictureOne processImage];
            [staticPictureOne useNextFrameForImageCapture];
            [staticPictureOne removeTarget:filterModel.filter];
        }

//        [staticPictureOne processImage];
        weakSelf.processedImage = staticPictureOne.imageFromCurrentFramebuffer;
        
//        GPUImageView *view = [[GPUImageView alloc]initWithFrame:CGRectZero];
//        
//      
//        GPUImageFilterPipeline  *pipelineOne  = [[GPUImageFilterPipeline alloc]
//                                                 initWithOrderedFilters:[self allFilters:view]
//                                                 input:staticPictureOne
//                                                 output:(GPUImageView *)view];
//        
//        [staticPictureOne processImage];
//        weakSelf.processedImage =  [[pipelineOne currentFilteredFrame] copy];
//        
//        [staticPictureOne removeAllTargets];
//        [pipelineOne removeAllFilters];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            weakSelf.imageView.image = weakSelf.processedImage;
        });
    });
}


#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FilterModel *filterModel = [self.filters objectAtIndex:indexPath.row];
    FilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Filter"];
    cell.filterModel = filterModel;
    cell.slider.minimumValue = filterModel.filterRange.min;
    cell.slider.maximumValue = filterModel.filterRange.max;
    cell.slider.value = filterModel.progress;
    cell.progressLabel.text = [NSString stringWithFormat:@"%0.2f",filterModel.progress];
    cell.minLabel.text = [NSString stringWithFormat:@"%0.2f",filterModel.filterRange.min];
    cell.maxLabel.text = [NSString stringWithFormat:@"%0.2f",filterModel.filterRange.max];
    cell.filterNameLabel.text = filterModel.filterName;
    cell.block =^(void){
        
        [self procecessImage];
    };
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filters.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 140;
}

@end
