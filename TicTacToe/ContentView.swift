//
//  ContentView.swift
//  TicTacToe
//
//  Created by Franklin Ackah on 12/30/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        NavigationView {
            Board()
                .navigationTitle("Tic Tac Toe")
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Board : View {
    
    @State var moves : [String] = Array(repeating: "", count: 9)
    @State var currentPlayer = false
    @State var gameOver = false
    @State var msg = ""
    
    var body: some View {
        
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), content: {
            
            
            ForEach(0..<9, id: \.self){index in
                
                ZStack {
                    
                    Color.white
                        .opacity(moves[index] == "" ? 1 : 0.5)
                    
                    Text(moves[index])
                        .font(.system(size: 55))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .opacity(moves[index] != "" ? 1 : 0)

                }
                .frame(width: getWidth(), height: getWidth())
                .cornerRadius(15)
                .rotation3DEffect(
                    .init(degrees: moves[index] != "" ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0),
                    anchor: .center,
                    anchorZ: 0.0,
                    perspective: 1.0
                )
                .onTapGesture {
                    
                    withAnimation(Animation.easeIn(duration: 0.5)){
                        
                        //disable non empty space
                        if moves[index] == ""{
//                            moves[index] = currentPlayer ? "X" : "O"
                            
                            if !currentPlayer {
                                moves[index] = "O"
                                checkWinner()
                            }
                            
                            currentPlayer.toggle()
                        }
                    }
                }
                
            }
        })
        .padding(15)
        .onChange(of: moves, perform: { value in
            
            checkWinner()
        })
        .onChange(of: currentPlayer, perform: { value in
            
            withAnimation(Animation.easeIn(duration: 0.5)){
                CPUPlay()
                checkWinner()
            }
            
        })
        .alert(isPresented: $gameOver, content: {
            
            Alert(title: Text("Winner"), message: Text(msg), dismissButton: .destructive(Text("Play Again"), action: {
                
                withAnimation(Animation.easeIn(duration: 0.5)){
                    moves.removeAll()
                    moves = Array(repeating: "", count: 9)
                    currentPlayer = true
                }
            }))
        })
    }
    
    
    // calc grid length

    func getWidth()->CGFloat{
        
        let width = UIScreen.main.bounds.width - (30 + 30)
        
        return width / 3
        
    }

    //check winner
    func checkWinner(){
        
        if(checkMoves(player: "X")){
            
            msg = "Player X Won!"
            gameOver.toggle()
        }
        else if(checkMoves(player: "O")){
            msg = "Player O Won!"
            gameOver.toggle()
        } else {
            
            //tie
            
            let result = moves.contains { (value) -> Bool in
                
                return value == ""
            }
            
            if !result {
                msg = "Game Over, it's a Tie !"
                gameOver.toggle()
            }
        }
        
    }


    func checkMoves(player: String)->Bool{
        
        //horizontal moves
        
        for i in stride(from: 0, to: 9, by: 3){
            
            if (moves[i] == player && moves[i + 1] == player && moves[i + 2] == player ){
                return true
            }
        }
        
        //vertical moves
        
        for i in 0...2 {
            
            if (moves[i] == player && moves[i + 3] == player && moves[i + 6] == player ){
                return true
            }
        }
        
        //check diagonal
        
        if (moves[0] == player && moves[4] == player && moves[8] == player ){
            return true
        }
        
        if (moves[2] == player && moves[4] == player && moves[6] == player ){
            return true
        }
        
        
        return false;
    }
    
    func nextAvailMove()->Int{
        
        for i in 0..<9 {
            if moves[i] == "" {
                return i
            }
        }
        return -1
    }
    
    func CPUPlay(){
        //cpu
        if currentPlayer == true {
//            let emptySpot = nextAvailMove()
            if !gameOver {
                let emptySpot = minimaxCPU(currentMoves: moves, currentPlayer: currentPlayer)
              //  print("Empty Slots: ", emptySpot)
             //   NSLog("Hello")
                if emptySpot.bestMove != -1 {
                    moves[emptySpot.bestMove] = "X"
                    currentPlayer.toggle()
                }

            }

        }
    }
    
    
    func minimaxCPU(currentMoves: Array<String>, currentPlayer: Bool)->(bestScore: Int, bestMove: Int){
        
        let CPU = "X" // true
        let humanPlayer = "O" //false
        
        //base case
        if isGameOver(currentBoard: currentMoves) {
            return (utility(currentBoard: currentMoves), -1)
        }
        
        var bestScore = (currentPlayer) ? Int.min : Int.max
        var bestMove = -1
        
        for i in 0..<9 {
            
            if currentMoves[i] != "" {
                continue
            }
            
            //deep copy of moves
            var newMoves = Array.init(currentMoves)
            //add move to get successors
            newMoves[i] = currentPlayer ? CPU : humanPlayer
            let newPlayer = currentPlayer ? false : true
            //recursive call
            let results = minimaxCPU(currentMoves: newMoves, currentPlayer: newPlayer)
            print("Best results: ",  results.bestScore)
            
            //max player
            if currentPlayer == true{ //cpu
                
                if results.bestScore > bestScore {
                    bestScore = results.bestScore
                    bestMove = i
                    
                }
            } else { //min player
                
                if results.bestScore < bestScore {
                    bestScore = results.bestScore
                    bestMove = i
                }
            }
        }
        
        return (bestScore, bestMove)
    }
    
    func utility(currentBoard: Array<String>)->Int{
        var nonBlanks = 0;
        var blanks = 0;
        //find # of non-blank spaces
     //   print(currentBoard)
        for move in currentBoard {
            if (move == "") {
                blanks = blanks + 1
            }
        }
        
        nonBlanks = 9 - blanks
        print("non blanks: ", nonBlanks)
        for i in 0..<8 {
            var set = ""
            
            switch i {
            case 0:
                set = "" + currentBoard[0] + currentBoard[1] + currentBoard[2]
                break
            case 1:
                set = "" + currentBoard[3] + currentBoard[4] + currentBoard[5]
                break
            case 2:
                set = "" + currentBoard[6] + currentBoard[7] + currentBoard[8]
                break
            case 3:
                set = "" + currentBoard[0] + currentBoard[3] + currentBoard[6]
                break
            case 4:
                set = "" + currentBoard[1] + currentBoard[4] + currentBoard[7]
                break
            case 5:
                set = "" + currentBoard[2] + currentBoard[5] + currentBoard[8]
                break
            case 6:
                set = "" + currentBoard[2] + currentBoard[4] + currentBoard[6]
                break
            case 7:
                set = "" + currentBoard[0] + currentBoard[4] + currentBoard[8]
                break
            default: break
                
            }
            
            if set == "OOO" {
                
                var score = (10 - nonBlanks)
                if currentPlayer {
                    score = -1 * score
                }
                print("Score: ", score)
                return score
                
            } else if set == "XXX" {
                var score = 10 - nonBlanks
                if !currentPlayer {
                    score = -1 * score
                }
                print("Score: ", score)
                return score
            }
        }
        
        //draw
        return 0
    }
    
    func isGameOver(currentBoard: Array<String>)->Bool{
        
        for i in 0..<8 {
            var set = ""
            
            switch i {
            case 0:
                set = "" + currentBoard[0] + currentBoard[1] + currentBoard[2]
                break
            case 1:
                set = "" + currentBoard[3] + currentBoard[4] + currentBoard[5]
                break
            case 2:
                set = "" + currentBoard[6] + currentBoard[7] + currentBoard[8]
                break
            case 3:
                set = "" + currentBoard[0] + currentBoard[3] + currentBoard[6]
                break
            case 4:
                set = "" + currentBoard[1] + currentBoard[4] + currentBoard[7]
                break
            case 5:
                set = "" + currentBoard[2] + currentBoard[5] + currentBoard[8]
                break
            case 6:
                set = "" + currentBoard[2] + currentBoard[4] + currentBoard[6]
                break
            case 7:
                set = "" + currentBoard[0] + currentBoard[4] + currentBoard[8]
                break
            default: break
                
            }
            
            if set == "OOO" {
                
                return true
                
            } else if set == "XXX" {
                return true
            }
            
            for i in 0..<9 {
                if currentBoard[i] == "" { //incomplete
                    return false
                }
            }
        }
        return true
    }
}



