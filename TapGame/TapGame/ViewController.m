#import "ViewController.h"
#import "Foundation/Foundation.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *gameTimeLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *gameFieldView;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation ViewController {
    int defaultGameTime;
    int currentScore;
    BOOL isGameStarted;
    
    NSTimeInterval gameTimeInterval;
    NSTimer *gameTimer;
    NSTimer *moveImageTimer;
    
    NSString *gameTime;
    NSString *remainingGameTime;
    NSString *gameTimeFullText;
    NSString *second;
    NSString *startGame;
    NSString *stopGame;
    NSString *lastScore;
    
    UITapGestureRecognizer *recognizer;
    
    int maxXValue;
    int maxYValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initFields];
    [self initUi];
    [self addListeners];
}

#pragma mark - Init

- (void) initFields {
    defaultGameTime = 30;
    currentScore = 0;
    isGameStarted = NO;
    gameTimeInterval = 0;
    
    gameTime = @"Время";
    remainingGameTime = @"Оставшееся время";
    gameTimeFullText =  @"%@ : %d сек";
    
    startGame = @"Начать";
    stopGame = @"Завершить";
    
    lastScore = @"Последний счет: %d";
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture)];
}

- (void) initUi {
    self.timeStepper.value = defaultGameTime;
    self.timeStepper.stepValue = 1;
    self.timeStepper.maximumValue = 60;
    self.timeStepper.minimumValue = 10;
    
    self.gameFieldView.layer.borderWidth = 1;
    self.gameFieldView.layer.cornerRadius = 12;
    self.gameFieldView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    [self.image addGestureRecognizer: recognizer];
    [self setImageVisibility: FALSE];
    [self updateUi];
}

#pragma mark - Listeners

- (void) addListeners {
    [self.timeStepper addTarget:self action: @selector(stepperTapped) forControlEvents: UIControlEventTouchUpInside];
    [self.actionButton addTarget:self action:@selector(actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void) stepperTapped {
    [self setGameTimeInterval];
}

-(void) handleGesture {
    currentScore += 1;
    [self setScore: currentScore];
    [self setImageVisibility: NO];
}

- (void) actionButtonTapped {
    if(isGameStarted == YES) {
        [self stopGame];
    } else {
        [self startGame];
    }
}

- (void) startGame {
    isGameStarted = YES;
    maxXValue = self.gameFieldView.frame.size.width - self.image.frame.size.width;
    maxYValue = self.gameFieldView.frame.size.height - self.image.frame.size.height;
    [self updateUi];
    [self invalidateTimers];
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeUiByTimer) userInfo:nil repeats:YES];
    moveImageTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(moveImageByTimer) userInfo:nil repeats:YES];
    [moveImageTimer fire];
}

- (void) stopGame {
    isGameStarted = NO;
    [self invalidateTimers];
    [self updateUi];
    [self setImageVisibility:FALSE];
}

- (void) updateUi {
    [self setGameTimeInterval];
    [self changeActionButtonTitle];
    [self setStepperEnabled: !isGameStarted];
    [self setScore: currentScore];
}

- (void) changeUiByTimer {
    if(gameTimeInterval == 0) {
        [self stopGame];
    } else {
        gameTimeInterval -= 1;
        [self setGameTime: gameTimeInterval];
    }
}

- (void) moveImageByTimer {
    [self setImageVisibility: FALSE];
    self.image.frame = CGRectMake([self getRandomNumberBetweenZero: maxXValue],
                                  [self getRandomNumberBetweenZero: maxYValue],
                                  self.image.frame.size.width,
                                  self.image.frame.size.height);
    [self setImageVisibility: TRUE];
}

#pragma mark - State

- (void) setGameTimeInterval {
    gameTimeInterval = self.timeStepper.value;
    [self setGameTime: gameTimeInterval];
}

- (void) setGameTime:(int) seconds {
    NSString *text = isGameStarted? remainingGameTime : gameTime;
    NSString *gameTime = [[NSString alloc] initWithFormat: gameTimeFullText, text, seconds];
    self.gameTimeLabel.text = gameTime;
}

- (void) changeActionButtonTitle {
    NSString *text = isGameStarted? stopGame : startGame;
    [self.actionButton setTitle:text forState:UIControlStateNormal];
}

- (void) setScore: (int) value {
    NSString *scoreText = [[NSString alloc] initWithFormat:  lastScore, value];
    self.scoreLabel.text = scoreText;
}

- (void) setImageVisibility: (BOOL) isVisible {
    self.image.hidden = !isVisible;
}

- (void) setStepperEnabled: (BOOL) isEnabled {
    self.timeStepper.enabled = isEnabled;
}

- (void) invalidateTimers {
    if(gameTimer != nil) {
        [gameTimer invalidate];
    }
    
    if(moveImageTimer != nil) {
        [moveImageTimer invalidate];
    }
}

#pragma mark - Utils

- (int) getRandomNumberBetweenZero:(int)to {
    return arc4random_uniform(to);
}

@end
