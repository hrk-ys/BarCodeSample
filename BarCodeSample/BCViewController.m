//
//  BCViewController.m
//  BarCodeSample
//
//  Created by Hiroki Yoshifuji on 2014/01/12.
//  Copyright (c) 2014年 Hiroki Yoshifuji. All rights reserved.
//

#import "BCViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface BCViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureDeviceInput *deviceInput;

@property (nonatomic, retain) UIView* rectView;

@property (nonatomic) BOOL enableCapture;
@property (nonatomic, retain) UIAlertView* alertView;


@property (nonatomic, retain) UIImageView* imageView;
@end

@implementation BCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.enableCapture = YES;
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = nil;
    AVCaptureDevicePosition camera = AVCaptureDevicePositionBack; // Back or Front
    for (AVCaptureDevice *d in devices) {
        device = d;
        if (d.position == camera) {
            break;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    [self.session addInput:input];
    
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    
    // QR コードのみ
    //output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 全部認識させたい場合
    // (
    // face,
    // "org.gs1.UPC-E",
    // "org.iso.Code39",
    // "org.iso.Code39Mod43",
    // "org.gs1.EAN-13",
    // "org.gs1.EAN-8",
    // "com.intermec.Code93",
    // "org.iso.Code128",
    // "org.iso.PDF417",
    // "org.iso.QRCode",
    // "org.iso.Aztec"
    // )
    output.metadataObjectTypes = output.availableMetadataObjectTypes;
    
    NSLog(@"%@", output.availableMetadataObjectTypes);
    NSLog(@"%@", output.metadataObjectTypes);
    
    [self.session startRunning];
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.frame = self.view.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:preview];

    self.rectView = [[UIView alloc] initWithFrame:CGRectZero];
    self.rectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.rectView];

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"----");
    if (! self.enableCapture) return;
    
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // 複数の QR があっても1度で読み取れている
            NSString *qrcode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", qrcode);
            self.rectView.frame = metadata.bounds;
            
            [self showAlertViewWithMessage:qrcode];

        }
        else if ([metadata.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            NSString *ean13 = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", ean13);
            self.rectView.frame = metadata.bounds;
            
            [self showAlertViewWithMessage:ean13];
        }
    }
}

- (void)showAlertViewWithMessage:(NSString*)message
{
    if (! self.enableCapture) return;
    
    // QRコード作成用のフィルターを作成・パラメータの初期化
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [ciFilter setDefaults];

    // 格納する文字列をNSData形式（UTF-8でエンコード）で用意して設定
    NSString *qrString = message;
    NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    [ciFilter setValue:data forKey:@"inputMessage"];
    
    // 誤り訂正レベルを「L（低い）」に設定
    [ciFilter setValue:@"L" forKey:@"inputCorrectionLevel"];

    // Core Imageコンテキストを取得したらCGImage→UIImageと変換して描画
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgimg =
    [ciContext createCGImage:[ciFilter outputImage]
                    fromRect:[[ciFilter outputImage] extent]];
    UIImage *image = [UIImage imageWithCGImage:cgimg scale:1.0f
                                   orientation:UIImageOrientationUp];
    CGImageRelease(cgimg);

    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.imageView addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        [self.view addSubview:self.imageView];
    }
    
    self.imageView.image = image;
    self.imageView.hidden = NO;
    
    self.enableCapture = NO;
}

- (void)tapImage:(id)sender
{
    self.imageView.hidden = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.enableCapture = YES;
}

@end
