//
//  ContentView.swift
//  Undead
//
//  Created by mac on 18/03/22.
//

import SwiftUI

struct HomeScreen: View {
    
    @State var row = 4
    @State var column = 4
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: GameView(row: row, column: column),
                label: {
                    Text("play")
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.5))
                        .padding()
                })
            VStack {
                Stepper("row :- \(row)") {
                    row += 1
                    if row > 7 {row = 4}
                } onDecrement: {
                    row-=1
                    if row < 4{row = 7}
                }
                Stepper("column :- \(column)") {
                    column+=1
                    if column > 7 {column = 4}
                } onDecrement: {
                    column-=1
                    if column < 4{column = 7}
                }
            }
            .padding()
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeScreen()
        }
    }
}
