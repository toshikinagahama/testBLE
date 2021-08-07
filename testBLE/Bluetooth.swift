import Combine

public class CoreObject: ObservableObject{
    @Published public var x: Int = 10
    @Published public var y: Int = 0
    @Published public var direction: Int = 0
    
}
