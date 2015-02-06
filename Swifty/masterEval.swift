//
//  masterEval.swift
//  Swifty
//
//  Created by Pouya Kary on 11/25/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

/// Space remover tool: removes spaces and comments from
/// the code for performance
func preprocessor (#codeToBeSpaceFixed: String, inout #screen: codeScreen) -> String {
    
    var spaces: [String: [NSNumber]] = ["@return":[0]]

    var theCode = Arendelle (code: codeToBeSpaceFixed)
    var result : String = ""
    
    while theCode.whileCondtion() {
        
        var currentChar = theCode.readAtI()
        
        switch currentChar {
            
        case "'" :
            result += "'" + onePartOpenCloseParser(openCloseCommand: "'", spaces: &spaces, arendelle: &theCode, screen: &screen, preprocessorState: true) + "'"
            --theCode.i
            
        case "\"" :
            result += "\"" + onePartOpenCloseParser(openCloseCommand: "\"", spaces: &spaces, arendelle: &theCode, screen: &screen, preprocessorState: true) + "\""
            --theCode.i
            
        case "/" :
            ++theCode.i
            currentChar = Array(theCode.code)[theCode.i]
            
            //
            // SLASH SLASH COMMENT REMOVER
            //
            
            
            
            if currentChar == "/" {
                
                theCode.i++
                var whileControl = true
                
                while theCode.i < theCode.code.utf16Count && whileControl {
                    
                    currentChar = Array(theCode.code)[theCode.i]
                    
                    if currentChar == "\n" {
                        
                        whileControl = false
                        
                    } else {
                        
                        theCode.i++
                        
                    }
                    
                }
                
                
                //
                // SLASH START ... STAR SLASH REMOVER
                //
                
            } else if currentChar == "*" {
                
                theCode.i++
                var whileControl = true
                
                while theCode.i < theCode.code.utf16Count && whileControl {
                    
                    currentChar = Array(theCode.code)[theCode.i]
                    
                    if currentChar == "*" {
                        
                        theCode.i++
                        
                        if theCode.i < theCode.code.utf16Count {
                            
                            currentChar = Array(theCode.code)[theCode.i]
                            
                            if currentChar == "/" {
                                
                                whileControl = false
                                
                            } else {
                                
                                theCode.i++
                                currentChar = Array(theCode.code)[theCode.i]
                                
                            }
                        }
                    }
                    
                    theCode.i++
                }
                
                if whileControl == true { screen.errors.append("Unfinished /* ... */ comment") }
                
                //
                // ARE WE WRONG
                //
                
            } else {
                
                result += "/"
                
            }
            
            theCode.i--
            
        case "&", "|":
            screen.errors.append("&&/& and ||/| are not accepted by Arendelle, Use 'and' and 'or' instead")

        case "÷":
            result += "÷"
            
        case "×":
            result += "*"
            
        case " ", "\n", "\t" :
            break
            
        default:
            result.append(currentChar)
            
        }
        
        theCode.i++
    }
    
    
    return result
}



func masterEvaluator (#code: String, #screenWidth: Int, #screenHeight: Int) -> codeScreen {
    
    //
    // Initing the first spaces
    //
    
    var spaces: [String: [NSNumber]] = ["@return":[0]]
    

    var screen = codeScreen(xsize: screenWidth, ysize: screenHeight)

    //
    // Rest of initilization
    //
    
    var arendelle = Arendelle(code: preprocessor(codeToBeSpaceFixed: code, screen: &screen))
        
    //
    // EVALUATION
    //

    let toBeRemoved = eval(&arendelle, &screen, &spaces)
    evalSpaceRemover(spaces: &spaces, spacesToBeRemoved: toBeRemoved)
    
    // done
    return screen
}