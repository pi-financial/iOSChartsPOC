//
//  ViewController.swift
//  ChartTest
//
//  Created by Nutan Niraula on 11/10/2565 BE.
//

import UIKit
import Charts

final class ViewController: UIViewController {
    
    private let stackView = UIStackView()
    private let titleStackView = UIStackView()
    private let label = UILabel()
    private let valueLabel = UILabel()
    private let chartView = CombinedChartView()
    private let segmentedControl = UISegmentedControl(items: ["1W", "1M", "3M", "6M", "1Y", "Max"])

    private var dataArray1 = [[Double]]()
    private var dataArray0 = [[Double]]()

    private var dataArray2 = [[Double]]()
    private var dataArray3 = [[Double]]()
    private var dataArray4 = [[Double]]()
    private var dataArray5 = [[Double]]()
    
    private let mainChartGradient = CGGradient(
        colorsSpace: nil,
        colors: [
            ChartColorTemplates.colorFromString("#00ff0866").cgColor,
            ChartColorTemplates.colorFromString("#ffff0000").cgColor
        ] as CFArray,
        locations: nil
    )!
    
    private var chartDataset = LineChartDataSet(entries: [ChartDataEntry](), label: "Price")
    private var deselectedDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "")
    private var dummyDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "")
    private var dataSets : [LineChartDataSet] = [LineChartDataSet]()
    private var barDs = BarChartDataSet(entries: [BarChartDataEntry](), label: "Bar Data")

    private var selectedYValues = [ChartDataEntry]()
    private var deselectedYValues = [ChartDataEntry]()
    private var yValueBarChart = [BarChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabels()
        setupChartView()
        
        setupChartDataSet()
        loadData(from: "ZRXUSD_1440")
        setupDummyDataSet()
        setupDeselectedDataSet()
        setupSegmentedControl()
        
        // bar chart data
        barDs.highlightEnabled = false
        barDs.colors = [.lightGray]
        
        dataSets.append(dummyDataSet)
        dataSets.append(chartDataset)
        dataSets.append(deselectedDataSet)
        
        titleStackView.axis = .horizontal
        titleStackView.addArrangedSubview(label)
        titleStackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(chartView)
        stackView.addArrangedSubview(segmentedControl)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 300.0)
        ])
    }
    
    func loadData(from: String) {
        selectedYValues.removeAll()
        deselectedYValues.removeAll()
        yValueBarChart.removeAll()
        
        loadData(in: &dataArray1, from)
        loadData(in: &dataArray0, from)
        for i in 0 ..< dataArray1.count {
            selectedYValues.append(ChartDataEntry(x: Double(i + 1), y: dataArray1[i][3]))
            deselectedYValues.append(ChartDataEntry(x: Double(i + 1), y: dataArray1[i][3]))
            yValueBarChart.append(BarChartDataEntry(x: Double(i + 1), y: dataArray1[i][5] * 0.0000001))
        }

        dummyDataSet.replaceEntries(selectedYValues)
        chartDataset.replaceEntries(selectedYValues)
        barDs.replaceEntries(yValueBarChart)
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(dummyDataSet)
        dataSets.append(chartDataset)
        dataSets.append(deselectedDataSet)
        
        let combinedData = CombinedChartData()
        combinedData.barData = BarChartData(dataSets: [barDs])
        combinedData.lineData = LineChartData(dataSets: dataSets)
        chartView.data = combinedData
    }
}

// MARK: - View Setup
extension ViewController {
        
    func setupLabels() {
        label.text = "   Chart test: ZRX-USD"
        valueLabel.text = "0.0"
        valueLabel.textColor = .red
    }
    
    func setupChartView() {
        let combinedData = CombinedChartData()
        combinedData.barData = BarChartData(dataSets: [barDs])
        combinedData.lineData = LineChartData(dataSets: dataSets)
        chartView.data = combinedData
        
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.drawBordersEnabled = false
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        
        // selected black marker
        let marker = CircleMarker(color: .black)
        chartView.marker = marker
        
        chartView.delegate = self
    }
    
