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

@property (strong, nonatomic) GPUImagePicture *imagePicture;

@property (weak, nonatomic) GPUImageFilter *finalFilter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.originImage = [UIImage imageNamed:@"test.jpg"];
    self.processedImage = [self.originImage copy];
    self.imageView.image = self.originImage;
    
    NSArray *filters =   [@[
                              @"GPUImageBrightnessFilter",
                              @"GPUImageContrastFilter",
                              @"GPUImageSaturationFilter",
                              @"GPUImageHighlightShadowFilter",
                              @"GPUImageSharpenFilter"
                              
                           ] mutableCopy];
    
    FilterRange range1 = FilterRangeMake(0,1);
    FilterRange range2 = FilterRangeMake(0,4.0);
    FilterRange range3 = FilterRangeMake(0,2.0);
    FilterRange range4 = FilterRangeMake(-4.0,4.0);
    FilterRange range5 = FilterRangeMake(-1.0,1.0);
    
    self.filters = [NSMutableArray arrayWithCapacity:0];
    self.filtersInPut = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < filters.count; i ++) {
        FilterModel *filterModel = [[FilterModel alloc]init];
        filterModel.filterName = [filters objectAtIndex:i];
        Class class = NSClassFromString( filterModel.filterName);
        GPUImageFilter *filter = (GPUImageFilter *)[[class alloc]init];
        filterModel.filter = filter;
        [self.filters addObject:filterModel];
        [self.filtersInPut addObject:filter];
        
        switch (i) {
            case 0:
            {
                filterModel.filterRange = range5;
            }
                break;
            case 1:
            {
                filterModel.filterRange = range2;
            }
                break;
            case 2:
            {
                filterModel.filterRange = range3;
            }
                break;
            case 3:
            {
                filterModel.filterRange = range5;
            }
                break;
            case 4:
            {
                filterModel.filterRange = range1;
            }
                break;
            case 5:
            {
                filterModel.filterRange = range4;
            }
                break;
            default:
                break;
        }
    }
    
    self.imagePicture = [[GPUImagePicture alloc]initWithImage:self.originImage];
    
//    GPUImageFilter *filter;
//    NSInteger idx = 0;
//    for (FilterModel *filterModel in self.filters) {
//        if (idx == 0) {
//            [self.imagePicture addTarget:filterModel.filter];
//            filter = filterModel.filter;
//        }
//        else {
//            [filter  addTarget: filterModel.filter];
//            if (idx == self.filters.count - 1) {
//                self.finalFilter = filterModel.filter;
//            }
//        }
//        
//        idx ++;
//        [self.filtersInPut addObject:filterModel.filter];
//    }
//    
    [self.filterTableView registerNib:[UINib nibWithNibName:@"FilterTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Filter"];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (GPUImageFilter *)resetFilter:(NSInteger)i  {
    
    FilterModel *filterModel = [self.filters objectAtIndex:i];
    GPUImageFilter *filter = filterModel.filter;
    CGFloat value = filterModel.progress;
    
    if (i == 0) {
        [(GPUImageBrightnessFilter *)filter setBrightness:value];
    }
    if (i == 1) {
        [(GPUImageContrastFilter *)filter setContrast:value];
    }
    else if (i == 2) {
        [(GPUImageSaturationFilter *)filter setSaturation:value];
    }
    else if (i == 3) {
        [(GPUImageHighlightShadowFilter *)filter setShadows:value];
    }
    else if (i == 4) {
        [(GPUImageSharpenFilter *)filter setSharpness:value];
    }
    return filter;
}


- (void)imageForProcess:(void (^)(UIImage *image ))compeletionBlock withIndex:(NSInteger)idx {
    
    GPUImageFilter *filter  = [self resetFilter:idx];
    [filter forceProcessingAtSize:self.originImage.size];

//    GPUImagePicture  * staticPictureOne = [[GPUImagePicture alloc] initWithImage:self.processedImage];
//    [staticPictureOne addTarget:filter];
//    [staticPictureOne processImage];
//    [filter useNextFrameForImageCapture];
    
    [self.imagePicture processImage];
     self.processedImage = self.imagePicture.imageFromCurrentFramebuffer;
    
    if (compeletionBlock) {
        compeletionBlock(self.processedImage);
    }
}

- (void)procecessImage:(NSInteger)idx {
    
//    static BOOL hasLoad = NO;
//    if (hasLoad == NO) {
//
//        [self imageForProcess:^(UIImage *image) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.imageView.image = image;
//            });
//            
//        } withIndex:idx];
//    }
    
    if (!self.processQueue) {
        self.processQueue = dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
    }
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.processQueue, ^{
        
        GPUImagePicture  * staticPictureOne = [[GPUImagePicture alloc] initWithImage:weakSelf.originImage];
        [staticPictureOne forceProcessingAtSize:self.originImage.size];

        for (FilterModel *filterModel in weakSelf.filters) {
            [filterModel.filter forceProcessingAtSize:self.originImage.size];
            [staticPictureOne addTarget:filterModel.filter];
//            [staticPictureOne useNextFrameForImageCapture];
            [staticPictureOne processImage];
            
            if (filterModel == self.filters.lastObject) {
                weakSelf.processedImage = filterModel.filter.imageFromCurrentFramebuffer;
            }
            [staticPictureOne removeTarget:filterModel.filter];

        }
        
    
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
        
        [self procecessImage:indexPath.row];
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
