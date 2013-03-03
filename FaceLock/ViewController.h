//
//  ViewController.h
//  FaceLock
//
//  Created by Diogo Carneiro on 03/03/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
	CGFloat scale;
	UIImagePickerController *imagePicker;
}

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)searchFace:(id)sender;
- (IBAction)openImage:(id)sender;

@end
