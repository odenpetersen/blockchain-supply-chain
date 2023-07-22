places = ["hongkong", "mumbai", "newyork", "seattle", "london", "johannesburg", "houston", "dubai", "sydney"]

shipping_time_days = [
    ("hongkong", "mumbai", 15),
    ("hongkong", "seattle", 20),
    ("hongkong", "dubai", 10),
    ("hongkong", "sydney", 7),
    
    ("mumbai", "seattle", 20),
    ("mumbai", "johannesburg", 18),
    ("mumbai", "dubai", 3),
    ("mumbai", "sydney", 8),
    
    ("newyork", "seattle", 5),
    ("newyork", "london", 10),
    ("newyork", "johannesburg", 15),
    ("newyork", "houston", 8),
    
    ("seattle", "london", 18),
    ("seattle", "johannesburg", 18),
    ("seattle", "houston", 5),
    ("seattle", "dubai", 12),
    ("seattle", "sydney", 11),
    
    ("london", "johannesburg", 14),
    ("london", "dubai", 9),
    
    ("johannesburg", "dubai", 8)
]

graph = dict()
for start,end,days in shipping_time_days:
    if start not in graph:
        graph[start] = dict()
    graph[start][end] = days
    if end not in graph:
        graph[end] = dict()
    graph[end][start] = days

import heapq
#How to deliver from point A to point B 
def route(origin, destination):
    for place in origin,destination:
        if place not in places:
            raise Exception(f"{place} not in list of places, {places}.")

    #BFS
    queue = [(0,origin)]

    source = {origin : origin}

    while queue:
        cur_time, cur = heapq.heappop(queue)
        for neighbour, shipping_time in graph[cur].items():
            if neighbour not in source:
                source[neighbour] = cur
                heapq.heappush(queue,(cur_time + shipping_time,neighbour))
            if neighbour == destination:
                locations = []
                cur_location = destination
                while destination != origin:
                    locations.append(destination)
                    destination = source[destination]
                locations.append(origin)
                locations.reverse()
                return locations

    return None

def estimate_days(places_list):
    return sum(map(lambda pair : graph[pair[0]][pair[1]], zip(places_list,places_list[1:])))
