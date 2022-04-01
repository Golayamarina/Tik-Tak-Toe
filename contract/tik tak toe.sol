// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract TikTakToe
{
    
    modifier bid_value {
      require(msg.value == 0.5 ether, "bid shoud be 0.5 ether!");
        _;
    }

    
    struct Game
    {
        uint balance;
        uint turn;
        address opposition;
        uint time_limit;
        mapping(uint => mapping(uint => uint)) board;
        bool isSet;
    }

    
    mapping (address => Game) games;

    
    function start() public bid_value payable
    {
        
        Game storage g = games[msg.sender];
        
        if(g.balance == 0)
        {
            g.isSet = true;
            restart(msg.sender);
            g.balance += msg.value;
        }
    }

    
    function join(address host) public bid_value payable
    {
        Game storage g = games[host];
        
        require(g.isSet && g.opposition == address(0) && msg.value == g.balance);
       
        if(g.opposition == address(0) && msg.sender != host)
        {
            g.balance += msg.value;
            g.opposition = msg.sender;
        }
    }

    
    function play(address host, uint row, uint column) public
    {
        Game storage g = games[host];

        
        uint8 player = 2;
        if(msg.sender == host)
            player = 1;

        
        if(
          g.balance > 0 && g.opposition != address(0) &&
          row >= 0 && row < 3 && column >= 0 && column < 3 &&
          g.board[row][column] == 0 &&
          (g.time_limit == 0 || block.timestamp <= g.time_limit) &&
          g.turn != player
          )
        {
            
            g.board[row][column] = player;

            
            if(is_board_full(host))
            {
                payable(host).transfer(g.balance/2);
                payable(g.opposition).transfer(g.balance/2);
                g.balance = 0;
                restart(host);
                return;
            }

           
            if(is_winner(host, player))
            {
                if(player == 1)
                    payable(host).transfer(g.balance);
                else
                    payable(g.opposition).transfer(g.balance);

                g.balance = 0;
                restart(host);
                return;
            }

            
            g.turn = player;

            
            g.time_limit = block.timestamp + (600);
        }
    }

    
    function claim_reward(address host) public
    {
        Game storage g = games[host];

        if(g.opposition != address(0)
        && g.balance > 0
        && block.timestamp > g.time_limit)
        {
            if(g.turn == 2)
                payable(host).transfer(g.balance);
            else
                payable(g.opposition).transfer(g.balance);
            g.balance = 0;
            restart(host);
        }
    }

     function check(address host, uint player, uint r1, uint r2, uint r3,
    uint c1, uint c2, uint c3) private view returns (bool retVal)
    {
        Game storage g = games[host];
        if(g.board[r1][c1] == player && g.board[r2][c2] == player
        && g.board[r3][c3] == player)
            return true;
    }

    
    function is_winner(address host, uint player) private view returns (bool winner)
    {
        
        if(check(host, player, 0, 1, 2, 0, 1, 2) || check(host, player, 0, 1, 2, 2, 1, 0))
            return true;

        
        for(uint r = 0; r < 3; r++)
            if(check(host, player, r, r, r, 0, 1, 2) || check(host, player, 0, 1, 2, r, r, r))
                return true;
    }

    
    function is_board_full(address host) private view returns (bool retVal)
    {
        Game storage g = games[host];
        uint count = 0;
        for(uint r = 0; r < 3; r++)
            for(uint c = 0; c < 3; c++)
                if(g.board[r][c] > 0)
                    count++;
        if(count >= 9)
            return true;
    }

    
    function restart(address host) private
    {
        Game storage g = games[host];
        if(g.balance == 0)
        {
            g.turn = 1;
            g.opposition = address(0);
            g.time_limit = 0;

            for(uint r = 0; r < 3; r++)
                for(uint c = 0; c < 3; c++)
                    g.board[r][c] = 0;
        }
    }

    
    function get_game_status(address host) public view returns(uint, uint, address, uint, uint, uint){
      Game storage g = games[host];
      uint row1 = (100 * (g.board[0][0] + 1)) + (10 * (g.board[0][1] + 1)) + (g.board[0][2] + 1);
      uint row2 = (100 * (g.board[1][0] + 1)) + (10 * (g.board[1][1] + 1)) + (g.board[1][2] + 1);
      uint row3 = (100 * (g.board[2][0] + 1)) + (10 * (g.board[2][1] + 1)) + (g.board[2][2] + 1);

      return (games[host].balance,
              games[host].turn,
              games[host].opposition,
              row1,
              row2,
              row3
              );
    }

    
    function get_blocktimestamp() public view returns(uint){
      return(block.timestamp);
    }
} 