    func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 4
        segmentedControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
    }
    
    @objc func updateData(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadData(from: "ZRXUSD_1")
        case 1:
            loadData(from: "ZRXUSD_15")
        case 2:
            #warning("big data set over 8000 data points, used just for testing")
            loadData(from: "ZRXUSD_60")
        case 3:
            loadData(from: "ZRXUSD_720")
        case 4:
            loadData(from: "ZRXUSD_1440")
        default:
            loadData(from: "ZRXUSD_1440")
        }
        chartView.animate(yAxisDuration: 0.2, easingOption: .easeInOutBounce)
    }
}

// MARK: - Setup datasets
extension ViewController {
    
    
    func setupChartDataSet() {
        chartDataset.colors = [UIColor(red: 1.0, green: 8.0/255, blue: 102/255, alpha: 1.0)]
        chartDataset.drawCirclesEnabled = false
        chartDataset.mode = .cubicBezier
        chartDataset.drawValuesEnabled = false
        chartDataset.fillAlpha = 1
        chartDataset.fill = LinearGradientFill(gradient: mainChartGradient, angle: 90)
        chartDataset.drawFilledEnabled = true
        chartDataset.highlightEnabled = false
    }
    
    func setupDummyDataSet() {
        dummyDataSet.fillAlpha = 0
        dummyDataSet.fill = LinearGradientFill(gradient: mainChartGradient, angle: 90)
        dummyDataSet.drawFilledEnabled = false
        dummyDataSet.drawCirclesEnabled = false
        dummyDataSet.drawValuesEnabled = false
        
        //highlight vertical line
        dummyDataSet.setDrawHighlightIndicators(true)
        dummyDataSet.drawHorizontalHighlightIndicatorEnabled = false
        dummyDataSet.highlightColor = .black
        dummyDataSet.highlightLineWidth = 1
        dummyDataSet.highlightLineDashLengths = [5]
        dummyDataSet.highlightEnabled = true
    }
    
    func setupDeselectedDataSet() {
        deselectedDataSet.colors = [.gray]
        deselectedDataSet.drawCirclesEnabled = false
        deselectedDataSet.drawValuesEnabled = false
        let gradientColors0 = [ChartColorTemplates.colorFromString("#00aaaaaa").cgColor,
                              ChartColorTemplates.colorFromString("#ffffffff").cgColor]
        let gradient0 = CGGradient(colorsSpace: nil, colors: gradientColors0 as CFArray, locations: nil)!
        deselectedDataSet.fillAlpha = 1
        deselectedDataSet.fill = LinearGradientFill(gradient: gradient0, angle: 90)
        deselectedDataSet.drawFilledEnabled = true
        deselectedDataSet.highlightEnabled = false
    }
}

// MARK: - ChartViewDelegate
extension ViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        let a = Array(selectedYValues.prefix(Int(entry.x)))
        let b = Array(deselectedYValues.suffix(selectedYValues.count - Int(entry.x)))
        valueLabel.text = "\(entry.y)"
        valueLabel.textColor = entry.y > 0.8 ? UIColor(red: 13/255, green: 115/255, blue: 119/255, alpha: 1.0) : .red
        chartDataset.replaceEntries(a)
        deselectedDataSet.replaceEntries(b)
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
        chartDataset.replaceEntries(selectedYValues)
        deselectedDataSet.replaceEntries([])
    }
}

// MARK: - Utility functions
extension ViewController {
    func loadData(in dataArray: inout [[Double]], _ forResource: String) {
        if let path = Bundle.main.path(forResource: forResource, ofType: "csv") {
            dataArray = []
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                let dataEncoded = String(data: data, encoding: .utf8)
                dataArray = csv(data: dataEncoded!)
                print(dataArray[1][1])
            } catch let jsonErr {
                print("\n Error reading CSV file: \n ", jsonErr)
            }
        }
        print(dataArray)
    }
    
    func csv(data: String) -> [[Double]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 1 { continue }
            result.append(columns)
        }
        return result.map { elements in
            elements.map { element in
                Double(element)!
            }
        }
    }
}


class CircleMarker: MarkerImage {
    
    @objc var color: UIColor
    @objc var radius: CGFloat = 4
    
    @objc public init(color: UIColor) {
        self.color = color
        super.init()
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        let circleRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: circleRect)
        
        context.restoreGState()
    }
}
