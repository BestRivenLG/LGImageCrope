//
//  ViewController.m
//  图片编辑截取
//
//  Created by mac on 16/5/30.
//  Copyright © 2016年 ZnLG. All rights reserved.
//

#import "ViewController.h"
#import "ImageCropper.h"
#define ORIGINAL_MAX_WIDTH 640.0f

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)selectedAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选择", nil];
    
    
    [actionSheet showInView:self.view];


}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex   %lu",buttonIndex);
    if(buttonIndex == 0){
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        self.imagePicker.allowsEditing = YES;
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
        
    }else if(buttonIndex ==1)
    {
        //不支持相机，则使用照片裤作为图片选择器的数据源类型
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:^() {

    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //使用选择的照片
//    self.imageView.image = image;
    //    [[ImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    image = [self imageByScalingToMaxSize:image];
        
    // 裁剪  y 100
    CGFloat cropFrame_Y = (self.view.frame.size.height - self.view.frame.size.width)/2.0;
        
    ImageCropper *imageCropper = [[ImageCropper alloc] initWithImage:image cropFrame:CGRectMake(0, cropFrame_Y,self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageCropper];
    
    __weak typeof(ImageCropper *) weakImage = imageCropper;
    imageCropper.dismissBlock = ^{
        
//        ImageCropper *strongImage = weakImage;
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2.0;

        self.imageView.image = [weakImage getSubImage];
    };
        
    [self presentViewController:nav animated:NO completion:nil];
    //关闭从该视图控制器(self)弹出的以模态形式显示的视图控制器
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
