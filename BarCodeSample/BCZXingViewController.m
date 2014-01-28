//
//  BCZXingViewController.m
//  BarCodeSample
//
//  Created by Hiroki Yoshifuji on 2014/01/27.
//  Copyright (c) 2014年 Hiroki Yoshifuji. All rights reserved.
//

#import "BCZXingViewController.h"
#import "ZXingObjC.h"

@interface BCZXingViewController () <ZXCaptureDelegate>
@property (nonatomic) ZXCapture* capture;
@end

@implementation BCZXingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
    [self.view addSubview:v];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.rotation = 90.0f;
    
    // Use the back camera
    self.capture.camera = self.capture.back;
    
    self.capture.layer.frame = v.bounds;
    
    [v.layer addSublayer:self.capture.layer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    
    // run the reader when the view is visible

    self.capture.delegate = self;
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear:animated];
    self.capture.delegate = nil;
}

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result
{
    if (result) {
        // We got a result. Display information about the result onscreen.
        NSLog(@"result:%@", result);

    }
}

@end
