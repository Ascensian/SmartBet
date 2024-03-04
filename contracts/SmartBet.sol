// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract SmartBet {

    address public admin;
    uint public nextMatchId;
    
    constructor() {
        admin = msg.sender;
    }

    struct User {
        address walletAddress;
        string userName;
    }

    struct Bet {
        uint matchId;
        uint predictedHomeScore;
        uint predictedAwayScore;
        address user;
        uint amount;
    }

    struct Match {
        uint id;
        string homeTeam;
        string awayTeam;
        uint startTime;
        bool exists; 
    }

    struct MatchResult {
        uint homeScore;
        uint awayScore;
    }


    mapping(address => User) public users;
    mapping(uint => Bet[]) public betsByMatchId;
    mapping(uint => Match) public matches;
    mapping(uint => MatchResult) public matchResults;

    // ADMIN

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only administrator is authorized to make change");
        _;
    }

    function addMatch(string memory teamA, string memory teamB, uint dateTime) public onlyAdmin {
        matches[nextMatchId] = Match(nextMatchId, teamA, teamB, dateTime, true);
        nextMatchId++;
    }

    function updateMatch(uint matchId, string memory teamA, string memory teamB, uint dateTime) public onlyAdmin {
        matches[matchId] = Match(matchId, teamA, teamB, dateTime, true);
    }

    function deleteMatch(uint matchId) public onlyAdmin {
        delete matches[matchId];
    }

    function setMatchResult(uint _matchId, uint _homeScore, uint _awayScore) public onlyAdmin {
        matchResults[_matchId] = MatchResult(_homeScore, _awayScore);
    }

    // USER

    function registerUser(string memory _username) public {
        require(users[msg.sender].walletAddress == address(0), "User already registered.");
        users[msg.sender] = User({
            walletAddress: msg.sender,
            userName: _username
            
        });
    }

    // UTILITY FUNCTIONS

    function matchExists(uint _matchId) private view returns (bool) {
        return matches[_matchId].exists;
    }

    function matchHasStarted(uint _matchId) private view returns (bool) {
        return matches[_matchId].startTime <= block.timestamp;
    }

    // BET _ users pay money to make prediction

    function placeBet(uint _matchId, uint _predictedHomeScore, uint _predictedAwayScore) public payable {
        require(matchExists(_matchId), "Match does not exist.");
        require(!matchHasStarted(_matchId), "Match has already started.");
        require(msg.value > 0, "Bet amount must be greater than 0.");

        Bet memory newBet = Bet({
            matchId: _matchId,
            predictedHomeScore: _predictedHomeScore,
            predictedAwayScore: _predictedAwayScore,
            user: msg.sender,
            amount: msg.value
        });

        betsByMatchId[_matchId].push(newBet);
    }

    // WINNER _ determine who are the winners and send money to them

    function determineWinners(uint _matchId) public {
        require(matchExists(_matchId), "Match does not exist.");
        require(matchHasStarted(_matchId), "Match has not started yet.");

        uint actualHomeScore = matchResults[_matchId].homeScore;
        uint actualAwayScore = matchResults[_matchId].awayScore;

        for (uint i = 0; i < betsByMatchId[_matchId].length; i++) {
            Bet memory bet = betsByMatchId[_matchId][i];
            // Verify if prediction is correct
            if (bet.predictedHomeScore == actualHomeScore && bet.predictedAwayScore == actualAwayScore) {
                // winner is paid here
                payable(bet.user).transfer(bet.amount * 2);
            }
    }





}
