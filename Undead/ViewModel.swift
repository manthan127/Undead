//
//  ViewModel.swift
//  Undead
//
//  Created by mac on 18/03/22.
//

import SwiftUI

enum CellType: String, CaseIterable {
    case mirror
    case mirror2
    
    case ghost
    case vampire
    case zombie
    
    case empty
    
    var isMirror: Bool {
        self == .mirror || self == .mirror2
    }
}

class GameScreenVM: ObservableObject {
    var row: Int = 4
    var column: Int = 4
    
    @Published var dBoard: [[CellType]] = []
    
    var ans: [[CellType]] = []
    
    let monsters: [CellType] = [.ghost, .vampire, .zombie]
    
    @Published var monstersCount = _3zeros
    @Published var monstersTotal = _3zeros
    
    @Published var counters: [[Counter]] = Array(repeating: [], count: 4)
    @Published var win = false
    
    @Published var answerReveled = false
    
    init() {}
    
    func initBoard(row: Int, col: Int) {
        self.row = row
        self.column = col
        
        dBoard = Array(repeating: Array(repeating: CellType.empty, count: column), count: row)
        let col = Array(repeating: Counter(), count: column)
        let ro = Array(repeating: Counter(), count: row)
        counters = [col, ro, col, ro]
        setData()
    }
    
    func revelAnswer() {
        dBoard = ans
        answerReveled = true
        for i in counters.indices {
            for j in counters[i].indices {
                counters[i][j].color = .black
            }
        }
        monstersCount = _3zeros
    }
    
    func setMonstersCount() {
        for i in monsters.indices {
            monstersCount[i] = monstersTotal[i] - dBoard.map{$0.filter({$0 == monsters[i]}).count}.reduce(0, +)
        }
        handleNumbers(setCounters: false, board: dBoard)
    }
    
    func setData() {
        ans = dBoard
        
        let choices = CellType.allCases.dropLast()
        for i in ans.indices {
            for j in ans[i].indices {
                ans[i][j] = choices.randomElement()!
                if ans[i][j].isMirror {
                    dBoard[i][j] = ans[i][j]
                }
            }
        }
        
        for i in ans {
            for x in 0..<3 {
                monstersTotal[x] += i.filter{$0 == monsters[x]}.count
            }
        }
        monstersCount = monstersTotal
        
        handleNumbers(setCounters: true, board: ans)
    }
    
    func resetBoard() {
        dBoard = Array(repeating: Array(repeating: CellType.empty, count: column), count: row)
        answerReveled = false
        monstersTotal = _3zeros
        setData()
    }
    
    func handleNumbers(setCounters: Bool, board: [[CellType]]) {
        var misMatch = false
        
        for i in 0..<4 { for j in [board[0].indices, board.indices][i%2] {
            var mirrorVisited = false
            
            var direction = i
            var counter = 0
            var emptyCount = 0
            
            var curPos: (row: Int, col: Int) = [(0, j), (j, 0), (board.count-1, j), (j, board[i].count-1) ][i]
            
            while let x = board[safe: curPos.row]?[safe: curPos.col] {
                switch x {
                case .mirror:
                    direction = 3 - direction
                    mirrorVisited = true
                case .mirror2:
                    direction += direction % 2 == 0 ? 1 : -1
                    mirrorVisited = true
                case .ghost:
                    if mirrorVisited {
                        counter += 1
                    }
                case .vampire:
                    if !mirrorVisited {
                        counter += 1
                    }
                case .zombie:
                    counter += 1
                case .empty:
                    emptyCount += 1
                }
                
                switch direction {
                case 0: curPos.row += 1
                case 1: curPos.col += 1
                case 2: curPos.row -= 1
                default: curPos.col -= 1
                }
            }
            if setCounters {
                counters[i][j].monNum = counter
            } else if counter + emptyCount < counters[i][j].monNum || counters[i][j].monNum < counter {
                misMatch = true
                counters[i][j].color = .red
            } else {
                counters[i][j].color = .primary
            }
        }}
        if monstersCount == _3zeros && !setCounters && !misMatch && !answerReveled {
            win = true
        }
    }
    
    func removeMonster(row: Int, col: Int) {
        if dBoard[row][col] != .empty {
            dBoard[row][col] = .empty
            setMonstersCount()
        }
    }
}
