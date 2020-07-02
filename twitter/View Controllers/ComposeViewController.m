//
//  ComposeViewController.m
//  twitter
//
//  Created by Benjamin Charles Hora on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *handle;
@property (weak, nonatomic) IBOutlet UILabel *charCount;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.NewTweet.delegate = self;
    
    // Check if this tweet is a reply or
    if (self.reply == NO) {
        [[APIManager shared] getCurrUser:^(User *user, NSError *error){
            if (user) {
                // Set image
                NSString *stringURL = [user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                NSURL *imageURL = [NSURL URLWithString: stringURL];
                [self.profileImage setImageWithURL: imageURL];
                self.name.text = user.name;
                self.handle.text = [NSString stringWithFormat:@"%@%@", @"@", user.screenName];
            } else {
                NSLog(@"😫😫😫 Error getting user: %@", error.localizedDescription);
            }
        }];
    }
    else {
        User *user = self.tweet.user;
        // Set image
        NSString *stringURL = [user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        NSURL *imageURL = [NSURL URLWithString: stringURL];
        [self.profileImage setImageWithURL: imageURL];
        self.name.text = user.name;
        self.handle.text = [NSString stringWithFormat:@"%@%@", @"@", user.screenName];
        self.NewTweet.text =[NSString stringWithFormat:@"%@%@", @"@", user.screenName];
        [self updateCount];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateCount];
}

- (IBAction)publish:(id)sender {
    if (self.reply == NO) {
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
    else {
        [[APIManager shared]replyStatusWithText:self.tweet.idStr text:self.NewTweet.text completion:^(Tweet *tweet, NSError *error) {
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
}

-(void)updateCount {
    int currLength = (280 - ((int) [self.NewTweet.text length]));
    self.charCount.text = [NSString stringWithFormat:@"%@%d", @"Remaining Characters: ", currLength];
}

- (IBAction)close:(id)sender {
    if (self.reply == YES) {
        self.tweet.replyClicked = NO;
    }
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
