places = ["hongkong", "mumbai", "newyork", "seattle", "london", "johannesburg", "houston", "dubai"]

shipping_time_days = [
    ("hongkong", "mumbai", 15),
    ("hongkong", "seattle", 20),
    ("hongkong", "dubai", 10),
    
    ("mumbai", "seattle", 20),
    ("mumbai", "johannesburg", 18),
    ("mumbai", "dubai", 3),
    
    ("newyork", "seattle", 5),
    ("newyork", "london", 10),
    ("newyork", "johannesburg", 15),
    ("newyork", "houston", 8),
    ("newyork", "dubai", 10),
    
    ("seattle", "london", 18),
    ("seattle", "johannesburg", 18),
    ("seattle", "houston", 5),
    ("seattle", "dubai", 12),
    
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
            raise Exception("{place} not in list of places, {places}.")

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
