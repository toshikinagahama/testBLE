import SwiftUI
import Charts

/**
  3軸のデータを保持するクラス
 */
class ThreeAxesData: ObservableObject {
    @Published var xChartDataEntry : [ChartDataEntry] = []
    @Published var yChartDataEntry : [ChartDataEntry] = []
    @Published var zChartDataEntry : [ChartDataEntry] = []
}
 

/**
  3つの折れ線データを描画するクラス
 */
struct LineChart : UIViewRepresentable {
    @ObservedObject var accData: ThreeAxesData
    @State var chart = LineChartView()
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        updateChartData()

    }

    func makeUIView(context: Context) -> LineChartView {
        // グラフに表示する要素
        let data = LineChartData()
        //x
        let xDataSet = LineChartDataSet(entries: accData.xChartDataEntry, label: "x acc")
        //xDataSet.mode = .cubicBezier
        xDataSet.drawCirclesEnabled = false
        xDataSet.setColor(.red)
        xDataSet.drawValuesEnabled = false
        //y
        let yDataSet = LineChartDataSet(entries: accData.yChartDataEntry, label: "y acc")
        //yDataSet.mode = .cubicBezier
        yDataSet.drawCirclesEnabled = false
        yDataSet.setColor(.blue)
        yDataSet.drawValuesEnabled = false
        //z
        let zDataSet = LineChartDataSet(entries: accData.zChartDataEntry, label: "z acc")
        //zDataSet.mode = .cubicBezier
        zDataSet.drawCirclesEnabled = false
        zDataSet.setColor(.green)
        zDataSet.drawValuesEnabled = false

        // データセットを作ってチャートに反映
        data.addDataSet(xDataSet)
        data.addDataSet(yDataSet)
        data.addDataSet(zDataSet)
        chart.data = data

        return chart
    }
    
    func updateChartData(){
        // update
        let data = LineChartData()
        //x
        let xDataSet = LineChartDataSet(entries: accData.xChartDataEntry, label: "x acc")
        //xDataSet.mode = .cubicBezier
        xDataSet.drawCirclesEnabled = false
        xDataSet.setColor(.red)
        xDataSet.drawValuesEnabled = false
        //y
        let yDataSet = LineChartDataSet(entries: accData.yChartDataEntry, label: "y acc")
        //yDataSet.mode = .cubicBezier
        yDataSet.drawCirclesEnabled = false
        yDataSet.setColor(.blue)
        yDataSet.drawValuesEnabled = false
        //z
        let zDataSet = LineChartDataSet(entries: accData.zChartDataEntry, label: "z acc")
        //zDataSet.mode = .cubicBezier
        zDataSet.drawCirclesEnabled = false
        zDataSet.setColor(.green)
        zDataSet.drawValuesEnabled = false

        // データセットを作ってチャートに反映
        data.addDataSet(xDataSet)
        data.addDataSet(yDataSet)
        data.addDataSet(zDataSet)

        //print(accData.xChartDataEntry)

        chart.data = data
    }
}


struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    @ObservedObject var accData = ThreeAxesData()
    @State var count = 1

    var body: some View {
        VStack (spacing: 10) {

            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            List(bleManager.peripherals) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Spacer()
                    Text(String(peripheral.rssi))
                }
            }.frame(height: 300)

            Spacer()
            //Text("\(self.bleManager.value[0])")

            Text("STATUS")
                .font(.headline)
            LineChart(accData: accData)
                .onChange(of: self.bleManager.value) { value in
                    if(accData.xChartDataEntry.count > 32 * 5){
                        accData.xChartDataEntry.removeFirst()
                        accData.yChartDataEntry.removeFirst()
                        accData.zChartDataEntry.removeFirst()
                    }
                    accData.xChartDataEntry.append(ChartDataEntry(x: Double(Double(count) / 32.0), y: value[0]))
                    accData.yChartDataEntry.append(ChartDataEntry(x: Double(Double(count) / 32.0), y: value[1]))
                    accData.zChartDataEntry.append(ChartDataEntry(x: Double(Double(count) / 32.0), y: value[2]))
                    count += 1
                }

            // Status goes here
            if bleManager.isSwitchedOn {
                Text("Bluetooth is switched on")
                    .foregroundColor(.green)
            }
            else {
                Text("Bluetooth is NOT switched on")
                    .foregroundColor(.red)
            }

            Spacer()

            HStack {
                VStack (spacing: 10) {
                    Button(action: {
                        self.bleManager.startScanning()
                    }) {
                        Text("Start Scanning")
                    }
                    Button(action: {
                        self.bleManager.stopScanning()
                    }) {
                        Text("Stop Scanning")
                    }
                }.padding()

                Spacer()

                VStack (spacing: 10) {
                    Button(action: {
                        let data = Data(_: [0x31, 0x31, 0x31, 0x31])
                        self.bleManager.myPeripheral.writeValue(data , for: self.bleManager.writeCharacteristic!, type: .withResponse)
                    }) {
                        Text("Start Meas")
                    }
                    Button(action: {
                        let data = Data(_: [0x32, 0x32, 0x32, 0x32])
                        self.bleManager.myPeripheral.writeValue(data , for: self.bleManager.writeCharacteristic!, type: .withResponse)
                    }) {
                        Text("Stop Meas")
                    }
                }.padding()
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
