//
//  ViewController.m
//  FQContactAdd
//
//  Created by Orestis Lykouropoulos on 1/1/15.
//  Copyright (c) 2015 Orestis Lykouropoulos. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //this is only for the keyboard to go away when I press enter
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.addressTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addContactButtonPressed:(UIButton *)sender {
    
    //first and last name are required + at least one of phone, email, address
    if ((![self.firstNameTextField.text isEqualToString:@""] &&
         ![self.lastNameTextField.text isEqualToString:@""]) && (![self.phoneTextField.text isEqualToString:@""] || ![self.emailTextField.text isEqualToString:@""] || ![self.addressTextField.text isEqualToString:@""])) {
        
        //can't add contact alert
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
            NSLog(@"Denied");
            [cantAddContactAlert show];
            
        } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            NSLog(@"Authorized");
            [self addToContacts];
            
        } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
            NSLog(@"Not determined");
            ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                if (!granted){
                    NSLog(@"Just denied");
                    [cantAddContactAlert show];
                    return;
                }
                NSLog(@"Just authorized");
                [self addContactButtonPressed:sender];
            });
        }
    } else {
        NSLog(@"else - improve actions later");
    }
}


- (void)addToContacts{
    
    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABRecordRef newPerson = ABPersonCreate();
    
    //name
    CFErrorRef firstNameError = NULL;
    bool didSetFirstName = ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFStringRef)self.firstNameTextField.text, &firstNameError);
    if (!didSetFirstName) {
        NSLog(@"error setting first name record value");
        /* Handle error here. */}
    
    CFErrorRef lastNameError = NULL;
    bool didSetLastName = ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFStringRef)self.lastNameTextField.text, &lastNameError);
    if (!didSetLastName) {
        NSLog(@"error setting  last name record value");
        /* Handle error here. */}
    
    //phone
    if (![self.phoneTextField.text isEqualToString:@""]){
        ABMutableMultiValueRef phoneMulti =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneMulti ,(__bridge CFStringRef)self.phoneTextField.text,kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty,  phoneMulti, nil);
    }
    
    // email
    if (![self.emailTextField.text isEqualToString:@""]){
        
        ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMulti, (__bridge CFStringRef) self.emailTextField.text, kABWorkLabel, NULL);
        
        ABRecordSetValue(newPerson, kABPersonEmailProperty, emailMulti, nil);
    }
    
    
    
    
    // Adress - I haven't yet included all the parts of an address - but I don't think Fliq needs addresses anyway
    if (![self.addressTextField.text isEqualToString:@""]){
        ABMutableMultiValueRef addressMulti = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
        
        ABMultiValueAddValueAndLabel(addressMulti, (__bridge CFDictionaryRef) addressDictionary, kABHomeLabel, NULL);
        
        ABRecordSetValue(newPerson, kABPersonAddressProperty, addressMulti, nil);
    }
    
    //social
    if (![self.facebookTextField.text isEqualToString:@""] || ![self.twitterTextField.text isEqualToString:@""] || ![self.linkedInTextField.text isEqualToString:@""]) {
        
        ABMultiValueRef socialMulti = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        
        //facebook
        if (![self.facebookTextField.text isEqualToString:@""]){
            ABMultiValueAddValueAndLabel(socialMulti, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:(NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey, self.facebookTextField.text, kABPersonSocialProfileUsernameKey,nil]), kABPersonSocialProfileServiceFacebook, NULL);
        }
        
        //twitter
        if (![self.twitterTextField.text isEqualToString:@""]) {
            
            ABMultiValueAddValueAndLabel(socialMulti, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:(NSString *)kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceKey, self.twitterTextField.text, kABPersonSocialProfileUsernameKey,nil]), kABPersonSocialProfileServiceTwitter, NULL);
        }
        
        //linkedIn
        if (![self.linkedInTextField.text isEqualToString:@""]) {
            
            ABMultiValueAddValueAndLabel(socialMulti, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:(NSString *)kABPersonSocialProfileServiceLinkedIn, kABPersonSocialProfileServiceKey, self.linkedInTextField.text, kABPersonSocialProfileUsernameKey,nil]), kABPersonSocialProfileServiceLinkedIn, NULL);
        }
        
        ABRecordSetValue(newPerson, kABPersonSocialProfileProperty, socialMulti, NULL);
    }
    
    
    //save
    ABAddressBookAddRecord(addressBook, newPerson, nil);
    if (ABAddressBookSave(addressBook, nil)) {
        NSLog(@"Saved successfuly");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Contact added succesfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    } else {
        NSLog(@"Error saving person to AddressBook");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error adding contact" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [self.view endEditing:YES];
    return YES;
}

@end
