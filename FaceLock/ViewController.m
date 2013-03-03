//
//  ViewController.m
//  FaceLock
//
//  Created by Diogo Carneiro on 03/03/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize image;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self correctImage:[UIImage imageNamed:@"natalie"]];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self cleaup];
}

- (void)correctImage:(UIImage *)camImage{
	[self cleaup];
	
	image = camImage;
	
	CGFloat maxWidth = 320;
	CGFloat maxHeight = 548;
	CGFloat newWidth = image.size.width;
	CGFloat newHeight = image.size.height;
	scale = 1;
	
	
//	image = [UIImage imageNamed:@"natalie"];
	
	if (image.size.width > maxWidth || image.size.height > maxHeight) {
		if (image.size.width > image.size.height) {
			NSLog(@"1 - %f x %f", image.size.width, image.size.height);
			scale = image.size.width / maxWidth;
			newWidth = maxWidth;
			newHeight = image.size.height / scale;
			
			if (newHeight > maxHeight) {
				scale = newHeight / maxHeight;
				newHeight = maxHeight;
				newWidth = newWidth / scale;
			}
		}else{
			NSLog(@"2 - %f x %f", image.size.width, image.size.height);
			scale = image.size.height / maxHeight;
			newHeight = maxHeight;
			newWidth = image.size.width / scale;
			
			if (newWidth > maxWidth) {
				NSLog(@"%f",scale);
				scale = newWidth / maxWidth;
				NSLog(@"%f",scale);
				newWidth = maxWidth;
				newHeight = newHeight / scale;
			}
		}
	}
	
	self.imageView.frame = CGRectMake(0, 0, newWidth, newHeight);
	
	NSLog(@"3 - %f x %f | s: %f", newWidth, newHeight, scale);
	
	[self.imageView setImage:image];
}

- (IBAction)openImage:(id)sender{
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	UIButton *button = (UIButton *)sender;
	
	if (button.tag == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}else{
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	
	[self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	[self correctImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)faceDetection{
	CIContext *context = [CIContext contextWithOptions:nil]; // 1
	NSDictionary  *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
													  forKey:CIDetectorAccuracy]; // 2
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
											  context:context
											  options:opts]; // 3
	
	CIImage *ciImage = [[CIImage alloc] initWithImage:image];
	
//	[self.imageView setTransform:CGAffineTransformMakeScale(1, -1)];
	[[self containerView] setTransform:CGAffineTransformMakeScale(1, -1)];
	
	[self.containerView setFrame:self.imageView.frame];
	
	NSArray *features = [detector featuresInImage:ciImage options:nil];
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		
		NSLog(@"%d", [features count]);
		
		for (CIFaceFeature *f in features){
			NSLog(@"%f %f", f.leftEyePosition.x/scale, f.leftEyePosition.y/scale);
			NSLog(@"%f %f", f.rightEyePosition.x/scale, f.rightEyePosition.y/scale);
			NSLog(@"%f %f", f.mouthPosition.x/scale, f.mouthPosition.y/scale);
			
			UIView *face = [[UIView alloc] initWithFrame:CGRectMake(f.bounds.origin.x/scale, f.bounds.origin.y/scale, f.bounds.size.width/scale, f.bounds.size.height/scale)];
			face.backgroundColor = [UIColor redColor];
			face.alpha = 0.3;
			face.tag = 1;
			[[self containerView] addSubview:face];
			
			UIView *lEye = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
			lEye.backgroundColor = [UIColor greenColor];
			lEye.alpha = 0.5;
			lEye.center = CGPointMake(f.leftEyePosition.x/scale, f.leftEyePosition.y/scale);
			lEye.tag = 2;
			[[self containerView] addSubview:lEye];
			
			UIView *rEye = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
			rEye.backgroundColor = [UIColor greenColor];
			rEye.alpha = 0.5;
			rEye.center = CGPointMake(f.rightEyePosition.x/scale, f.rightEyePosition.y/scale);
			rEye.tag = 3;
			[[self containerView] addSubview:rEye];
			
			UIView *mouth = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
			mouth.backgroundColor = [UIColor greenColor];
			mouth.alpha = 0.5;
			mouth.center = CGPointMake(f.mouthPosition.x/scale, f.mouthPosition.y/scale);
			mouth.tag = 4;
			[[self containerView] addSubview:mouth];
		}
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		
		if ([features count] < 1) {
			[self faceNotFoud];
		}
	});
	
}

- (void)cleaup{
	[[[self containerView] viewWithTag:1] removeFromSuperview];
	[[[self containerView] viewWithTag:2] removeFromSuperview];
	[[[self containerView] viewWithTag:3] removeFromSuperview];
	[[[self containerView] viewWithTag:4] removeFromSuperview];
}

- (IBAction)searchFace:(id)sender{
	[self cleaup];
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kidin"]];
	hud.labelText = @"guenta aí";
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self faceDetection];
	});
}

- (void)faceNotFoud{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"okay"]];
	hud.labelText = @"achei nada não";
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			sleep(1);
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		});
	});
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setImageView:nil];
	[self setContainerView:nil];
	[super viewDidUnload];
}
@end
