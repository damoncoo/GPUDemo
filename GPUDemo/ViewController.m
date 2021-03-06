//
//  ViewController.m
//  GPUDemo
//
//  Created by Darcy on 16/6/1.
//  Copyright © 2016年 Darcy. All rights reserved.
//

#import "ViewController.h"
#import "FilterTableViewCell.h"
#import "UIView+Tap.h"
#import "GPUDemo-Swift.h"

@interface ViewController ()< UITableViewDelegate , UITableViewDataSource , UINavigationControllerDelegate, UIImagePickerControllerDelegate >

@property (weak, nonatomic) IBOutlet UITableView *filterTableView;

@property (strong, nonatomic)  dispatch_queue_t processQueue;

@property (nonatomic ,copy) UIImage *originImage;

@property (nonatomic ,strong) UIImage *processedImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *filters;

@property (strong, nonatomic) NSMutableArray *filtersInPut;

@property (strong, nonatomic) NSLock *lock;

@property (nonatomic ,strong) GPUImagePicture *stillImagePicture;

@property (nonatomic ,weak) GPUImageFilter *filterTemp ;

@end

@implementation ViewController

#pragma mark - UIImagePicker Controller Delegate 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo  {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.originImage = self.processedImage = [image copy];
    self.imageView.image = [self.processedImage copy];
    [self reintialStillImagePicture];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.originImage = [UIImage imageNamed:@"test.jpg"];
    self.processedImage = [self.originImage copy];
    self.imageView.image = self.originImage;
    
    [self.imageView handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
       
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.allowsEditing = YES;
        controller.delegate = self;
        [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        
    }];

    [self.filterTableView registerNib:[UINib nibWithNibName:@"FilterTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Filter"];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 44, 24);
    [rightButton addTarget:self action:@selector(didButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.backgroundColor = [UIColor purpleColor];
    [rightButton setTitle:@"生成" forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    [self reintialStillImagePicture];
    
}

- (void)didButtonClicked:(id)sender {

    [self imageForProcess:^(UIImage *image) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
        
    } withIndex:0];
    
    WebViewController *web = [[WebViewController alloc]init];
    [self presentViewController:web animated:YES completion:NULL];
}

- (void)reintialStillImagePicture {
    
    NSArray *filters =   [@[
                            @"GPUImageBrightnessFilter",//0
                            @"GPUImageContrastFilter",//1
                            @"GPUImageSaturationFilter",//2
                            @"GPUImageHighlightShadowFilter",//3
                            @"GPUImageHighlightShadowFilter",//4
                            @"GPUImageSharpenFilter",//5
                            @"GPUImageExposureFilter",//6
                            @"GPUImageRGBFilter",//7         0 - 1
                            @"GPUImageRGBFilter",//8
                            @"GPUImageRGBFilter",//9
                            @"GPUImageWhiteBalanceFilter",//10白平衡，色温
                            @"GPUImageVignetteFilter",//晕影 11
                            @"GPUImageSepiaFilter",//12  默认 1  ， 0 - 4
                            @"GPUImageLevelsFilter",//13
                            @"GPUImageGrayscaleFilter",//14
                            @"GPUImageToneCurveFilter",//15
                            @"GPUImageAverageLuminanceThresholdFilter",// 16 默认 1.0  0 - 4
                            @"GPUImageLowPassFilter" // 17  默认 0.5  0 - 1
                            ] mutableCopy];
    
    FilterRange range1 = FilterRangeMake(0,1);
    FilterRange range2 = FilterRangeMake(0,4.0);
    FilterRange range3 = FilterRangeMake(0,2.0);
    FilterRange range4 = FilterRangeMake(-4.0,4.0);
    FilterRange range5 = FilterRangeMake(-1.0,1.0);
    FilterRange range6 = FilterRangeMake(-10.0,10.0);
    FilterRange range7 = FilterRangeMake(1000,10000);
    
    self.filters = [NSMutableArray arrayWithCapacity:0];
    self.filtersInPut = [NSMutableArray arrayWithCapacity:0];
    self.stillImagePicture = [[GPUImagePicture alloc]initWithImage:self.originImage
                                               smoothlyScaleOutput:YES];
    for (int i = 0; i < filters.count; i ++) {
        FilterModel *filterModel = [[FilterModel alloc]init];
        filterModel.filterName = [filters objectAtIndex:i];
        Class class = NSClassFromString( filterModel.filterName);
        GPUImageFilter *filter = (GPUImageFilter *)[[class alloc]init];
        filterModel.filter = filter;
        [self.filters addObject:filterModel];
        [self.filtersInPut addObject:filter];
        
        switch (i) {
            case 0:  {
                filterModel.filterRange = range5;
            }
                break;
            case 1:
            case 7:
            case 8:
            case 9:
            case 12:
            case 16:  {
                filterModel.filterRange = range2;
            }
                break;
            case 2:  {
                filterModel.filterRange = range3;
            }
                break;
            case 3:
            case 4:
            case 17:  {
                filterModel.filterRange = range1;
            }
                break;
            case 5:  {
                filterModel.filterRange = range4;
            }
                break;
            case 6: {
                filterModel.filterRange = range6;
            }
                break;
            case 10: {
                filterModel.filterRange = range7;
            }
                break;
            default:
                break;
        }
        
        switch (i) {
            case 0:
            case 3:
            case 4:
            case 5:
            case 6:  {
                filterModel.progress = 0;
            }
                break;
            case 10: {
                filterModel.progress = 5000;
            }
                break;
            case 17: {
                filterModel.progress = 0.5;
            }
                break;
            default: {
                filterModel.progress = 1;
            }
                break;
        }
    }
    [self.filterTableView reloadData];
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
        [(GPUImageHighlightShadowFilter *)filter setHighlights:value];
    }
    else if (i == 4) {
        [(GPUImageHighlightShadowFilter *)filter setShadows:value];
    }
    else if (i == 5) {
        [(GPUImageSharpenFilter *)filter setSharpness:value];
    }
    else if (i == 6) {
        [(GPUImageExposureFilter *)filter setExposure:value];
    }
    else if(i == 7 ) {
        [(GPUImageRGBFilter *)filter setRed:value];
    }
    else if(i == 8 ) {
        [(GPUImageRGBFilter *)filter setGreen:value];
    }
    else if(i == 9 ) {
        [(GPUImageRGBFilter *)filter setBlue:value];
    }
    else if(i == 10 ) {
        [(GPUImageWhiteBalanceFilter *)filter setTemperature:value];
    }
    else if(i == 11 ) {
//        return nil;
    }
    else if(i == 12 ) {
        [(GPUImageSepiaFilter *)filter setIntensity:value];
//        return nil;
    }
    else if(i == 13 ) {
//        GPUImageLevelsFilter
//        return nil;
    }
    else if(i == 14 ) {
//        GPUImageGrayscaleFilter
//        return nil;
    }
    else if(i == 15 ) {
//        GPUImageGrayscaleFilter
//        return nil;
    }
    else if(i == 16 ) {
        [(GPUImageAverageLuminanceThresholdFilter *)filter setThresholdMultiplier:value];
//        return nil;
    }
    else if(i == 17 ) {
        [(GPUImageLowPassFilter *)filter setFilterStrength:value];
    }
    return filter;
}


