//
//  ComposeViewController.m
//  twitter
//
//  Created by Benjamin Charles Hora on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)publish:(id)sender {
    [[APIManager shared] postStatusWithText:self.NewTweet.text completion:^(Tweet * tweet, NSError * error) {
        if (tweet){
            NSLog(@"Compose Tweet Success!");
            [self.delegate didTweet:tweet];
        }
        else {
            NSLog(@"Error composing Tweet: %@", error.localizedDescription);

        }
        [self dismissViewControllerAnimated:true completion:nil];

    }];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
