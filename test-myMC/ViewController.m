//
//  ViewController.m
//  test-myMC
//
//  Created by Don Miller on 3/8/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;

@property (weak, nonatomic) IBOutlet UISwitch *connectSwitch;
@property (weak, nonatomic) IBOutlet UIButton *browseButton;

@property (nonatomic,assign)BOOL isMaster;
@property (nonatomic,assign)BOOL doConnect;

//@property (nonatomic,assign)BOOL isAdvertising;

@property (nonatomic,strong)NSMutableArray *connectedPeerNames;

@property(nonatomic,strong) ConnectivityManager *connectManager;

@property(nonatomic,strong)IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.connectedPeerNames = [@[] mutableCopy];
    [self.connectSwitch setOn:self.doConnect];
    self.browseButton.hidden = YES;
    
    // need to set this for what it currently is from defaults
    self.isMaster = YES;
    [self updateConnectLabelForMode:self.isMaster];
    
    self.connectManager = [[ConnectivityManager alloc] init];
    [self.connectManager setDelegate:self];
    
    
}


- (void)resetPeers {
    //[self.connectManager disconnectAllPeers];
    [self.connectedPeerNames removeAllObjects]; // = self.connectManager.connectedconnectedPeerNames;
    [self.tableView reloadData];
}


- (void)updateConnectLabelForMode:(BOOL)mode {
    self.connectLabel.text = mode ? NSLocalizedString(@"Connect to Remote Devices",@"") : NSLocalizedString(@"Connect to Controller",@"");
}


- (IBAction)segmentAction:(UISegmentedControl *)sender {
    
    [self resetPeers];
    
    self.isMaster = (sender.selectedSegmentIndex == 0);
    [self updateConnectLabelForMode:self.isMaster];
    
    [self.connectSwitch setOn:NO];
}


- (void)displayBrowser {
    MCBrowserViewController *vc = [self.connectManager browserVC];
    [vc setDelegate:self];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)browseButtonAction:(id)sender {
    [self displayBrowser];
}


- (IBAction)connectSwitchAction:(UISwitch *)sender {
    
    self.doConnect = [sender isOn];
    
    // either way, start over
//    [self resetPeers];
    
    if (self.doConnect) {
        
        // it was off, so fire off either the browser or start advertising
        if (self.isMaster) {
            // show the browser
            [self displayBrowser];
            
            
        } else {
            // advertise the slave
            [self.connectManager advertiseSelf:YES];
            //self.isAdvertising = YES;
        }
        
    } else { // it was on but now disconnect
        
        // this should disconnect it self from ALL peers?????
        // and they should all get messages?????
        
        
        if (self.isMaster) {
            
            // this should disconnect it self from ALL peers?????
            // and they should all get messages?????
            [self.connectManager disconnectAllPeers];
            
            self.browseButton.hidden = YES;
            
            // dismiss the browser (IF it is around)
            [self dismissViewControllerAnimated:YES completion:nil];
            
            // disconnect all remotes connected to this controller
            //[self.connectManager disconnectAllPeers];
            
        } else {
            // stop advertising the slave
            if (self.connectManager.isAdvertising) {
                [self.connectManager advertiseSelf:NO];
            }
            
            [self.connectManager disconnectFromSession];
        }
    }
}



#pragma mark ConnectivityManager Delegate Methods

// this is a proxy for change in state disconnected vs. connecting
- (void)connectionStateDidConnect:(BOOL)didConnect withPeerID:(MCPeerID *)peerID {
    
    NSLog(@"connectionStateDidConnect: %@  didConnect: %@", peerID.displayName, didConnect ? @"YES" : @"NO");
    
    
    if (didConnect) {
        // for the master, this might be many names
        // for the slave, this is ONLY the controller I hope ?????????
        [self.connectedPeerNames addObject:peerID.displayName];
        
        if (self.isMaster) {
            self.browseButton.hidden = NO;
        }
        
    } else {
        
        [self.connectedPeerNames removeObject:peerID.displayName];
        
        // master/browser may have mutiple slaves/advertisers
        // even after one or all are removed
        // an advertiser can only have one, and once there are no connections
        // it will have to readvertise to connect
        // BUT it's OK for the browser to to still be browsing with NO clients
        
        if (!self.isMaster && ([self.connectedPeerNames count] == 0)) { // an advertiser could have only had ONE connected peer
            [self.connectSwitch setOn: NO];
        }
    }
    

    [self.tableView reloadData];
}


- (void)didReceiveMessageWithKey:(NSString *)key value:(id)value {
    // now decide what to do
}


// this is called when the master disconnects with all its peers
- (void)peerDidDisconnect:(MCPeerID *)peerID {
    
    NSLog(@"peerDidDisconnect: %@", peerID.displayName);
    
}


#pragma mark MCBrowserViewControllerDelegate methods

// these are only for the master which is the only one that does the browsing

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    // the connect switch should still be on
    // as well as the list of peers
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // can initiate sending data at this point
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //self.doConnect = NO;
    //[self.connectSwitch setOn:NO];
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.isMaster ? NSLocalizedString(@"Connected Remotes",@"") : NSLocalizedString(@"Controller",@"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return  [self.connectedPeerNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.connectedPeerNames objectAtIndex:indexPath.row];
    
    return cell;
}

@end
