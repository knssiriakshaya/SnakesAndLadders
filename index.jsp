<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Snakes and Ladders</title>
    <style>
        body {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            margin: 0;
        }
        canvas {
            border: 2px solid black;
            margin-bottom: 20px;
        }
        h1 {
            margin-bottom: 10px;
        }
        #gameBoard {
            background: lightyellow;
        }
        button {
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }
        p {
            font-size: 18px;
        }
        #winMessage {
            font-size: 24px;
            color: green;
            font-weight: bold;
            margin-top: 20px;
        }
        #eventMessage {
            font-size: 20px;
            color: orange;
            font-weight: bold;
            margin-top: 10px;
        }
        .playerDetails {
            display: flex;
            justify-content: space-between;
            width: 100%;
            margin-top: 10px;
        }
        .player {
            flex: 1;
            text-align: center;
        }
        .player1 {
            color: red; /* Color matching Player 1 */
        }
        .player2 {
            color: blue; /* Color matching Player 2 */
        }
    </style>
</head>
<body>
    <h1>Snakes and Ladders - Two Players</h1>
    <canvas id="gameBoard" width="500" height="500"></canvas>
    <button onclick="rollDice()">Roll Dice</button>
    <p>Dice Roll: <span id="diceValue">0</span></p>
    <p id="winMessage"></p> <!-- "YOU WON" message will be displayed here -->
    <p id="eventMessage"></p> <!-- Message for snake or ladder events -->
    <p>Current Turn: <span id="currentPlayer">Player 1</span></p>
    <!-- Player details section -->
    <div class="playerDetails">
        <div class="player player1">
            <p>Player 1 Position: <span id="player1Position">1</span></p>
        </div>
        <div class="player player2">
            <p>Player 2 Position: <span id="player2Position">1</span></p>
        </div>
        
    </div>

    <!-- JavaScript to control game logic -->
    <script>
        const canvas = document.getElementById('gameBoard');
        const ctx = canvas.getContext('2d');
        let player1Position = 1;
        let player2Position = 1;
        let currentPlayer = 1;
        const boardSize = 10;  // 10x10 grid
        const cellSize = canvas.width / boardSize;
        let gameOver = false;

        // Snakes and Ladders positions (Ladders go up, Snakes go down)
        const ladders = {
            2: 38,
            7: 14,
            8: 31,
            15: 26,
            21: 42,
            28: 84,
            36: 44,
            51: 67,
            71: 91,
            78: 98,
            87: 94
        };

        const snakes = {
            16: 6,
            46: 25,
            49: 11,
            62: 19,
            64: 60,
            74: 53,
            89: 68,
            92: 88,
            95: 75,
            99: 80
        };

        function drawBoard() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            
            let position = 100; // Start from 100 (top-left)
            
            for (let i = 0; i < boardSize; i++) {
                for (let j = 0; j < boardSize; j++) {
                    // For even rows (top-down), numbers move left-to-right
                    let col = (i % 2 === 0) ? j : (boardSize - j - 1);
                    let x = col * cellSize;
                    let y = i * cellSize;

                    // Alternate colors for the board squares
                    ctx.fillStyle = (i % 2 === 0) ? (j % 2 === 0 ? '#f9f9f9' : '#ddd') : (j % 2 === 0 ? '#ddd' : '#f9f9f9');
                    ctx.fillRect(x, y, cellSize, cellSize);

                    // Number the cells in reverse order
                    ctx.fillStyle = 'black';
                    ctx.font = '16px Arial';
                    ctx.fillText(position, x + 5, y + 20);

                    // Display snake and ladder destination messages
                    if (ladders[position]) {
                        ctx.fillStyle = 'green';
                        ctx.font = '12px Arial';
                        ctx.fillText("Go to " + ladders[position], x + 5, y + 40);
                    }
                    if (snakes[position]) {
                        ctx.fillStyle = 'red';
                        ctx.font = '12px Arial';
                        ctx.fillText("Go to " + snakes[position], x + 5, y + 40);
                    }

                    position--; // Decrease the number for each cell
                }
            }

            // Redraw both players after clearing the board
            drawPlayers();
        }

        function drawPlayers() {
            drawPlayer(player1Position, 'red');  // Player 1 in red
            drawPlayer(player2Position, 'blue'); // Player 2 in blue
        }

        function drawPlayer(position, color) {
            let row = Math.floor((100 - position) / boardSize); // Inverted row because of reverse numbering
            let col = (100 - position) % boardSize;

            // Adjust positioning for snake-like path (reverse for odd rows)
            if (row % 2 === 1) {
                col = boardSize - col - 1;
            }

            // Draw the player as a circle
            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.arc(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2, cellSize / 4, 0, 2 * Math.PI);
            ctx.fill();
        }

        function rollDice() {
            if (gameOver) return;

            fetch('rollDice.jsp')
                .then(response => response.json())
                .then(data => {
                    let diceValue = data.diceValue;
                    document.getElementById('diceValue').innerText = diceValue;
                    movePlayer(diceValue);
                })
                .catch(error => console.error('Error:', error));
        }

        function movePlayer(diceValue) {
            let position;
            let playerStr;

            // Determine which player is moving
            if (currentPlayer === 1) {
                player1Position += diceValue;
                position = player1Position;
                playerStr = "Player 1";
            } else {
                player2Position += diceValue;
                position = player2Position;
                playerStr = "Player 2";
            }

            // Check for ladders or snakes at the new position
            let eventMessage = '';
            if (ladders[position]) {
                position = ladders[position];
                eventMessage = playerStr + ": Yayyy! A Ladder!"; // Ladder event message with player name
            } else if (snakes[position]) {
                position = snakes[position];
                eventMessage = playerStr + ": Oh no! A snake!"; // Snake event message with player name
            }

            // Ensure player does not go beyond position 100
            if (position >= 100) {
                position = 100;
                document.getElementById('winMessage').innerText = playerStr + " WON!";
                gameOver = true;
            }

            // Update the correct player's position
            if (currentPlayer === 1) {
                player1Position = position;
                document.getElementById('player1Position').innerText = player1Position;
            } else {
                player2Position = position;
                document.getElementById('player2Position').innerText = player2Position;
            }

            // Display the event message
            document.getElementById('eventMessage').innerText = eventMessage;

            // Draw the updated board with both players
            drawBoard();

            // Switch to the other player's turn
            currentPlayer = (currentPlayer === 1) ? 2 : 1;
            document.getElementById('currentPlayer').innerText = "Player " + currentPlayer;
        }

        // Initial board rendering
        drawBoard();
    </script>
</body>
</html>
