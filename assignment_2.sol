pragma solidity ^0.8.0;

contract RockPaperScissors {

    enum Move { ROCK, PAPER, SCISSORS }

    uint256 public constant MIN_BET = 0.0001 ether;

    uint256 public constant MAX_REWARD_MULTIPLIER = 2;

    mapping(address => Move[]) public gameHistory;

    Game public currentGame;

    struct Game {
        address player1;
        address player2;
        uint256 betAmount;
        Move player1Move;
        Move player2Move;
        uint256 winner;
    }

    constructor() {}

    function createGame() public payable {
        require(msg.value >= MIN_BET, "Minimum bet amount required");

        currentGame = Game({
            player1: msg.sender,
            player2: address(0),
            betAmount: msg.value,
            player1Move: Move.UNKNOWN,
            player2Move: Move.UNKNOWN,
            winner: 0
        });
    }

    function joinGame() public payable {
        require(msg.value == currentGame.betAmount, "Bet amount must match the existing game");
        require(currentGame.player2 == address(0), "Game is already full");

        currentGame.player2 = msg.sender;
    }

    function playMove(Move move) public {
        require(currentGame.player1 == msg.sender || currentGame.player2 == msg.sender, "Must be a player in the game");
        require(currentGame.player1Move == Move.UNKNOWN || currentGame.player2Move == Move.UNKNOWN, "Both players must make a move");

        if (currentGame.player1 == msg.sender) {
            currentGame.player1Move = move;
        } else if (currentGame.player2 == msg.sender) {
            currentGame.player2Move = move;
        }

        if (currentGame.player1Move != Move.UNKNOWN && currentGame.player2Move != Move.UNKNOWN) {
            calculateWinner();
        }
    }

    function calculateWinner() private {
        uint256 winner = 0;

        if (currentGame.player1Move == Move.ROCK && currentGame.player2Move == Move.SCISSORS) {
            winner = 1;
        } else if (currentGame.player1Move == Move.SCISSORS && currentGame.player2Move == Move.PAPER) {
            winner = 1;
        } else if (currentGame.player1Move == Move.PAPER && currentGame.player2Move == Move.ROCK) {
            winner = 1;
        } else if (currentGame.player1Move == Move.SCISSORS && currentGame.player2Move == Move.SCISSORS) {
            winner = 0;
        } else if (currentGame.player1Move == Move.PAPER && currentGame.player2Move == Move.PAPER) {
            winner = 0;
        } else if (currentGame.player1Move == Move.ROCK && currentGame.player2Move == Move.ROCK) {
            winner = 0;
        } else {
            winner = 2;
        }

        currentGame.winner = winner;
    }

    function withdrawWinnings() public {
        require(currentGame.winner == msg.sender, "Only the winner can withdraw winnings");

        uint256 winnings = currentGame.betAmount * MAX_REWARD_MULTIPLIER;
        payable(msg.sender).transfer(winnings);

        currentGame = Game({
            player1: address(0),
            player2: address(0),
            betAmount: 0,
            player1Move: Move.UNKNOWN,
            player2Move: Move.UNKNOWN,
            winner: 0
        });
    }

    // Retrieves the current game state
}