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
        
        
        switch (i) {
            case 0:
            case 3:
            case 4:
            
            {
                filterModel.progress = 0;
            }
                break;
                
            default: {
                filterModel.progress = 1;
            }
                break;
        }
        
    }
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
    
    NSLock *lock  = [[NSLock alloc]init];
    [lock lock];
    
    UIImage *inputImage = [self.originImage copy];
    for (int i = 0 ; i < self.filtersInPut.count; i ++) {
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
        GPUImageFilter *filter = [self resetFilter:i];
        [stillImageSource addTarget:(GPUImageFilter *)filter];
        [stillImageSource processImage];
        [(GPUImageFilter *)filter useNextFrameForImageCapture];
        inputImage = [(GPUImageFilter *)filter imageFromCurrentFramebuffer];
    }
    
    if (compeletionBlock) {
        compeletionBlock(inputImage);
    }
    
    [lock unlock];
}

- (void)procecessImage:(NSInteger)idx {
    
    static BOOL hasLoad = NO;
    if (hasLoad == NO) {
        [self imageForProcess:^(UIImage *image) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
            
        } withIndex:idx];
    }
//
//    if (!self.processQueue) {
////        dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
//        self.processQueue = dispatch_get_main_queue();
//    }
    
//    if (!hasLoad) {
//        hasLoad = YES;
//    }
//    else {
//        return;
//    }
//    
//    __weak typeof(self) weakSelf = self;
//    self.processedImage = self.originImage;
//    for (FilterModel *filterModel in weakSelf.filters) {
//
//            GPUImageFilter *filter = [self resetFilter:[weakSelf.filters indexOfObject:filterModel]];
//            [filter forceProcessingAtSize:self.processedImage.size];
//
//            GPUImagePicture  * staticPictureOne = [[GPUImagePicture alloc] initWithImage:weakSelf.processedImage];
//            [filterModel.filter forceProcessingAtSize:self.processedImage.size];
//            [staticPictureOne addTarget:filter];
//            [staticPictureOne processImage];
//            [staticPictureOne useNextFrameForImageCapture];
//            weakSelf.processedImage = filter.imageFromCurrentFramebuffer;
//            [staticPictureOne removeTarget:filter];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//           
//            weakSelf.imageView.image = weakSelf.processedImage;
//        });
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
    cell.filterNameLabel.text = [filterModel.filterName substringWithRange:NSMakeRange(8, filterModel.filterName.length - 14)];
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