- (void)imageForProcess:(void (^)(UIImage *image ))compeletionBlock withIndex:(NSInteger)idx {
    
    static NSInteger time = 0;
    time ++;
    NSLog(@"第%zi次执行",time);
    
    static  BOOL isProcessing = NO;
    if (isProcessing) {
        return;
    }
    isProcessing = YES;
    
    static NSInteger timeExcuting = 0;
    timeExcuting ++;
    NSLog(@"第%zi次执行",timeExcuting);

    
    [self.stillImagePicture removeAllTargets];
    for (int i = 0 ; i < self.filtersInPut.count; i ++) {
        GPUImageFilter *filter =  [self resetFilter:i];
        [filter removeAllTargets];
        
        if (i == 0 ) {
            self.filterTemp = filter;
            [self.stillImagePicture addTarget:filter];
            [filter useNextFrameForImageCapture];
        }
        else {
            if (i == 12  || i == 14 ||  i == 16 || i == 17 || i == 11) {
                continue;
            }
            [self.filterTemp addTarget:filter];
            [filter useNextFrameForImageCapture];
            self.filterTemp = filter;
        }
    }
    
    [self.stillImagePicture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.processedImage = self.filterTemp.imageFromCurrentFramebuffer;
            if (compeletionBlock) {
                compeletionBlock(self.processedImage);
            }
            isProcessing = NO;
        });
    }];
}

- (void)procecessImage:(NSInteger)idx {
    
    static BOOL hasLoad = NO;
    if (hasLoad == NO) {
        [self imageForProcess:^(UIImage *image) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [image copy];
            });
            
        } withIndex:idx];
    }
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
