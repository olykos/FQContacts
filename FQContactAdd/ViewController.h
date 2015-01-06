//
//  ViewController.h
//  FQContactAdd
//
//  Created by Orestis Lykouropoulos on 1/1/15.
//  Copyright (c) 2015 Orestis Lykouropoulos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *facebookTextField;
@property (strong, nonatomic) IBOutlet UITextField *twitterTextField;
@property (strong, nonatomic) IBOutlet UITextField *linkedInTextField;


- (IBAction)addContactButtonPressed:(UIButton *)sender;
@end

