//
//  GameView.swift
//  Undead
//
//  Created by mac on 18/03/22.
//

import SwiftUI
import UniformTypeIdentifiers


struct Counter {
    var monNum: Int = 0
    var color: Color = .primary
}

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var row: Int
    @State var column: Int
    
    @ObservedObject var vm = GameScreenVM()
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(vm.answerReveled ? "New Game" : "show Answer") {
                if vm.answerReveled {
                    vm.resetBoard()
                } else {
                    vm.revelAnswer()
                }
            }
            
            HStack {
                ForEach(vm.monsters.indices, id: \.self) { index in
                    VStack {
                        Image("\(vm.monsters[index].rawValue)")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.primary)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .onDrag({ return NSItemProvider(object: index.description as NSString) })
                        Text("\(vm.monstersCount[index])/\(vm.monstersTotal[index])")
                            .foregroundColor(vm.monstersCount[index] >= 0 ? .primary : .red)
                    }
                }
            }
            Spacer()
            Spacer()
            HLine(vm.counters[0])
            HStack {
                VLine(vm.counters[1])
                boardView
                VLine(vm.counters[3])
            }
            .aspectRatio(1, contentMode: .fit)
            HLine(vm.counters[2])
            Spacer()
        }
        .onAppear {
            vm.initBoard(row: row, col: column)
        }
        .alert(isPresented: $vm.win, content: {
            Alert(title: Text("won"), primaryButton: Alert.Button.default(Text("Home Screen"), action: {
                presentationMode.wrappedValue.dismiss()
            }), secondaryButton: Alert.Button.default(Text("play again"), action: {
                vm.resetBoard()
            }))
        })
    }
    
    
    func VLine(_ arr: [Counter]) -> some View {
        VStack(spacing: 5) {
            ForEach(arr.indices, id: \.self) { i in
                Text("\(arr[i].monNum)")
                    .frame(maxHeight: .infinity)
                    .foregroundColor(arr[i].color)
            }
        }
        .padding(.vertical)
    }
    
    func HLine(_ arr: [Counter]) -> some View {
        HStack(spacing: 5) {
            ForEach(arr.indices, id: \.self) { i in
                Text("\(arr[i].monNum)")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(arr[i].color)
            }
        }
        .padding(.horizontal)
    }
    
    var boardView: some View {
        VStack(spacing: 5) {
            ForEach(vm.dBoard.indices, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(vm.dBoard[row].indices, id: \.self) { column in
                        cellView(row: row, column: column)
                    }
                }
            }
        }
    }
    
    func cellView(row: Int, column: Int) -> some View {
        let isMirror = vm.dBoard[row][column].isMirror
        return Image("\(vm.dBoard[row][column].rawValue)")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.primary)
            .aspectRatio(1, contentMode: .fit)
            .padding(4)
            .border(Color.primary, width: 3)
            .onTapGesture(count: 2){
                vm.removeMonster(row: row, col: column)
            }
            .disabled(isMirror)
            .onDrop(
                of: ["public.String"],
                delegate: URLDropDelegate(clous: { monsterIndex in
                    if !isMirror && monsterIndex != -1 {
                        vm.dBoard[row][column] = vm.monsters[monsterIndex]
                        vm.setMonstersCount()
                    }
                }, isDroppable: !isMirror)
            )
            
    }
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else { return nil }
        return self[index]
    }
}

struct URLDropDelegate: DropDelegate {
    var clous: (Int) -> Void
    var isDroppable: Bool
    
    func validateDrop(info: DropInfo) -> Bool {
        isDroppable
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [UTType.text]) else {
            return false
        }
        
        let items = info.itemProviders(for: [UTType.text])
        
        for item in items {
            _ = item.loadObject(ofClass: String.self) { (_ObjectiveCBridgeable, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        clous(Int(_ObjectiveCBridgeable ?? "-1") ?? -1)
                    }
                }
            }
        }
        return false
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(row: 5, column: 5)
    }
}

