import SwiftUI

struct Section {
    let index: Int
    let color: Color
}

struct ContentView: View {
    
    let sections: [Section] = [.init(index: 0,
                                     color: Color.blue),
                               .init(index: 1,
                                     color: Color.pink),
                               .init(index: 2,
                                     color: Color.gray),
                               .init(index: 3,
                                     color: Color.orange),
                               .init(index: 4,
                                     color: Color.cyan),
                               .init(index: 5,
                                     color: Color.brown)
    ]
    
    @State var selectedIndex: Int = 0
    @State var xOffset: Double = 0.0
    @State var restedXOffset: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            ZStack {
                ForEach(sections, id: \.self.index) { section in
                    placeholder(color: section.color)
                        .scaleEffect(itemScale(itemIndex: section.index,
                                               currentScrollOffset: xOffset))
                        .offset(x: itemOffset(itemIndex: section.index,
                                              currentScrollOffset: xOffset))
                        .blur(radius: itemBlur(itemIndex: section.index,
                                               currentScrollOffset: xOffset) * 100)
                        
                }
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    xOffset = gesture.translation.width + restedXOffset
                }
                .onEnded { gesture in
                    let newIndex = predictedIndex(predictedEndOffset: gesture.predictedEndTranslation.width + restedXOffset)
                    if newIndex == selectedIndex {
                        animateTo(index: newIndex)
                    } else {
                        selectedIndex = newIndex
                    }
                }
        )
        .onChange(of: selectedIndex) { newIndex in
            animateTo(index: newIndex)
        }
    }
    
    func animateTo(index: Int) {
        withAnimation(Animation.interpolatingSpring(mass: 1.0,
                                                    stiffness: 100,
                                                    damping: 100,
                                                    initialVelocity: 10)) {
            xOffset = -(700 * Double(index))
            restedXOffset = xOffset
        }
    }
    
    func predictedIndex(predictedEndOffset: Double) -> Int {
        var returnIndex = 0
        var closestRange = Double(Int.max)
        sections.enumerated().forEach { (i, section) in
            let value = -(700 * Double(i))
            let difference = abs(predictedEndOffset - value)
            
            if difference < closestRange {
                returnIndex = i
                closestRange = difference
            }
        }
        return returnIndex
    }
    
    func itemOffset(itemIndex: Int,
                    currentScrollOffset: Double) -> Double {
        
        let proposedOffset = proposedOffset(itemIndex: itemIndex,
                                            currentScrollOffset: currentScrollOffset)
        
        if proposedOffset < 0 {
            let newOffset = proposedOffset * 0.2
            return newOffset
        } else {
            return proposedOffset
        }
    }
    
    func itemScale(itemIndex: Int,
                   currentScrollOffset: Double) -> Double {
        let proposedOffset = proposedOffset(itemIndex: itemIndex,
                                            currentScrollOffset: currentScrollOffset)
        
        if proposedOffset < 0 {
            let toReturn = 1 - calculate(paceAdjustment: 3.0,
                                         minimum: 0.0,
                                         maximum: 1.0,
                                         proposedOffset: proposedOffset)
            return toReturn
        } else {
            return 1.0
        }
    }
    
    func itemBlur(itemIndex: Int,
                  currentScrollOffset: Double) -> Double {
        let proposedOffset = proposedOffset(itemIndex: itemIndex,
                                            currentScrollOffset: currentScrollOffset)
        if proposedOffset < 0 {
            let toReturn = calculate(paceAdjustment: 5.0,
                                     minimum: 0.0,
                                     maximum: 0.2,
                                     proposedOffset: proposedOffset)
            return toReturn
        } else {
            return 0.0
        }
    }
    
    func proposedOffset(itemIndex: Int,
                        currentScrollOffset: Double) -> Double {
        let itemIndexAsDouble = Double(itemIndex)
        return (itemIndexAsDouble * 700) + currentScrollOffset
    }
    
    func calculate(paceAdjustment: Double,
                   minimum: Double,
                   maximum: Double,
                   proposedOffset: Double) -> Double {
        
        let paceAdjustment = paceAdjustment
        let minimum = minimum
        let maximum = maximum
        
        let halfScreenWidth = UIScreen.screenWidth * paceAdjustment
        let progressOffset = abs(proposedOffset)
        
        let progress = ((progressOffset / halfScreenWidth))
        return max(minimum, min(maximum, progress))
    }
    
    func placeholder(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(color)
            .frame(width: 600, height: 600)
    }

}


extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
