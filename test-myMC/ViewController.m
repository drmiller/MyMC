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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *advertisingActivityIndicator;


@property (nonatomic,assign)BOOL isMaster; // segmented control
@property (nonatomic,assign)BOOL doConnect; // switch

@property (nonatomic,assign)BOOL isAdvertising;
@property (nonatomic,assign)BOOL isBrowsing;

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
    [self updateConnectUI];
    
    self.connectManager = [[ConnectivityManager alloc] init];
    [self.connectManager setDelegate:self];
    
    
}


- (void)resetPeers {
    //[self.connectManager disconnectAllPeers];
    [self.connectedPeerNames removeAllObjects]; // = self.connectManager.connectedconnectedPeerNames;
    [self.tableView reloadData];
}


- (void)updateConnectUI {
    
    NSString *labelText;
    
    self.advertisingActivityIndicator.hidden = YES;
    
    if (self.isMaster) {
        labelText =  self.isBrowsing ? NSLocalizedString(@"Trying to find slaves...",@"") : NSLocalizedString(@"Connect to Remote Devices",@"");
        
        self.browseButton.hidden = !self.connectSwitch.isOn;
    } else {
        
        self.browseButton.hidden = YES;
        
        self.advertisingActivityIndicator.hidden = !self.isAdvertising;
        
        if (self.isAdvertising) {
            labelText = NSLocalizedString(@"Advertising self to master...",@"");
            [self.advertisingActivityIndicator startAnimating];
        } else {
            [self.advertisingActivityIndicator stopAnimating];
             labelText = NSLocalizedString(@"Connect to master",@"");
        }
    }
    
    self.connectLabel.text = labelText;
}


- (IBAction)segmentAction:(UISegmentedControl *)sender {
    
    [self resetPeers];
    
    self.isMaster = (sender.selectedSegmentIndex == 0);
    
    self.isBrowsing = NO;
    
    //self.browseButton.hidden = !self.isMaster;
    
    [self.connectSwitch setOn:NO];
    
    // if browsing, this view is hidden, BUT
    // if advertising we need to shut it down
    
    if (self.isAdvertising) {
        [self.connectManager advertiseSelf:NO];
        self.isAdvertising = NO;
    }

     
     
     [self updateConnectUI];
    
}


- (void)displayBrowser {
    [self presentViewController:[self.connectManager browserVC] animated:YES completion:nil];
}

- (IBAction)browseButtonAction:(id)sender {
    self.isBrowsing = YES;
    [self displayBrowser];
}


- (IBAction)connectSwitchAction:(UISwitch *)sender {
    
    self.doConnect = [sender isOn];
    
    // either way, start over
//    [self resetPeers];
    
    if (self.doConnect) {
        
        
        self.isBrowsing = self.isMaster;
        self.isAdvertising = !self.isMaster;
        
        // it was off, so fire off either the browser or start advertising
        if (self.isMaster) {
            // show the browser
//            
//            self.isBrowsing = YES;
//            self.isAdvertising = NO;
//            
//            // let the user know something is happening
//            //[self updateConnectUI];
            
            [self displayBrowser];
            
            
        } else {
            // advertise the slave
//            self.isAdvertising = YES;
            [self.connectManager advertiseSelf:YES];
            
//            self.isBrowsing = !self.isAdvertising;
            
            
            // let the user know something is happening
            //[self updateConnectUI];
        }
        
    } else { // it was on but now disconnect
        
        // this should disconnect it self from ALL peers?????
        // and they should all get messages?????
        
        self.isBrowsing = self.isAdvertising = NO;
        
        if (self.isMaster) {
            
            // this should disconnect it self from ALL peers?????
            // and they should all get messages?????
            [self.connectManager disconnectAllPeers];
            
            //self.isBrowsing = NO;
            
            // let the user know something is happening
            //[self updateConnectUI];
            
            // dismiss the browser (IF it is around)
            [self dismissViewControllerAnimated:YES completion:nil];
            
            // disconnect all remotes connected to this controller
            //[self.connectManager disconnectAllPeers];
            
        } else {
            // stop advertising the slave
            //if (self.isAdvertising) {
                //self.isAdvertising = NO;
                [self.connectManager advertiseSelf:self.isAdvertising];
                 
                 // let the user know something is happening
                 //[self updateConnectUI];
           // }
            
            [self.connectManager disconnectFromSession];
        }
        
        
    }
    [self updateConnectUI];
}



#pragma mark ConnectivityManager Delegate Methods

// this is a proxy for change in state disconnected vs. connecting
// AND IS CALLED ON A PRIVATE OPERATION THREAD

- (void)connectionStateDidConnect:(BOOL)didConnect withPeerID:(MCPeerID *)peerID {
    
    NSLog(@"connectionStateDidConnect: %@  didConnect: %@", peerID.displayName, didConnect ? @"YES" : @"NO");
    
    if (didConnect) {
        // for the master, this might be many names
        // for the slave, this is ONLY the controller I hope ?????????
        [self.connectedPeerNames addObject:peerID.displayName];
        
        // if a slave then stop advertising
        if (!self.isMaster) {
            self.isAdvertising = NO;
            [self.connectManager advertiseSelf:self.isAdvertising];
        }
        
        [self updateConnectUI];
        
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


// these are only for the master which is the only one that does the browsing
- (void)browserViewController:(MCBrowserViewController *)browser didConnect:(BOOL)didConnect {
    
    // the connect switch should still be on
    // as well as the list of peers
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (didConnect) {
        // can initiate sending data at this point
    }

    self.isBrowsing = NO;
    [self updateConnectUI];
}


#pragma mark - Table view data source

// Use self.connectManager.connectedPeerIDs to have the peerID for deletion/disconnecting

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.isMaster ? NSLocalizedString(@"Connected Remotes",@"") : NSLocalizedString(@"Controller",@"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.connectManager.connectedPeerIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.connectManager.connectedPeerIDs objectAtIndex:indexPath.row] displayName ];
    
    return cell;
}

@end
