//
//  ChatViewController.m
//  parseExample
//
//  Created by Gildardo Banuelos on 7/6/21.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ChatViewController

- (IBAction)onClickSend:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_FBU2021"];
    chatMessage[@"text"] = self.chatMessageField.text;
    chatMessage[@"user"] = PFUser.currentUser;
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
            self.chatMessageField.text = @"";
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
}

- (void)onTimer{
    PFQuery *query = [PFQuery queryWithClassName:@"Message_FBU2021"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.arrayOfMessages = posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
    // Do any additional setup after loading the view.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];

    NSDictionary *msg = self.arrayOfMessages[indexPath.row];
    cell.msgLabel.text = msg[@"text"];
    
    PFUser *user = msg[@"user"];
    if (user != nil) {
        // User found! update username label with username
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    } else {
        // No user found, set default username
        cell.usernameLabel.text = @"@Default Name";
    }
    

    return cell;
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
