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
                            moves[index] = currentPlayer ? "X" : "O"
                            
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
}



