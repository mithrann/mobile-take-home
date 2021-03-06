//
//  CSVHelper.swift
//  TakeHomeChallenge
//
//  Created by Mithran Natarajan on 5/8/19.
//  Copyright © 2019 Mithran Natarajan. All rights reserved.
//

import Foundation
import CSV

class CSVHelper {
    /*
     Reading CSVfile with CSV library
     */
    static func getCSVReader(filename:String) -> CSVReader? {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else { return nil }
        guard let stream = InputStream(fileAtPath: filepath) else { return nil }
        guard let reader = try? CSVReader(stream: stream, hasHeaderRow: true) else { return nil }
        return reader
    }
    
    /*
     Reading airlines csv file and added conveted into map
     */
    static func parseAirlineCSV() -> [String: Airline]{
        var data: [String: Airline] = [:]
        guard let csvReader = getCSVReader(filename: CSVFile.airlines) else { return data }
        let decoder = CSVRowDecoder()
        while csvReader.next() != nil {
            if let row = try? decoder.decode(Airline.self, from: csvReader){
                data[row.twoDigitCode] = row
            }
        }
        return data
    }
    
    
    /*
     Reading airports csv file and added as vertex in the graph after Decoding
     */
    static func parseAirportCSV(graph: inout AdjacencyList<Airport>) -> [String: Vertex<Airport>]{
        var vertexMap: [String: Vertex<Airport>] = [:]
        guard let csvReader = getCSVReader(filename: CSVFile.airports) else { return vertexMap }
        let decoder = CSVRowDecoder()
        while csvReader.next() != nil {
            if let row = try? decoder.decode(Airport.self, from: csvReader){
                let vertex = graph.createVertex(data: row)
                vertexMap[row.iata] = vertex
            }
        }
        
        return vertexMap
    }
    
    /*
     Reading routes csv file to finds the edges(paths) and added into graph
     */
    static func parseRouteCSV(airlineMap: [String: Airline], airportVertexMap: [String: Vertex<Airport>], graph: inout AdjacencyList<Airport>) -> Void{
        guard let csvReader = getCSVReader(filename: CSVFile.routes) else { return }
        let decoder = CSVRowDecoder()
        while csvReader.next() != nil {
            if let row = try? decoder.decode(Route.self, from: csvReader){
                let airlineName = airlineMap[row.airlineId]?.name
                if let originVertex = airportVertexMap[row.origin], let destinationVertex = airportVertexMap[row.destination]{
                    graph.addDirectedEdge(from: originVertex, to: destinationVertex, weight: 1, via: airlineName)
                }
            }
        }
    }
    
}
